//
//  Task.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/10/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public enum Tasks {
    public static func delay(duration: TimeInterval) -> Task<Void> {
        let startedQueue = DispatchQueue.Current!;
        
        return TaskFactory.Default.start(scheduler: TaskSchedulers.Synchronous) { cancelToken in
            let asyncHandle = TaskKernelAsynchronousCompletion<Void>();
            startedQueue.after(duration) {
                asyncHandle.result = .Completed(());
            };
            throw asyncHandle;
        }
    }
}
/**
 Represents an asynchronous operation.
 
 - remark:
    This class is responsible for ensuring the execution of a task while providing features
    such as cancellation, maintaing state, observer subscriptions, etc.
 
    A task uses what is called a "kernel object" that actually carries out the task's work.
    This is any object adoping the `TaskKernel` protocol.
 
    A task cna have "continuation tasks" associated with it
 
*/
public final class Task<ResultType> : TaskOperation {
    private let completionEvent = WaitableEvent(initiallySignaled: false, automaticallyReset: false);
    private var continuations : [() -> ()] = [];

    public convenience init(result: ResultType) {
        self.init(options: [], cancellationToken: TaskCancellationToken.None, kernel: TaskKernels.make(withValue: result));
    }
    public convenience init
        (options: TaskOptions = [],
         cancellationToken: TaskCancellationToken = TaskCancellationToken.None,
         handler: (TaskCancellationToken) throws -> ResultType) {
        
        self.init(options: options,cancellationToken: cancellationToken, kernel: TaskKernels.make(handler));
    }
    public init(
         options: TaskOptions = [],
        cancellationToken: TaskCancellationToken = .None,
        kernel: AnyTaskKernel<ResultType>) {
        
        self.kernel = kernel;
        self.options = options;
        self.cancellationToken = cancellationToken;
    }
    
    public private(set) var status: TaskStatus = .Created;
    public let options: TaskOptions;
    public let kernel: AnyTaskKernel<ResultType>;
    public var cancellationToken: TaskCancellationToken = .None;
    public var awaiter : Waitable { return completionEvent }
    
    private func updateExecutionPhase(phase: TaskKernelPhase<ResultType>) {
        switch phase {
        case .Scheduled:
            self.status = .Scheduled;
            return;
        case .Started:
            self.status = .Running;
            return;
        case let .Completed(value):
            self.status = .Completed(value);
        case let .Failed(value as TaskCancelled) where value.token == self.cancellationToken:
            self.status = .Cancelled;
        case let .Failed(value as TaskKernelAsynchronousCompletion<ResultType>):
            value.setCompletionHandler {
                switch $0 {
                case let .Completed(value):
                    self.updateExecutionPhase(.Completed(value));
                case let .Faulted(value):
                    self.updateExecutionPhase(.Failed(value));
                }
                
                
            };
            return;
        case let .Failed(value):
            self.status = .Faulted(value);
        }
        
        
        self.completionEvent.set();
        self.dispatchContinuations();

    }
    
    public func start(scheduler: TaskScheduler = TaskSchedulers.Default) {
        guard self.status == .Created else {
            return;
        }
        
        
        scheduler.schedule(self, observer: updateExecutionPhase);
    }
    
    public func anyValue(timeout: Double = Timeout.Infinite) throws -> Any {
        return try self.value(timeout);
    }
    public func value(timeout : Double = Timeout.Infinite) throws -> ResultType {
        if !self.awaiter.wait(timeout) {
            throw WaitableTimedOut();
        }
        
        if self.status.isCancelled {
            throw TaskCancelled(self.cancellationToken);
        }
        
        let result : ResultType = try self.status.value()!;
        
        return result;
    }
    
    private func dispatchContinuations() {
        guard self.status.isFinal else {
            return;
        }
        
        let continuations = self.continuations;
        self.continuations.removeAll();

        for code in continuations {
            code();
        }
    }
}

public extension Task {
//    public static func delay(seconds: Double) -> Task<ResultType> {
//        return self.continueWith { (antecdent) in
//            let value = try antecdent.value();
//            let asyncContinue = TaskKernelMustAsynchronouslyContinue<ResultType>();
//            
//            
//            throw asyncContinue;
//        };
//    }
}

public extension Task {
    /**
     Returns a task which doesn't start until this task is completed, which then completes when the task returned from the given `continuation` closure completes.
     
    */
    public func continueFor<ContinuationResultType>(
        options options: TaskOptions = [],
        cancellationToken: TaskCancellationToken = TaskCancellationToken.None,
        scheduler: TaskScheduler = TaskSchedulers.Default,
        _ continuation: (Task<ResultType>) throws -> Task<ContinuationResultType>) -> Task<ContinuationResultType> {
        
        let ctask = self.continueWith(
                        scheduler: TaskSchedulers.Default) { (antecedent) throws -> ContinuationResultType in
                            let innerTask =  try continuation(antecedent);
                            
                            return try innerTask.value();
                        };
    
        self.addContinuationHandler() {
            ctask.start();
        }
    
        return ctask;
    }
    public func continueToMainWith<ContinuationResultType>(handler handler: (Task<ResultType>) throws -> ContinuationResultType) -> Task<ContinuationResultType> {
        
        let test =  self.continueWith(scheduler: TaskSchedulers.Main, handler);
        return test;
    }
    

    public func continueWith<ContinuationResultType>(
        scheduler scheduler: TaskScheduler = TaskSchedulers.Default,
        _ handler: (Task<ResultType>) throws -> ContinuationResultType) -> Task<ContinuationResultType> {
    
        let task = Task<ContinuationResultType>{ _ in
            return try handler(self);
        }

        self.addContinuationHandler() {
            task.start(scheduler);
        }
        
        return task;
    }
    
    private func addContinuationHandler(handler: () -> ()) {
        self.continuations.append() {
            handler();
        }
        self.dispatchContinuations();
    }
}

private protocol ContinuationState {
    mutating func start();
}
private struct TaskContinuationState<ResultType, ContinuationResultType> : ContinuationState {
    private typealias TResult = ContinuationResultType;
    
    init(sourceTask: Task<ResultType>, handler: (Task<ResultType>) -> Task<ContinuationResultType>) {
        self.sourceTask = sourceTask;
        self.continuationTaskCreator = handler;
    }
    
    let continuationTaskCreator: (Task<ResultType>) -> Task<ContinuationResultType>;
    let sourceTask: Task<ResultType>;
    var continuationTask: Task<ContinuationResultType>?;
    
    mutating func start() {
        precondition(self.continuationTask == nil, "Started more than once?");
        
        self.continuationTask = self.continuationTaskCreator(self.sourceTask);
    }
}

/** An option set defining hints and other flags to augment a task's behavior. */
public struct TaskOptions : OptionSetType {
    public let rawValue : UInt;
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue;
    }
    
    public static let Default = TaskOptions(rawValue: 0);
    
    /**
    This option hints the kernel that the thread will be running for a "long time".
 
    This option can hint a scheduler to not use a dispatch queue, thread pool, etc. for the work, and use a
    dedicated thread instead.
 
    - note: This is a hint only, the scheduler makes the decisions on how to schedule work items. */
    public static let LongRunning = TaskOptions(rawValue: 2);
    
    /** 
    This option hints the kernel to perform the work synchronously (on the
    same thred which requseted execution)

    This is useful for scenarios when you know your kernel will return immediately, and
    queing a work item for async execution would be wasteful.

    - warning: Do NOT use this option if your kernel may do any of this following:
        - Relinquish the operating system's given execution timeslice, for example:
            - Attempt to aquire a lock (maybe okay if the lock is not highly contended, but still not recommended).
            - Sleeping (duh).
            - Performing I/O.
        - Will take so long as to force the operation system to preempt the thread and context switch.
     
    - note: This is a hint only, the kernel implementation can choose to schedule your
     kernel however it can or sees fit.
    */
    public static let ShouldExecuteSynchronously = TaskOptions(rawValue: 4);
}


