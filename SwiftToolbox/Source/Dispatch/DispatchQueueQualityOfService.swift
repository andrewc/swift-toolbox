//
//  DispatchQueueQualityOfService.swift
//  tiptapps
//
//  Created by Andrew Christiansen on 5/9/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

/** Contains cases for a dispatch queue's quality-of-service. */
public enum DispatchQueueQualityOfService : RawRepresentable, CustomStringConvertible {
    /** Default prority of work. */
    case Default;
    /** Low priority utility work. */
    case Utility;
    /** Medium priority background work. */
    case Background;
    /** High priority, user initiated work. */
    case UserInitiated;
    /** Utmost priority for user interaction. */
    case UserInteractive;
    
    public init?(rawValue: dispatch_qos_class_t) {
        switch rawValue {
        case QOS_CLASS_USER_INTERACTIVE:
            self = .UserInteractive;
        case QOS_CLASS_USER_INITIATED:
            self = .UserInitiated;
        case QOS_CLASS_DEFAULT:
            self = .Default;
        case QOS_CLASS_UTILITY:
            self = .Utility;
        case QOS_CLASS_BACKGROUND:
            self = .Background;
        default:
            return nil;
        }
    }
    
    public var rawValue : dispatch_qos_class_t {
        get {
            switch self {
            case .Default:
                return QOS_CLASS_DEFAULT;
            case .UserInitiated:
                return QOS_CLASS_USER_INITIATED;
            case .Utility:
                return QOS_CLASS_UTILITY;
            case .UserInteractive:
                return QOS_CLASS_USER_INTERACTIVE;
            case .Background:
                return QOS_CLASS_BACKGROUND;
            }
        }
    }
    
    public static var HighPriority : DispatchQueueQualityOfService {
        get {
            return .UserInitiated;
        }
    }
    public static var LowPriority : DispatchQueueQualityOfService {
        get {
            return .Utility;
        }
    }
    
    public var description: String {
        get {
            switch self {
            case .Default:
                return "Default";
            case .UserInitiated:
                return "User Initiated";
            case .Utility:
                return "Utility";
            case .UserInteractive:
                return "User Interactive";
            case .Background:
                return "Background";
            }
        }
    }
}
