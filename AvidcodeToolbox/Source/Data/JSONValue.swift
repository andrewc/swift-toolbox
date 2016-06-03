//
//  JSONValue.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/16/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public enum JSONValueErrors : ErrorType {
    case UnconvertibleObject(Any);
    case KeyNotFound(String);
}

prefix operator <- {}
public prefix func <- (value: String?) -> JSONValue {
    return JSONValue(value);
}
public prefix func <- (value: Int?) -> JSONValue {
    return JSONValue(value);
}
public prefix func <- (value: Double?) -> JSONValue {
    return JSONValue(value);
}
public prefix func <- (value: [JSONValue]?) -> JSONValue {
    return JSONValue(value);
}
public prefix func <- (value: [String:JSONValue]?) -> JSONValue {
    return JSONValue(value);
}
public prefix func <- (value: Bool?) -> JSONValue {
    return JSONValue(value);
}

/** Represents a JSON value. */
public indirect enum JSONValue :
    CustomStringConvertible,
    
    StringLiteralConvertible,
    IntegerLiteralConvertible,
    FloatLiteralConvertible,
    ArrayLiteralConvertible,
    DictionaryLiteralConvertible,
    BooleanLiteralConvertible,
    NilLiteralConvertible {
    
    /**
      Indicates the value is not present, or otherwise undefined.
     - note: This value is never output when serializaing.  For dictionaries, the key is excluded if its value is `Undefined`.
    */
    case Undefined;
    
    case Null;
    case Integer(Int);
    case Float(Double);
    case Boolean(Bool);
    case Text(String);
    case Dictionary([String:JSONValue]);
    case Array([JSONValue]);

    // MARK: - Initializers
    public init(_ value: String?) {
        guard let value = value else { self = .Undefined; return; }
        self = .Text(value);
    }
    public init(_ value: Int?) {
        guard let value = value else { self = .Undefined; return; }
        self = .Integer(value);
    }
    public init(_ value: Double?) {
        guard let value = value else { self = .Undefined; return; }
        self = .Float(value);
    }
    public init(_ value: Bool?) {
        guard let value = value else { self = .Undefined; return; }
        self = .Boolean(value);
    }
    public init(_ value: [String:JSONValue]?) {
        guard let value = value else { self = .Undefined; return; }
        self = .Dictionary(value);
    }
    public init(_ value: [JSONValue]?) {
        guard let value = value else { self = .Undefined; return; }
        self = .Array(value);
    }
    public init(_ value: ()?) {
        guard value == nil else { self = .Undefined; return; }
        self = .Null;
    }

    // MARK: - Value Accessors
    
    /**
     Attempts to get a value for the given key path.
     
     - returns: A value from the following:
        1. If `key` is empty, returns `self`.
        2. If `self` is a dictionary, returns the value for the key.
        3. If `self` is an array, and `key` can be converted to an integer, returns the value at that index (as long as index < count).
        4. If none of the above produce a value, `nil` is returned.
     
    */
    public subscript(key: String) -> JSONValue? {
        if key.isEmpty {
            return self;
        }
    
        func getThisKey(key: String) -> JSONValue? {
            if case let .Dictionary(dict) = self {
                return dict[key];
            }
            
            if let index = Int(key) {
                if case let .Array(array) = self {
                    if index  < array.count {
                        return array[index];
                    }
                }
            }
            
            return nil;
        };
        
        var keyComponents = key.componentsSeparatedByString(".");
        guard let value = getThisKey(keyComponents[0]) else {
            return nil;
        }
        
        keyComponents.removeFirst();
        if (keyComponents.count == 0) {
            return value;
        }
        
        return value[keyComponents.joinWithSeparator(".")];
    }
    
    /** Demands the value for the given key by throwing if not found. */
    public func value(key: String) throws -> JSONValue {
        guard let value = self[key] else {
            throw JSONValueErrors.KeyNotFound(key);
        }
        
        
        return value;
    }
    /** Gets the array representation of this value. If not an array,
        returns an array with a single item. */
    public var arrayValue: [JSONValue] {
        if case let .Array(value) = self {
            return value;
        }
        
        return [self];
    }
    /** If this is a dictionary, returns its contents, otherwise `nil`. */
    public var dictionaryValue: [String:JSONValue]? {
        if case let .Dictionary(value) = self {
            return value;
        }
        
        return nil;
    }
    /** Gets the float representation of this value, or `nil` if not
        an integer, float, or parsable text. */
    public var floatValue : Double? {
        if case let .Float(value) = self {
            return value;
        }
        if case let .Integer(value) = self {
            return Double(value);
        }
        if let text = self.textValue {
            return Double(text);
        }
        return nil;
    }
    /** Gets the integer representation of this value, or `nil` if not
        an integer, float, or parsable text. */
    public var integerValue : Int? {
        if case let .Integer(value) = self {
            return value;
        }
        if let text = self.textValue {
            return Int(text);
        }
        return nil;
    }
    /** Gets the boolean representation of this value, or `nil` if not
     a boolean, integer > 0, or text starting with `t' or `y` (true). */
    public var boolValue: Bool? {
        
        if case let .Boolean(value) = self {
            return value;
        }
        if let int = self.integerValue {
            return int > 0;
        }
        if var value = self.textValue {
            value = value.lowercaseString;
            return (value.hasPrefix("t") || value.hasPrefix("y") || value.hasPrefix("1"));
        }
        
        return nil;
    }
    /** Gets the string representation of this value, or `nil` if the
        value is `.Null`. */
    public var textValue : String? {
        switch self {
        case let .Text(value):
            return value;
        case let .Integer(value):
            return String(value);
        case let .Float(value):
            return String(value);
        case let .Boolean(value):
            return (value ? "true" : "false");
        default:
            return nil;
        }
    }
    
    public var description : String {
        return self.JSON();
    }
    
    // MARK: - Serialization
    
    public func JSON() -> String {
        let serialized = self.serialize();
        return String(UTF8String: UnsafePointer<CChar>(serialized.bytes))!;
    }
    public func serialize() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(self.toSerializableObject()!, options: NSJSONWritingOptions.PrettyPrinted)
        
    }
    
    private func toSerializableObject() -> AnyObject? {
        switch self {
        case .Null:
            return NSNull();
        case .Undefined:
            return nil;
        case let .Integer(value):
            return NSNumber(integer: value);
        case let .Float(value):
            return NSNumber(double: value);
        case let .Boolean(value):
            return value ? kCFBooleanTrue : kCFBooleanFalse;
        case let .Text(value):
            return value as NSString;
        case let .Dictionary(dict):
            let nsdict = NSMutableDictionary();
            for (k, v) in dict {
                if let v = v.toSerializableObject() {
                    nsdict[k] = v;
                }
            }
            return nsdict;
        case let .Array(value):
            let array = NSMutableArray();
            for v in value {
                if let v = v.toSerializableObject() {
                    array.addObject(v);
                }
            }
            return array;
        }
    }
    public func toAny(valueForNull nullValue: Any? = nil, valueForUndefined undefinedValue: Any? = nil) -> Any? {
        switch self {
        case .Null:
            return nullValue;
        case .Undefined:
            return undefinedValue;
        case let .Integer(value):
            return value;
        case let .Float(value):
            return Float64(value);
        case let .Boolean(value):
            return value;
        case let .Text(value):
            return value;
        case let .Dictionary(dict):
            var nsdict : [String:Any] = [:];
            for (k, v) in dict {
                if let v = v.toAny(valueForNull: nullValue, valueForUndefined: undefinedValue) {
                    nsdict[k] = v;
                }
            }
            return nsdict;
        case let .Array(value):
            var array : [Any] = [];
            for v in value {
                if let v = v.toAny(valueForNull: nullValue, valueForUndefined: undefinedValue) {
                    array.append(v);
                }
            }
            return array;
        }
    }
    
    // MARK: - Deserialization
    public static func fromData(data: NSData) throws -> JSONValue {
        return try JSONValue.fromAny(try NSJSONSerialization.JSONObjectWithData(data, options: []));
    }
    public static func fromAny(value: Any?) throws -> JSONValue {
        if value == nil {
            return .Null;
        }
        
        if let already = value as? JSONValue {
            return already;
        }
        if let value = value as? String {
            return .Text(value);
        }
        if let value = value as? Int {
            return .Integer(value);
        }
        if let value = value as? Double {
            return .Float(value);
        }
        if let value = value as? Float32 {
            return .Float(Double(value));
        }
        if let value = value as? Bool {
            return .Boolean(value);
        }
        if let value = value as? NSDictionary {
            var object : [String: JSONValue] = [:];
            for (key, anyValue) in value {
                let jsonValue = try JSONValue.fromAny(anyValue);
                object[key as! String] = jsonValue;
            }
            
            return .Dictionary(object);
        }
        if let value = value as? [String:Any] {
            var object : [String: JSONValue] = [:];
            for (key, anyValue) in value {
                let jsonValue = try JSONValue.fromAny(anyValue);
                object[key as String] = jsonValue;
            }
            
            return .Dictionary(object);
        }
        
        if let value = value as? [Any] {
            var array : [JSONValue] = [];
            for anyValue in value {
                let jsonValue = try JSONValue.fromAny(anyValue);
                array.append(jsonValue);
            }
            
            return .Array(array);
        }
        
        throw JSONValueErrors.UnconvertibleObject(value);
    }
    
    // MARK: - *LiteralConvertible
    public init(stringLiteral value: String) {
        self = .Text(value);
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .Text(value);
    }
    public init(unicodeScalarLiteral value: String) {
        self = .Text(value);

    }
    public init(integerLiteral value: Int) {
        self = .Integer(value);
    }
    public init(floatLiteral value: Double) {
        self = .Float(value);
    }
    
    public init(arrayLiteral elements: JSONValue...) {
        self = .Array(elements);
    }
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        var items : [String:JSONValue] = [:];
        for (k, v) in elements {
            items[k] = v;
        }
        self = .Dictionary(items);
    }
    public init(booleanLiteral value: Bool) {
        self = .Boolean(value);
    }
    public init(nilLiteral: ()) {
        self = .Null;
    }
}
