//
//  Waitable.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/12/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

public enum Timeout {
    public static let Infinite : Double = -1.0;
    public static let Test : Double = 0.0;
}

public struct WaitableTimedOut : ErrorType {};

/** Defines a protocol for objects that block thread execution. */
public protocol Waitable : CustomStringConvertible {
    
    /** 
    Blocks the calling thread until the waitable releases it, or the specified
    timeout duration has past.
 
    - parameters:
        - timeout: The number of seconds before the wait times out. \
            Pass `Timeout.Test` to test if the waitable is blocking.\
            Pass `Timeout.Infite` to wait forever.
     
    - returns: `True` if the waitable was released before the timeout expired, otherwise `False`.
    */
    func wait(timeout: Double) -> Bool;
}

public extension Waitable {
    /** Convenience property that tests if the waitable is currently blocking. */
    public var isBlocking : Bool {
        return !wait(Timeout.Test);
    }
}

extension Waitable {
    public var description : String {
        return "[\(String(self)): Blocking = \(self.isBlocking ? "Yes" : "No")]";

    }
}