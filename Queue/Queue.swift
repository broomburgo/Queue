/// 'Queue' is a struct that wraps a dispatch_queue_t and implements methods to execute sync and async tasks

import Foundation

///MARK: - Queue
public struct Queue {
    let dispatchQueue: dispatch_queue_t
    
    /// Queue initialization takes a dispatch_queue_t; if omitted, creates a serial dispatch_queue_t with defaultQueueIdentifier
    public init(_ queue: dispatch_queue_t = dispatch_queue_create("defaultQueueIdentifier", DISPATCH_QUEUE_SERIAL)) {
        self.dispatchQueue = queue
    }
    
    /// a couple of value methods, to conveniently initialize a reference to the main queue or to the default priority global queue
    public static let main = Queue(dispatch_get_main_queue())
    public static let global = Queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    
    /// the 'execute' method wraps the the basic functionality of the class
    public func executeAsynchronously(async: Bool, _ task: () -> ()) {
        if (async) {
            dispatch_async(dispatchQueue, task)
        }
        else {
            dispatch_sync(dispatchQueue, task)
            /// N.B dispatch_sync MUST NOT be called on the main queue, or it will lock the queue and block the running application forever; "sync" is only for background tasks
        }
    }
    
    /// convenience methods to execute tasks synchronously or asynchronously
    public func sync(task: () -> ()) {
        executeAsynchronously(false, task)
    }
    public func async(task: () -> ()) {
        executeAsynchronously(true, task)
    }
    
    /// the "after" method asynchronously executes a task after a certain number of seconds
    public func after(seconds: Double, _ task: () ->()) {
        let afterTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(afterTime, dispatchQueue, task)
    }
}

/// the "after" function is a simple shortcut to call Queue.main.after
public func after (seconds: Double, task: () -> ()) {
    Queue.main.after(seconds, task)
}


