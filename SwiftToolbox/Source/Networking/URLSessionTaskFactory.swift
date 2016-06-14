//
//  URLSessionTaskFactory.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/13/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

public extension NSURLSession {
    public func start(request: NSURLRequest) -> Task<(NSURLResponse, NSData)> {
        return TaskFactory.Default.start { (cancelToken) in
            let continueAsync = TaskKernelAsynchronousCompletion<(NSURLResponse, NSData)>();
            
            let urlTask = self.dataTaskWithRequest(request) { (data, response, error) in
                if let error = error {
                    continueAsync.result = .Faulted(error);
                    return;
                }
                
                continueAsync.result = .Completed((response!, data!));
            };
            
            urlTask.resume();
            
            throw continueAsync;
        };
    }
}