//
//  Date.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/23/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation

/**
 Represents a date.
 
 - note: Currently just wraps NSDate.
*/
public struct Date : CustomStringConvertible {
    private let value: TimeInterval;
    
    public init() {
        self.value = TimeInterval(seconds: NSDate.timeIntervalSinceReferenceDate());
    }
    public init(fromUnixTimestamp ts: TimeInterval) {
        self.value = TimeInterval(seconds: NSDate(timeIntervalSince1970: ts.seconds).timeIntervalSinceReferenceDate);
    }
    public init(fromReference ts: TimeInterval) {
        self.value = TimeInterval(seconds: NSDate(timeIntervalSinceReferenceDate: ts.seconds).timeIntervalSinceReferenceDate);
    }
    public init(_ date: NSDate) {
        self.value = TimeInterval(seconds: date.timeIntervalSinceReferenceDate);
    }
    
    public var timeElapsedSinceReference : TimeInterval {
        return self.value;
    }

    public var description: String {
        let formatter = NSDateFormatter();
        formatter.timeStyle = .FullStyle;
        formatter.dateStyle = .FullStyle;
        return formatter.stringFromDate(NSDate(self));
    }
    
    public static var Now : Date {
        return Date();
    }
}

public func -(lhs: Date, rhs: Date) -> TimeInterval {
    return lhs.timeElapsedSinceReference - rhs.timeElapsedSinceReference;
}
public func +(lhs: Date, rhs: TimeInterval) -> Date {
    return Date(fromReference: lhs.timeElapsedSinceReference + rhs);
}
public func -(lhs: Date, rhs: TimeInterval) -> Date {
    return Date(fromReference: lhs.timeElapsedSinceReference - rhs);
}

public extension NSDate {
    public convenience init(_ date: Date) {
        self.init(timeIntervalSinceReferenceDate: date.timeElapsedSinceReference.seconds);
    }
}