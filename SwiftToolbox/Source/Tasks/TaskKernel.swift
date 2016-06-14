//
//  TaskKernel.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/11/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

public enum TaskKernels {
    /** Makes a kernel which immediately returns with the given result value. */
     public static func make<ResultType>(withValue result: ResultType) -> AnyTaskKernel<ResultType> {
        return AnyTaskKernel(ResultAvailableTaskKernel<ResultType>(result));
    }
    /** Makes a kernel which executes the given closure. */
    public static func make<ResultType>(kernel: (TaskCancellationToken) throws -> ResultType) -> AnyTaskKernel<ResultType>  {
        return AnyTaskKernel(ClosureTaskKernel(kernel));
    }
    /** Makes a kernel which executes the given closure. */
    public static func make<KernelType : TaskKernel, ResultType where KernelType.ResultType == ResultType>(kernel: KernelType) -> AnyTaskKernel<ResultType>  {
        return AnyTaskKernel(kernel);
    }
    /** Makse a kernel which immediately fails by throwing the given error. */
    public static func make<ResultType>(withError error: ErrorType) -> AnyTaskKernel<ResultType> {
        return AnyTaskKernel(FailImmediatelyTaskKernel(error));
    }
     public static func make() -> AnyTaskKernel<Void> {
          return make(withValue: ());
     }
}

/** Contains the cases an asynchronously finishing kernel uses to report its result. */
public enum TaskAsyncKernelResult<ValueType> {
    case Completed(ValueType);
    case Faulted(ErrorType);
}

/** This object is thrown from the `TaskKernel.execute` method to signal that
    that the kernel is still executing, but must do so asynchronously. The kernel
    will report the final status to `result`. */
public final class TaskKernelAsynchronousCompletion<ResultType> : ErrorType {
    private var _status : TaskAsyncKernelResult<ResultType>? = nil;
    private var completionHandler : ((TaskAsyncKernelResult<ResultType>) -> ())?;
    private var hasAppliedCompletionHandler = false;

    internal func setPhaseHandler(handler: (TaskKernelPhase<ResultType>) -> ()) {
        setCompletionHandler {
            switch $0 {
            case let .Completed(value):
                handler(.Completed(value));
                break;
            case let .Faulted(value):
                handler(.Failed(value));
                break;
            }
        };
    }
    internal func setCompletionHandler(handler: (TaskAsyncKernelResult<ResultType>) -> ()) {
        precondition(!hasAppliedCompletionHandler, "Completion handler can only be applied once.");
        hasAppliedCompletionHandler = true;
        completionHandler = handler;
        notifyCompletionIfNecessary();
    }
    
    public var result: TaskAsyncKernelResult<ResultType>? {
        get {
            return _status;
        }
        set {
            precondition(_status == nil, "Can only set the result once.");
            _status = newValue;
            self.notifyCompletionIfNecessary();
        }
    }
   
    private func notifyCompletionIfNecessary() {
        guard let handler = completionHandler, status = _status else {
            return;
        }
        
        completionHandler = nil;
        handler(status);
    }
}

/** Provides a protocol for objects to execute a task's kernel. */
public protocol TaskKernel {
    /** A placeholder representing the kernel's result value type. */
    associatedtype ResultType;
    
    /**
     Executes the kernel code.
    */
    func execute(cancellationToken: TaskCancellationToken) throws -> ResultType;
}
public extension TaskKernel {
    public var shouldExecuteSynchronously : Bool {
        return false;
    }
}

private final class ResultAvailableTaskKernel<TResult> : TaskKernel {
    private let _result : TResult;
    
    private init(_ result: TResult) {
        _result = result;
    }
    
    private var shouldExecuteSynchronously: Bool {
        return true;
    }
    
    private func execute(cancellationToken: TaskCancellationToken) throws -> TResult {
        return _result;
    }
}
private final class FailImmediatelyTaskKernel<TResult> : TaskKernel {
    private let _error: ErrorType;
    
    private init(_ error: ErrorType) {
        _error = error;
    }
    
    private var shouldExecuteSynchronously: Bool {
        return true;
    }
    
    private func execute(cancellationToken: TaskCancellationToken) throws -> TResult {
        throw _error;
    }
}
private final class ClosureTaskKernel<TResult> : TaskKernel {
    private let _kernel : (TaskCancellationToken) throws -> TResult;
    
    private init(_ kernel: (TaskCancellationToken) throws -> TResult) {
        _kernel = kernel;
    }
    
    private func execute(cancellationToken: TaskCancellationToken) throws -> TResult {
        return try _kernel(cancellationToken);
    }
}

/**
 A type-erased `TaskKernel`
*/
public final class AnyTaskKernel<ResultType> : TaskKernel {
    private let box : _AnyTaskKernelBase<ResultType>;
    
    public init<KernelType: TaskKernel where KernelType.ResultType == ResultType>(_ base: KernelType) {
        box = _AnyTaskKernel(base);
    }
    
    public func execute(cancellationToken: TaskCancellationToken) throws -> ResultType {
        return try self.box.execute(cancellationToken);
    }
    public var shouldExecuteSynchronously: Bool {
        return self.box.shouldExecuteSynchronously;
    }
}
private class _AnyTaskKernelBase<TResult> : TaskKernel {
    func execute(cancellationToken: TaskCancellationToken) throws -> TResult {
        fatalError();
    }
    private var shouldExecuteSynchronously: Bool {
        fatalError();
    }
}
private class _AnyTaskKernel<TKernel : TaskKernel> : _AnyTaskKernelBase<TKernel.ResultType> {
    typealias TResult  = TKernel.ResultType;
    
    private let base : TKernel;
    
    init(_ base: TKernel) {
        self.base = base;
    }
    
    override private func execute(cancellationToken: TaskCancellationToken) throws -> TResult {
        return try self.base.execute(cancellationToken);
    }
    override private var shouldExecuteSynchronously: Bool {
        return self.base.shouldExecuteSynchronously;
    }
}