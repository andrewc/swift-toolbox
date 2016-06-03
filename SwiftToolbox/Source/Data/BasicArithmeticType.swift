//
//  BasicArithmeticType.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/23/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

public protocol BasicArithmeticValueContainer {
    associatedtype ValueType : BasicArithmeticType;
    
    init(withArithmeticAppliedValue: ValueType, left: Self, right: Self) throws;
    
    var arithmeticValue: ValueType { get }
}

public func +<T : BasicArithmeticValueContainer>(lhs: T, rhs: T) throws -> T {
    return try T.init(withArithmeticAppliedValue: try lhs.arithmeticValue + rhs.arithmeticValue, left: lhs, right: rhs);
}
public func -<T : BasicArithmeticValueContainer>(lhs: T, rhs: T) throws -> T {
    return try T.init(withArithmeticAppliedValue: try lhs.arithmeticValue - rhs.arithmeticValue, left: lhs, right: rhs);
}
public func /<T : BasicArithmeticValueContainer>(lhs: T, rhs: T) throws -> T {
    return try T.init(withArithmeticAppliedValue: try lhs.arithmeticValue / rhs.arithmeticValue, left: lhs, right: rhs);
}
public func *<T : BasicArithmeticValueContainer>(lhs: T, rhs: T) throws -> T {
    return try T.init(withArithmeticAppliedValue: try lhs.arithmeticValue * rhs.arithmeticValue, left: lhs, right: rhs);
}



public protocol BasicArithmeticType : Equatable, Comparable {
    func +(lhs: Self, rhs: Self) throws -> Self;
    func -(lhs: Self, rhs: Self) throws -> Self;
    func /(lhs: Self, rhs: Self) throws -> Self;
    func *(lhs: Self, rhs: Self) throws -> Self;
    func *(lhs: Self, rhs: Double) throws -> Self;
}

extension Double : BasicArithmeticType {}
