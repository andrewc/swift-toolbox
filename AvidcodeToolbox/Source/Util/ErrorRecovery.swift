//
//  ErrorAlertPresentationAssistant.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/16/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation
import UIKit

/** An type of error which exposes self-recovery options. */
public protocol RecoverableErrorType : ErrorType {
    /** Gets the `ErrorRecovery` object that can be leveraged to help facilitate recovery from this error. */
    var recovery : ErrorRecovery? { get }
}

public extension ErrorType {
    /**
     Attempts to create a useful error recovery instance for all errors.
 
     - remark:
     
        Tries to get a recoverable instance by:
     
        1. If `self` is of `RecoverableErrorType` and `RecoverableErrorType.recovery` is non-`nil`.InformativeErrorType
        2. If `self` is of `DebuggingErrorType`, `DebuggingErrorType.innerError.recovery` is non-`nil`.
        3. If `self` is of `InformativeErrorType` and contains both `InformativeErrorType.presentableDescription` 
            and `InformativeErrorType.presentableFailureReason`, constructs a recovery instance with that title and
            message, respectively, with a single no-op recovery option for dismissal.
        
        If all of the above fail, returns `nil`.
    */
    public var recovery : ErrorRecovery? {
        if let recoverable = self as? RecoverableErrorType, recovery = recoverable.recovery {
            return recovery;
        }
        
        if let innerRecovery = ((self as? DebuggingErrorType)?.innerError as? RecoverableErrorType)?.recovery {
            return innerRecovery;
        }
        
        if let informative = self as? InformativeErrorType, localDesc = informative.presentableDescription, localFailReason = informative.presentableFailureReason {
            return ErrorRecovery(title: localDesc, message: localFailReason, options: ErrorRecoveryOption.Dismiss);
        }
        
        return nil;
    }
}

/** Am error type which holds your recovery instance. */
public struct RecoverableError : DebuggingErrorType, RecoverableErrorType {
    public init(message: String, recovery: ErrorRecovery, innerError: ErrorType? = nil) {
        self.recovery = recovery;
        self.innerError = innerError;
        self.message = message;
    }
    
    private(set) public var message: String;
    private(set) public var recovery: ErrorRecovery?;
    private(set) public var innerError: ErrorType?;
}

/** A type which facilitates the recovery of an error. */
public final class ErrorRecovery {
    public static let Unexpected = ErrorRecovery(
        title: "Oops! Something Went Wrong",
        message: "Something unexpected happened while trying to do that. Give it another try in a few minutes."
    );
    
    private var _recoveryOptions :[ErrorRecoveryOption] = [];
    
    public init(title: String, message: String, options: ErrorRecoveryOption ...) {
        self.title = title;
        self.message = message;
        _recoveryOptions.appendContentsOf(options);
    }
    
    public let title: String;
    public let message: String;

    public var destructiveRecoveryOptions: [ErrorRecoveryOption] {
        return self.recoveryOptions.filter({ $0.kind.rawValue == ErrorRecoveryOptionKind.Destructive.rawValue});
    }
    public var recoveryOptions : [ErrorRecoveryOption] {
        return _recoveryOptions;
    }
    public func addRecoveryOption(option: ErrorRecoveryOption) {
        _recoveryOptions.append(option);
    }
    public func addRecoveryOption(title: String, description: String?, kind: ErrorRecoveryOptionKind = .Standard, _ recover: () -> Task<Void>) {
        _recoveryOptions.append(ErrorRecoveryOption(title: title, description: description, kind: kind, recover));
    }
}

public enum ErrorRecoveryOptionKind : Int {
    case Standard;
    case Cancel;
    case Destructive;
}

public struct ErrorRecoveryOption {
    public static let Dismiss = ErrorRecoveryOption(title: "Dismiss", kind: .Cancel) { Task(result: ()) };

    public init(title: String, description: String? = nil, kind: ErrorRecoveryOptionKind = .Standard, _ recover: () -> Task<Void>) {
        self.title = title;
        self.description = description;
        self.kind = kind;
        self.makeRecoveryTask = recover;
    }
    public let title: String;
    public let description: String?;
    public let kind: ErrorRecoveryOptionKind;
    public let makeRecoveryTask: () -> Task<Void>;

    public func attemptRecovery() -> Task<Void> {
        let task = makeRecoveryTask();
        task.start();
        return task;
    }
}

