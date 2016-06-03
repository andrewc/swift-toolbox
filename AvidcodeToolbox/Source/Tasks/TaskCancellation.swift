//
//  TaskCancellation.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/10/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public struct TaskCancelled : ErrorType {
    public let token: TaskCancellationToken;
    
    public init(_ token: TaskCancellationToken = TaskCancellationToken.None) {
        self.token = token;
    }
}


public class TaskCancellationSource {
    private var _cancelled : Bool = false;
    
    public var token : TaskCancellationToken {
        get {
            return TaskCancellationToken(source: self);
        }
    }
    
    public func cancel() {
        _cancelled = true;
    }
}

public struct TaskCancellationToken : Hashable {
    public static let None = TaskCancellationToken();
    
    var _source : TaskCancellationSource?;
    
    private init() {}
    private init(source: TaskCancellationSource) {
        _source = source;
    }
    
    public var cancellationRequested: Bool {
        get {
            guard let source = _source else {
                return false;
            }
            return source._cancelled;
        }
    }
    public func checkpoint() throws {
        if (self.cancellationRequested) {
            throw TaskCancelled(self);
        }
    }
    
    public var hashValue: Int {
        get {
            guard let source = _source else {
                return 0;
            }
            return ObjectIdentifier(source).hashValue;
        }
    }
}
public func ==(lhs: TaskCancellationToken, rhs: TaskCancellationToken) -> Bool {
    guard let lhss = lhs._source, rhss = rhs._source else {
        return false;
    }
    
    return ObjectIdentifier(lhss) == ObjectIdentifier(rhss);
}
