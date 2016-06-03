//
//  TimeInterval.swift
//  SimplyTappToolbox
//
//  Created by Andrew Christiansen on 5/18/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import CoreFoundation
import Foundation

/**
 Represnts an instant or duration of time.
 
 The smallest unit of time that can be represented is 1 nanosecond.
*/
public struct TimeInterval : CustomDebugStringConvertible, CustomStringConvertible, Hashable, FloatLiteralConvertible {
    public static let Zero = TimeInterval(microseconds: 0);
    public static let DistantFuture = TimeInterval(microseconds: Int64.max);
    public static let DistantPast = TimeInterval(microseconds: Int64.min);
    private static let Formatter = ({ () -> NSDateComponentsFormatter in
        let formatter = NSDateComponentsFormatter();
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Full;
        return formatter;
    })();
    private static let MachTimebase : mach_timebase_info_data_t     = ({ () -> mach_timebase_info_data_t     in
        var info = mach_timebase_info_data_t();
        mach_timebase_info(&info);
        return info;
    })();
    
    /**
     Gets the current time interval of the system.
     
     The time interval returned here is not related to any calendar based time.  It simply returns the time the
     instant the property was read from a clock the continuously moves forward.
    */
    public static var Now : TimeInterval {
        let abstime = mach_absolute_time();
        let nano = Int64(Double(abstime) * (Double(MachTimebase.numer) / Double(MachTimebase.denom)));
        return TimeInterval(microseconds: nano / 1000);
    }
    public init(floatLiteral value: Float64) {
        self.init(seconds: value);
    }
    public init(microseconds: Int64) {
        self.microseconds = microseconds;
    }
    public init(milliseconds: Double) {
        self.init(microseconds: Int64(milliseconds * 1000.0));
    }
    public init(seconds: Double) {
        self.init(milliseconds: Double(seconds * 1000.0));
    }
    public init(minutes: Double) {
        self.init(seconds: Double(minutes * 60));
    }
    public init(hours: Double) {
        self.init(minutes: Double(hours * 60));
    }
    
    //public let nanoseconds: Int64;

    public let microseconds : Int64;
    
    public var milliseconds : Double {
        return Double(self.microseconds) / 1000.0;
    }
    
    public var seconds : Double {
        return Double(self.milliseconds / 1000.0);
    }
    
    public var debugDescription: String {
        return "[TimeInterval: \(self.seconds)s; \(self.milliseconds)ms; \(self.microseconds)μs]"
    }
    
    public var description: String {
        return TimeInterval.Formatter.stringFromTimeInterval(self.seconds) ?? "\(self.seconds) seconds";
    }
    
    public var hashValue: Int {
        return self.microseconds.hashValue;
    }
}



public func ==(lhs: TimeInterval, rhs: TimeInterval) -> Bool {
    return (lhs.microseconds == rhs.microseconds);
}
public func >(lhs: TimeInterval, rhs: TimeInterval) -> Bool {
    return (lhs.microseconds > rhs.microseconds);
}
public func <(lhs: TimeInterval, rhs: TimeInterval) -> Bool {
    return (lhs.microseconds < rhs.microseconds);
}

public func +(lhs: TimeInterval, rhs: TimeInterval) -> TimeInterval {
    return TimeInterval(microseconds: lhs.microseconds + rhs.microseconds)
}
public func -(lhs: TimeInterval, rhs: TimeInterval) -> TimeInterval {
    return TimeInterval(microseconds: lhs.microseconds - rhs.microseconds)
}
public func /(lhs: TimeInterval, rhs: TimeInterval) -> TimeInterval {
    return TimeInterval(microseconds: lhs.microseconds  / rhs.microseconds)
}
public func *(lhs: TimeInterval, rhs: TimeInterval) -> TimeInterval {
    return TimeInterval(microseconds: lhs.microseconds * rhs.microseconds)
}