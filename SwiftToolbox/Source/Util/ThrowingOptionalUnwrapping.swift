//
//  ThrowingOptionalUnwrapping.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/20/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation
//
public struct OptionalEmptyError : DebuggingErrorType {
    public init(_ message: String) {
        self.message = message;
    }
    
    private(set) public var message: String;
}

postfix operator ^ {}
public postfix func ^<Wrapped>(value: Optional<Wrapped>) throws -> Wrapped {
    return try value.unwrap();
}

public extension Optional {
    
    public func unwrap() throws -> Wrapped {
        if case let .Some(value) = self {
            return value;
        }
        
         throw OptionalEmptyError("The optional \(String(self.dynamicType)) cannot be unwrapped because it contains no value.");
    }
}
//
//
//postfix operator .!.. {
//
//}
///** Force unwraps an optional value, throwing an error rather than a runtime error if no value. */
//public postfix func .!..<Wrapped>(_ optional: Optional<Wrapped>) throws -> Wrapped {
//    if case let .Some(value) = optional {
//        return value;
//    }
//    
//    throw OptionalEmptyError("The optional \(String(optional.dynamicType)) cannot be unwrapped because it contains no value.");
//}
