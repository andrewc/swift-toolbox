//
//  DispatchQueueKind.swift
//  tiptapps
//
//  Created by Andrew Christiansen on 5/9/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

/** Contains cases for each type of queue. */
public enum DispatchQueueKind : RawRepresentable {
    /** The queue should run tasks concurrently. */
    case Concurrent;
    /** The queue should run task at a time, in FIFO order. */
    case Serial;
    
    public init?(rawValue: dispatch_queue_attr_t?) {
        if let _ = rawValue {
            self = .Concurrent;
        } else {
            self = .Serial;
        }
    }
    
    public var rawValue: dispatch_queue_attr_t? {
        get {
            switch (self) {
            case .Concurrent:
                return DISPATCH_QUEUE_CONCURRENT;
            case .Serial:
                return nil;
            }
        }
    }
}
