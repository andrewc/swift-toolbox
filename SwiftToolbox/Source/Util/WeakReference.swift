//
//  Weakable.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/16/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

public struct WeakReference<ValueType: AnyObject> {
    private var strongRef : ValueType? = nil;
    private weak var weakRef : ValueType? = nil;
    
    private init(value: ValueType, weaklyReference: Bool) {
        if weaklyReference {
            weakRef = value;
        } else {
            strongRef = value;
        }
    }
    
    public var value : ValueType? {
        if let strong = self.strongRef {
            return strong;
        }
        
        if let weak = self.weakRef {
            return weak;
        }
        
        return nil;
    }
    
    public var isValueAvailable : Bool {
        return self.value != nil;
    }
    
    public static func takeStrongReference(value: ValueType) -> WeakReference<ValueType> {
        return WeakReference<ValueType>(value: value, weaklyReference: false);
    }
    public static func takeWeakReference(value: ValueType) -> WeakReference<ValueType> {
        return WeakReference<ValueType>(value: value, weaklyReference: true);
    }
}