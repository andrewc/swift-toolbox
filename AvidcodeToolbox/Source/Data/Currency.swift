//
//  Currency.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/23/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public enum CurrencyArithmeticErrors : ErrorType {
    case MismatchingLocale;
}
public enum CurrencyStyle {
    case Standard;
    case ISO;
    case Plural;
    case Accounting;
}

/**
 A value type which holds a currency.
 
 - note: Currently just wraps into ObjC land using NSDecimalNumber.
*/
public struct Currency : Equatable, Hashable, BasicArithmeticType, CustomStringConvertible, StringLiteralConvertible {
    private var value: NSDecimalNumber!;
    private var formatter = NSNumberFormatter();
    
    public static let Zero = Currency(value: 0.0, locale: NSLocale(localeIdentifier: "en_US"));
    
    public init(stringLiteral value: String) {
        self.init(value)!;
    }
    public init(unicodeScalarLiteral value: String) {
        self.init(value)!;
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)!;
    }
    public init?(rawValue: String) {
        self.init(rawValue);
    }
    
    public init(_ value: Currency) {
        self.init(locale: value.locale);
        self.value = value.value;
        self.formatter = value.formatter;
    }
    public init(_ value: Double) {
        self.init(locale: NSLocale.currentLocale());
        self.value = NSDecimalNumber(double: value);
    }
    public init(_ value: Double, locale: NSLocale) {
        self.init(locale: locale);
        self.value = NSDecimalNumber(double: value);
    }
    public init?(_ text: String) {
        self.init(text, locale: NSLocale.currentLocale())
    }
    public init?(_ text: String, locale localeId: String) {
        self.init(text, locale: NSLocale(localeIdentifier: localeId));
    }
    public init?(_ text: String, locale: NSLocale) {
        self.init(locale: locale);
        
        guard let pv = self.formatter.numberFromString(text) as? NSDecimalNumber else {
            return nil;
        }
        
        self.value = pv;
    }
    
    private init(value: NSDecimalNumber, locale: NSLocale) {
        self.init(locale: locale);
        self.value = value;
    }
    private init(locale: NSLocale) {
        self.locale = locale;
        self.formatter.locale = locale;
        self.formatter.generatesDecimalNumbers = true;
    }
    
    public let locale: NSLocale;

    public subscript(style: CurrencyStyle) -> String {
        let formatter = self.formatter;
        formatter.numberStyle = style.toNSNumberFormatterStyle;
        
        return formatter.stringForObjectValue(self.value) ?? "?";
    }
    
    public var description: String {
        return self.value.descriptionWithLocale(self.locale);
    }
    
    public var hashValue: Int {
        return self.value.hash ^ self.locale.hash;
    }
}

public func +(lhs: Currency, rhs: Currency) throws -> Currency {
    guard lhs.locale.isEqual(rhs.locale)else {
        throw CurrencyArithmeticErrors.MismatchingLocale;
    }
    
    return Currency(value: lhs.value.decimalNumberByAdding(rhs.value), locale: lhs.locale);
}
public func -(lhs: Currency, rhs: Currency) throws -> Currency {
    guard lhs.locale.isEqual(rhs.locale)else {
        throw CurrencyArithmeticErrors.MismatchingLocale;
    }
    
    return Currency(value: lhs.value.decimalNumberBySubtracting(rhs.value), locale: lhs.locale);
}
public func *(lhs: Currency, rhs: Currency) throws -> Currency {
    guard lhs.locale.isEqual(rhs.locale)else {
        throw CurrencyArithmeticErrors.MismatchingLocale;
    }
    
    return Currency(value: lhs.value.decimalNumberByMultiplyingBy(rhs.value), locale: lhs.locale);
}
public func *(lhs: Currency, rhs: Double) throws -> Currency {
    return Currency(value: lhs.value.decimalNumberByMultiplyingBy(NSDecimalNumber(double: rhs)), locale: lhs.locale);
}
public func /(lhs: Currency, rhs: Currency) throws -> Currency {
    guard lhs.locale.isEqual(rhs.locale)else {
        throw CurrencyArithmeticErrors.MismatchingLocale;
    }
    
    return Currency(value: lhs.value.decimalNumberByDividingBy(rhs.value), locale: lhs.locale);
}

public func ==(lhs: Currency, rhs: Currency) -> Bool {
    return lhs.value.isEqualToNumber(rhs.value) && lhs.locale.isEqual(rhs.locale);
}
public func >(lhs: Currency, rhs: Currency) -> Bool {
    if case .OrderedDescending = lhs.value.compare(rhs.value) {
        return true;
    }
    return false;
}
public func <(lhs: Currency, rhs: Currency) -> Bool {
    if case .OrderedAscending = lhs.value.compare(rhs.value) {
        return true;
    }
    return false;
}




private extension CurrencyStyle {
    var toNSNumberFormatterStyle : NSNumberFormatterStyle {
        switch self {
        case .Standard:
            return NSNumberFormatterStyle.CurrencyStyle;
        case .ISO:
            return NSNumberFormatterStyle.CurrencyISOCodeStyle;
        case .Plural:
            return  NSNumberFormatterStyle.CurrencyPluralStyle;
        case .Accounting:
            return  NSNumberFormatterStyle.CurrencyAccountingStyle;
        }
    }
}
