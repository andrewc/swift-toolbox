//
//  InformativeErrrorType.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/19/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

/** A type of error which contains a message for developer assistance. */
public protocol DebuggingErrorType : ErrorType, CustomDebugStringConvertible {
    /**
     A message describing the exception that is useful for developers.
     - important: This message must never be presented to the user.
     */
    var message: String { get }
    
    /** Gets the underlying error, if present. */
    var innerError : ErrorType? { get }
}

/** A type of error which contains user-presentable information. */
public protocol InformativeErrorType : DebuggingErrorType {    /**
     Gets the user-presentable description of the error.
     
     In the context of an alert, this would be the **title**:\
     _Unable To Load Products_
    */
    var presentableDescription: String? { get }
    
    /**
     Gets the user-presentable reason for the error.
     
     In the context of an alert, this would be the **message**:\
     _There was a problem contacting the products service._
    */
    var presentableFailureReason: String? { get }
    
    /**
     Gets the user-presentable recovery suggestion.
     
     In the context of an alert, this could be part of the **message**:\
     _Check your internet connection and try again._
     */
    var presentableRecoverySuggestion: String? { get }
}

public extension DebuggingErrorType {
    public var message : String { return "[Exception: \(String(self.dynamicType))]"; }
    public var innerError : ErrorType? { return nil; }
    
    public var debugDescription : String {
        return self.message;
    }
}

public extension InformativeErrorType {
    public var presentableDescription: String? { return nil; }
    public var presentableFailureReason: String? { return nil; }
    public var presentableRecoverySuggestion: String? { return nil; }
}


extension String : DebuggingErrorType {
    public var message : String { return self; }
}