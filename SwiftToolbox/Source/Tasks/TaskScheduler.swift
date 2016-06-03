//
//  TaskScheduler.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/12/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public enum TaskKernelPhase<TResult> {
    case Scheduled;
    case Started;
    case Completed(TResult);
    case Failed(ErrorType);
}
public protocol TaskScheduler {
    func  schedule<TResult>(task: Task<TResult>, observer: (TaskKernelPhase<TResult>) -> ());
}

public enum TaskSchedulers {
    public static var Main : TaskScheduler = DispatchTaskScheduler(DispatchQueue.Main);
    /** Gets or sets the default `TaskScheduler`.  This default value is a dispatch task scheduler using a global queue. */
    public static var Default : TaskScheduler = DispatchTaskScheduler(DispatchQueue.Global);
    /** Gets the task scheduler responsible for the code that is executing. */
    public static var Current : TaskScheduler {
        // TODO: Returning DispatchTaskScheduler from DispatchQueue.Current for now will be okay, but need to implement thread-local storage to store the actual TaskScheduler instance.
        return DispatchTaskScheduler(DispatchQueue.Current ?? DispatchQueue.Global);
    }
    public static let Synchronous : TaskScheduler = SyncTaskScheduler();
}

private final class SyncTaskScheduler : TaskScheduler {
    
    func schedule<TResult>(task: Task<TResult>, observer: (TaskKernelPhase<TResult>) -> ()) {
        observer(TaskKernelPhase<TResult>.Scheduled);
        observer(TaskKernelPhase<TResult>.Started);
        
        do {
            let result = try task.kernel.execute(task.cancellationToken);
            observer(TaskKernelPhase<TResult>.Completed(result))
        } catch {
            observer(TaskKernelPhase<TResult>.Failed(error));
        }
    }
    
}
private final class DispatchTaskScheduler : TaskScheduler {
    private let _queue : DispatchQueue;
    
    init(_ queue: DispatchQueue) {
        _queue = queue;
    }
    
    func schedule<TResult>(task: Task<TResult>, observer: (TaskKernelPhase<TResult>) -> ()) {
        observer(.Scheduled);
        
        _queue.async {
            do {
                observer(.Started);
                let value = try task.kernel.execute(task.cancellationToken);
                observer(.Completed(value));
            } catch {
                observer(.Failed(error));
            }
        };
        
    }
    
}