//
//  TaskFactory.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/10/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

public class TaskFactory {
    
    public init(scheduler: TaskScheduler = TaskSchedulers.Default,
                options: TaskOptions = [],
                cancellationToken: TaskCancellationToken = .None) {
        self.scheduler = scheduler;
        self.options = options;
        self.cancellationToken = cancellationToken;
    }
    
    public let scheduler : TaskScheduler;
    public let options : TaskOptions;
    public let cancellationToken : TaskCancellationToken;

    public func make<ResultType>(kernel kernel: AnyTaskKernel<ResultType>) -> Task<ResultType> {
        let task = Task(options: self.options, cancellationToken: self.cancellationToken, kernel: kernel);
        return task;
    }
//    public final func start<ResultType>(kernel kernel: AnyTaskKernel<ResultType>) -> Task<ResultType> {
//        let task = self.make(kernel: kernel);
//        task.start();
//        return task;
//    }
//    
    /** Starts a task, allowing you to override defaults of this task factory. */
    public final func start<ResultType>(scheduler scheduler: TaskScheduler? = nil, options: TaskOptions? = nil, cancellationToken: TaskCancellationToken? = nil, _ kernel: (TaskCancellationToken) throws -> ResultType) -> Task<ResultType> {
        let task = Task<ResultType>(options: options ?? self.options, cancellationToken: cancellationToken ?? self.cancellationToken, handler: kernel);
        task.start(scheduler ?? self.scheduler);
        return task;
    }
    
    public static let Default = TaskFactory();
}

