//
//  ResourceDecoder.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/13/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

public enum ResourceDecoderErrors : ErrorType {
    case UnableToConvertToRequestType;
}

public struct ContentType : CustomStringConvertible, Hashable {
    public init?(_ string: String) {
        var splitslash = string.componentsSeparatedByString("/");
        guard splitslash.count == 2 else {
            return nil;
        }
        
        let c = splitslash[0];
        let fs = splitslash[1];
        
        var sp = fs.componentsSeparatedByString("+");
        let f = sp[0];
        let s :String? = sp.count == 2 ? sp[1] : nil;
        
        self.init(c,  f == "*" ? nil : f,  s);
    }
    public init(_ `class`: String, _ format: String?, _ subtype: String? = nil) {
        self.`class` = `class`;
        self.format = format;
        self.subtype = subtype;
    }
    public let `class`: String;
    public let format: String?;
    public let subtype: String?;
    
    public var description: String {
        return "\(self.`class`)/\(self.format ?? "*")\(self.subtype != nil ? "+\(self.subtype!)" : "")";
    }
    
    public func isKindOfType(type: ContentType) -> Bool {
        guard self.`class` == type.`class` else {
            return false;
        }
        
        if self.format == nil || self.format == type.format {
            guard self.subtype == type.subtype else {
                return false;
            }
            
            return true;
        }

        return false;
    }
    
    public var hashValue: Int {
        return self.description.hashValue;
    }
}
public func ==(lhs: ContentType, rhs: ContentType) -> Bool {
    return (lhs.`class` == rhs.`class` && lhs.format == rhs.format && lhs.subtype == rhs.subtype);
}
public protocol ResourceDecoder {
    func canDecode(contentType: ContentType, intoType: AnyObject.Type) -> Bool;
    func decode<DecodedType>(data: [UInt8], contentType: ContentType) -> Task<DecodedType>;
}