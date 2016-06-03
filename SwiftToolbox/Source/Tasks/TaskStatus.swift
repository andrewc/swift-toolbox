//
//  TaskSTatus.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/10/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public enum TaskResultErrors : ErrorType {
    /** Indicates the status is completed, but the result value could not be cast to the requested type. */
    case ValueCastFailed;
    /** Indicates that no result value is available. */
    case ResultValueUnavailable
}

public enum TaskStatus : Hashable {
    /** The task has been created but nothing has been done with it yet. */
    case Created;
    /** The task has been scheduled to begin running. */
    case Scheduled;
    /** The task is actively running. */
    case Running;
    /** The task threw a `TaskCancelled` error indicating cooperative cancellation. */
    case Cancelled;

    /** The task completed successfully with the associated result value. */
    case Completed(Any);
    /** The task threw the associated error value, indicating the task faulted. */
    case Faulted(ErrorType);
    
    // MARK: - Result Value Querying
    
    /**
     Acts upon the result of this enumeration in a structured manner.

     - returns: The only time `nil` is returned is if the status is not `Completed`.
     - throws: 
        `TaskResultErrors.ValueCastFailed`: If `Completed` but the result value cannot be cast to `ResultType`.\
        If `Faulted`, the associated error value is thrown.
    */
    public func value<ResultType>() throws -> ResultType? {
        switch self {
        case let .Completed(result):
            if let result = result as? ResultType {
                return result;
            }
            throw TaskResultErrors.ValueCastFailed;
        case let .Faulted(error):
            throw error;
        default:
            return nil;
        }
    }
    
    public var hashValue: Int {
        switch self {
        case .Created:
            return 0;
        case .Scheduled:
            return 1;
        case .Running:
            return 2;
        case .Completed(_):
            return 3;
        case .Faulted(_):
            return 4;
        case .Cancelled:
            return 5;
        }
    }
    
    // MARK: - Collective Status Querying
    
    /** True if the status of this task is final (not in `Created`, `Scheduled`, or `Running` states). */
    public var isFinal : Bool {
        get {
            return (self.isFaulted || self.isCompleted || self.isCancelled);
        }
    }
    
    /** True if this instance represents a case which has a result (`Completed` or `Faulted`), otherwise `False`. */
    public var isResultAvailable : Bool {
        get {
            return (self.isCompleted || self.isFaulted);
        }
    }
    
    // MARK: - Status Querying
    
    public var isScheduled : Bool {
        get {
            if case .Scheduled = self {
                return true;
            }
            return false;
        }
    }
    public var isRunning : Bool {
        get {
            if case .Running = self {
                return true;
            }
            return false;
        }
    }
    public var isCreated : Bool {
        get {
            if case .Created = self {
                return true;
            }
            return false;
        }
    }
    public var isFaulted : Bool {
        get {
            if case .Faulted(_) = self {
                return true;
            }
            return false;
        }
    }
    public var isCompleted : Bool {
        get {
            if case .Completed(_) = self {
                return true;
            }
            return false;
        }
    }
    public var isCancelled : Bool {
        get {
            if case .Cancelled = self {
                return true;
            }
            return false;
        }
    }
}

// MARK: - Operators

public func ==(lhs: TaskStatus, rhs: TaskStatus) -> Bool {
    return lhs.hashValue == rhs.hashValue;
}