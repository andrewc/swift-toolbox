//
//  AggregateError.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/19/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public struct AggregateError : ErrorType {
    public init(_ errors: ErrorType...) {
        self.errors = errors;
    }
    
    public let errors: [ErrorType];
}