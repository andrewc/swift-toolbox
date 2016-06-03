//
//  TaskOperation.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/11/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public protocol TaskTraits {
    /** Gets the options for this task. */
    var options : TaskOptions { get }
    
    /** Gets or sets the task's cancellation token. */
    var cancellationToken : TaskCancellationToken { get set }
    
}
/**
 Defines the interface task operations must implement.
*/
public protocol TaskOperation : TaskTraits {
    /** Gets the status of the task. */
    var status : TaskStatus { get }

    /** Block the calling thread until a result is available. If timeout has passed, a `WaitableTimedOut` error is thrown. */
    func anyValue(timeout : Double) throws -> Any;
    
    /** Starts executing the task. */
    func start(scheduler: TaskScheduler);
    
/** Adds the given observer to receive status change notifications for this task. */
    // func subscribe<TObserver : TaskStatusObserving where TObserver.OperationType == Self>(observer: TObserver, options: TaskObserverOptions);
}

///** A type-erased task operation. */
//public final class AnyTaskOperation<ResultType> : TaskOperation {
//    private let box: _AnyTaskOperationBase<ResultType>;
//    
//    public init<TOperation: TaskOperation where TOperation.ResultType == ResultType>(_ base: TOperation) {
//        self.box = _AnyTaskOperation(base);
//    }
//    
//    public var status : TaskStatus {
//        get {
//            return self.box.status;
//        }
//    }
//    public var options: TaskOptions {
//        get {
//            return self.box.options;
//        }
//    }
//    public func start(context: TaskExecutionContext) {
//        self.box.start(context);
//    }
//    public func execute(context: TaskExecutionContext) throws -> ResultType {
//        return try self.box.execute(context);
//    }
//}
//
//
//private class _AnyTaskOperationBase<ResultType> : TaskOperation {
//    var status: TaskStatus { get { fatalError(); } }
//    var options: TaskOptions { get { fatalError(); } }
//    
//    func execute(context: TaskExecutionContext) throws -> ResultType {
//        fatalError();
//    }
//    func start(context: TaskExecutionContext) {
//        fatalError();
//    }
//    
//}
//
//private class _AnyTaskOperation<TOperation: TaskOperation> : _AnyTaskOperationBase<TOperation.ResultType> {
//    typealias Result = TOperation.ResultType;
//    
//    let base : TOperation;
//    
//    init(_ base: TOperation) {
//        self.base = base;
//    }
//    
//    override var status : TaskStatus {
//        get {
//            return base.status;
//        }
//    }
//    override var options: TaskOptions {
//        get {
//            return base.options;
//        }
//    }
//    
//    override func start(context: TaskExecutionContext) {
//        base.start(context);
//    }
//    
//    override private func execute(context: TaskExecutionContext) throws -> Result {
//        return try base.execute(context);
//    }
//}
//
