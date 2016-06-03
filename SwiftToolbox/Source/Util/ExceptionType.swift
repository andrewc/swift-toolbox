//
//  ExceptionType.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/20/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

/**
 A type which augments the throwable `ErrorType` to facilitate design patterns
 where it more suitable to throw a value regarded as an _exception_ rather than an _error_.
*/
public class Exception : ErrorType, InformativeErrorType {
    public convenience init(description: String? = nil, error: ErrorType? = nil, reason: String? = nil, suggestion: String? = nil) {
        self.init(String(self.dynamicType), error: error, description: description, reason: reason, suggestion: suggestion);
    }
    public init(_ message: String, error: ErrorType? = nil,  description: String? = nil, reason: String? = nil, suggestion: String? = nil) {
        self.message = message;
        self.innerError = error;
        self.presentableDescription = description;
        self.presentableFailureReason = reason;
        self.presentableRecoverySuggestion = suggestion;
    }
    

    private(set) public var message: String;
    private(set) public var presentableDescription: String?;
    private(set) public var presentableFailureReason: String?;
    private(set) public var presentableRecoverySuggestion: String?;
    private(set) public var innerError: ErrorType?;
}