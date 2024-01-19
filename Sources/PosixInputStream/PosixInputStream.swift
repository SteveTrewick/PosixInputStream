import Foundation
import PosixError


public class PosixInputStream {
  
  /*
    because while loops and posix threads are horrible, we will wrap our POSIXy bits in
    Grand Central Dispatch read sources and do things with a more eventy feel, as is tradition.
    
    pass in a live file descriptor for STDIN or a serial port, a pipe, whatever,
    set a handler, call resume and off we go.
    remember to set a cancel handler though so you can flush and close the FD after.
   
  */
  
  let queue      : DispatchQueue
  let source     : DispatchSourceRead
  
  public let descriptor : Int32
  
  let FIONREAD   : UInt = 0x4004667f  // IOCTL FIONREAD is not exposed through the header imports from ioctl.h, IDK why. FFS
  
  
  public var handler : ( (Result<Data, Trace>) -> () )? = nil
  
  
  public init(descriptor: Int32, targetQueue: DispatchQueue? = nil) {
  
    
    self.descriptor = descriptor
    
    if let target = targetQueue { self.queue = DispatchQueue(label: "posix_opq", target: target) }
    else {                        self.queue = DispatchQueue(label: "posix_opq")                 }
    
    self.source = DispatchSource.makeReadSource(fileDescriptor: descriptor, queue: queue)
    
    
    
    source.setEventHandler { [self] in
      
      guard let handler = handler else { return }
      
      var available = Int(0)
      let result    = ioctl(descriptor, FIONREAD, &available)
      
      guard available >  0 else { return }  // technically an error, but eh.
      guard result    == 0 else {
        defer {
          handler ( .failure ( .posix(self, tag: "ioctl FIONREAD") ) )
        }
        return
      }
      
      var bytes = [UInt8]( repeating: 0x00, count: available )
      let count = read( descriptor, &bytes, available )
                                     
      handler( .success ( Data ( bytes: bytes, count: count ) ) )
    }
  }
  
  
  // start delivering data
  
  public func resume() { source.resume() }
  
  
  // cancel is async, pass a completion if you want to know when it's done.
  // and you do, because you need to **safely** close the FD, mmkay?
  
  public func cancel( _ cancel_handler: (() -> ())? = nil ) {
    
    source.setCancelHandler {
      cancel_handler?()
    }
    
    handler = nil
    source.cancel()
  }
  
  
}
