//
//  Dispatch.swift
//  AvidcodeToolbox
//
//  Created by Andrew Christiansen on 4/17/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation


/**
 Provides a Swifty wrapper around dispatch queues.
 
 ----
 
 Using this class to work with dispatch queues provides the following benefits:

 **Queue-Local Storage**: Use `DispatchQueue.subscript` to set/get arbitrary values.
 **Current Queue Retrieval**: Ability to get the current queue from `DispatchQueue.Current`.

 ----
 
 Only a single instance of a `DispatchQueue` will be created per queue.
 The lifetime of the `DispatchQueue` instance will last until it and the queue it is wrapping
 are no longer referenced.
*/
public class DispatchQueue : Hashable, CustomStringConvertible {
    weak private var _unownedQueue : dispatch_queue_t!;
    private var _ownedQueue : dispatch_queue_t?;
    private var _storage = [String: Any]();
    
    private class QueueSpecificObject {}
    private static let QueueSpecificKey = QueueSpecificObject();
    private static let ObjectSpecificKeyAddress = UnsafeMutablePointer<Void>(Unmanaged.passUnretained(QueueSpecificKey).toOpaque());
    
    private init(queue: dispatch_queue_t, owns: Bool) {
        precondition(dispatch_queue_get_specific(queue, DispatchQueue.ObjectSpecificKeyAddress) == nil,
                     "This queue already has an instance associated with it.");
        
        _unownedQueue = queue;
        
        if (owns) {
            _ownedQueue = queue;
            dispatch_queue_set_specific(
                queue,
                DispatchQueue.ObjectSpecificKeyAddress,
                UnsafeMutablePointer<DispatchQueue>(Unmanaged.passUnretained(self).toOpaque()),
                QueueDeallocatedUnownedHandler);
        } else {
            dispatch_queue_set_specific(
                queue,
                DispatchQueue.ObjectSpecificKeyAddress,
                UnsafeMutablePointer<DispatchQueue>(Unmanaged.passRetained(self).toOpaque()),
                QueueDeallocatedHandler);

        }
    }
    deinit {
        if let wq = self.wrappedQueue {
            dispatch_queue_set_specific(wq, DispatchQueue.ObjectSpecificKeyAddress, nil, nil);
        }
    }

    /** Appoints the given queue as the target for items added to this queue. */
    public func assignTargetQueue(queue: DispatchQueue) {
        dispatch_set_target_queue(self.wrappedQueue!, queue.wrappedQueue!);
    }

    private var wrappedQueue : dispatch_queue_t? {
        get {
            return _ownedQueue ?? _unownedQueue;
        }
    }
    
    /** Determines if this queue is the main queue. */
    public var isMainQueue : Bool {
        get {
            return self == DispatchQueue.Main;
        }
    }

    /** Associates user data with this queue by key. */
    public subscript(key: String) -> Any? {
        get {
            return _storage[key];
        }
        set {
            _storage[key] = newValue;
        }
    }

    /** Dispatches the given code asynchronously. */
    public func async(code: () -> Void) {
        dispatch_async(self.wrappedQueue!) {
            let _ = self;
            code();
        };
    }
    
    /** Dispatches the given code synchronously. */
    public func sync(code: () -> Void) {
        dispatch_sync(self.wrappedQueue!) {
            let _ = self;
            code();
        };
    }
    
    /**
     Dispatches the given code synchronously, safe from deadlock situations.
 
     - remark: If a synchronous dispatch is made while executing in that queue, a deadlock situation
        occurs because the method blocks until the code is executed. 
     
        To mitigate deadlock, if the queue that is executing is the same as the target queue, the
        code block is called immediately, bypassing the dispatch queue entirely.
    */
    public func safeSync(code: () -> Void) {
        if self == DispatchQueue.Current {
            code();
        } else {
            sync(code);
        }
    }
    
    /** Dispatches the given code asynchronously, after the specified time period has elapsed. */
    public func after(time: TimeInterval, code: () -> Void) {
        let time = dispatch_time(DISPATCH_TIME_NOW, time.microseconds * 1000);
        dispatch_after(time, self.wrappedQueue!) {
            let _ = self;
            code();
        };
    }

    public var hashValue: Int {
        get {
            return unsafeAddressOf(self.wrappedQueue!).hashValue;
        }
    }
    
    public var description: String {
        get {
            let addr = unsafeAddressOf(self.wrappedQueue!);
            let label = String(dispatch_queue_get_label(self.wrappedQueue!));
            
            return "[Dispatch Queue \(addr): Name = \(label.isEmpty ? "<unnamed>" : label); Is Main Queue = \(self.isMainQueue)]";
        }
    }
}

public extension DispatchQueue {
    
    /**
     Creates a dispatch queue.
     
     - parameters:
        - kind: The kind of queue to create (serial or concurrent).
        - qualityClass: The quality of service class to assign to the queue.
        - label: Text that is associated with the queue to aide in debugging.
     
     - returns: A newly created `DispatchQueue`.
    */
    public static func create(kind: DispatchQueueKind, qualityClass: DispatchQueueQualityOfService = .Default, label: String = "") -> DispatchQueue {
        let attr = dispatch_queue_attr_make_with_qos_class(kind.rawValue, qualityClass.rawValue, 0);
        let queue = dispatch_queue_create((label as NSString).UTF8String, attr);
        return takeExistingQueue(queue);
    }
    
    /**
     Wraps and takes ownership of the given queue.
     
     - Warning:
        It is an error to call this method to take ownership of a queue that has already
        been wrapped by a previous call to `takeExistingQueue`, or to pass in a queue that
        was not explicitly created by a call to `dispatch_queue_create`.
    */
    public static func takeExistingQueue(queue: dispatch_queue_t) -> DispatchQueue {
        return DispatchQueue.findExistingWrapper(queue, createIfNecessary: true, owns: true)!;
    }
    
    /** Gets the main dispatch queue. */
    public static let Main : DispatchQueue = DispatchQueue.fromExistingQueue(dispatch_get_main_queue());
    
    /** Gets a global queue with the specified quality of service class. */
    public static func getGlobal(qos: DispatchQueueQualityOfService = DispatchQueueQualityOfService.Default) -> DispatchQueue {
        return fromExistingQueue(dispatch_get_global_queue(qos.rawValue, 0));
    }
    
    /** Gets the default quality of service global queue. */
    public static var Global : DispatchQueue {
        get {
            return getGlobal(DispatchQueueQualityOfService.Default);
        }
    }

    /**
     Gets the queue the current code is running on.
     
     - Warning:
     This property will return `nil` if the current queue has never touched this `DispatchQueue` wrapper.
    */
    public static var Current : DispatchQueue? {
        get {
            let _ = DispatchQueue.Main;
            
            let ptr = dispatch_get_specific(DispatchQueue.ObjectSpecificKeyAddress);
            if (ptr == nil) {
                return nil;
            }
            
            let unman =  Unmanaged<DispatchQueue>.fromOpaque(COpaquePointer(ptr));
            return unman.takeUnretainedValue();
        }
    }
    
    
    private static func findExistingWrapper(queue: dispatch_queue_t, createIfNecessary: Bool = false, owns: Bool = false) -> DispatchQueue? {
        let ptr = dispatch_queue_get_specific(queue,  DispatchQueue.ObjectSpecificKeyAddress);
        if (ptr != nil) {
            let unman =  Unmanaged<DispatchQueue>.fromOpaque(COpaquePointer(ptr));
            return unman.takeUnretainedValue();
        }
        
        if (!createIfNecessary) {
            return nil;
        }
        
        return DispatchQueue(queue: queue, owns: owns);
    }
    private static func fromExistingQueue(queue: dispatch_queue_t) -> DispatchQueue {
        return DispatchQueue.findExistingWrapper(queue, createIfNecessary: true, owns: false)!;
    }
}

public func ==(lhs: DispatchQueue, rhs: DispatchQueue) -> Bool {
    return lhs.wrappedQueue! === rhs.wrappedQueue!;
}

private func QueueDeallocatedUnownedHandler(ptr: UnsafeMutablePointer<Void>) -> Void {
    
}
private func QueueDeallocatedHandler(ptr: UnsafeMutablePointer<Void>) -> Void {
    let unman =  Unmanaged<DispatchQueue>.fromOpaque(COpaquePointer(ptr));
    let wrapper = unman.takeRetainedValue();
    
    wrapper._ownedQueue = nil;
    wrapper._unownedQueue = nil;
}
