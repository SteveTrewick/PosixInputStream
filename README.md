# PosixInputStream

Wrap a POSIX file descriptor in a GCD read dispatch source so it will call you when new data is available.

I'm sure there are nicer ways of going about this but, eh. 
This is basically a translation of some old code I had knocking around from the Objective C days, works for me.

Useful for serial ports and the like.

## Usage



```swift

import PosixInputStream

// ...

let stream = PosixInputStream(descriptor: YOUR_FD)

stream.handler = { result in 
    switch result {
        case .failure(let trace): ... 
        case .success(let data) : ...
    }
}

stream.resume()

// ...

stream.cancel {
  // whatever you want to do when cancel is finished,
  // like cleanly fluch and close your file descriptor.
}

```

## Target queue

PosixInputStream uses its own internal dispatch queue with default priority.
If you need it to target another queue to keep things tidy, pass that on init like so ...

```swift

let stream = PosixInputStream(descriptor: YOUR_FD, targetQueue: YOUR_QUEUE)

```

## Dependencies

Depends on [PosixError](https://github.com/SteveTrewick/PosixError), and by association [Trace](https://github.com/SteveTrewick/Trace)
