//
//  AggregateError.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/19/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

public struct AggregateError : ErrorType {
    public init(_ errors: ErrorType...) {
        self.errors = errors;
    }
    
    public let errors: [ErrorType];
}