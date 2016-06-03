//
//  WaitableEvent.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/12/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

/** A waitable that behaves like a gate for waiting threads. */
public class WaitableEvent : Waitable {
    private let _condition : NSConditionLock;
    
    /**
     Creates a new instance of this class.
 
     - parameters:
        - initiallySignaled: True to initialize the event in the signaled state, otherwise False.
        - automaticallyReset: True to automatically reset after a thread gets through.
    */
    public init(initiallySignaled: Bool = false, automaticallyReset autoreset: Bool = false) {
        self.automaticallyResets = autoreset;
        _condition = NSConditionLock(condition: (initiallySignaled ? 1 : 0));
    }
    
    /** Determines if the event is reset automatically once the first waiting thread is unblocked. */
    public let automaticallyResets : Bool;
    public var isSignaled : Bool {
        return _condition.condition == 1 ? true : false;
    }
    
    /** Releases the hold for all threads waiting. */
    public func set() {
        _condition.lock();
        _condition.unlockWithCondition(1);
    }
    public func reset() {
        _condition.lock();
        _condition.unlockWithCondition(0);
    }
    
    public func wait(timeout: Double) -> Bool {
        let beforeDate : NSDate;
        if (timeout == Timeout.Infinite) {
            beforeDate = NSDate.distantFuture();
        } else if (timeout == Timeout.Test) {
            beforeDate = NSDate();
        } else {
            beforeDate = NSDate().dateByAddingTimeInterval(timeout);
        }
        
        guard _condition.lockWhenCondition(1, beforeDate: beforeDate) else {
            return false;
        }
        
        if self.automaticallyResets {
            _condition.unlockWithCondition(0);
        } else {
            _condition.unlock();
        }
        
        return true;
    }
    
}