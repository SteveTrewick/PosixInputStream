# PosixInputStream

Wrap a POSIX file descriptor in a GCD read dispatch source so it will call you when new data is available.

I'm sure there are nicer ways of going about this but, eh. 
This is basically a translation of some old code I had knocking around from the Objective C days, works for me.

Useful for serial ports and the like.

## Usage



```
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

## Dependencies

Depends on [PosixError](https://github.com/SteveTrewick/PosixError), and by association [Trace](https://github.com/SteveTrewick/Trace)
