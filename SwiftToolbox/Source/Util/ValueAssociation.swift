////
////  ValueAssociation.swift
////  SwiftToolbox
////
////  Created by Andrew Christiansen on 5/16/16.
////  Copyright © 2016 Avidcode. All rights reserved.
////
//
//import Foundation
//
//public struct ValueAssociationOptions : OptionSetType {
//    public let rawValue : UInt;
//    
//    public init(rawValue: UInt) {
//        self.rawValue = rawValue;
//    }
//
//    public static let Default = ValueAssociationOptions(rawValue: 0);
//    public static let WeakReference = ValueAssociationOptions(rawValue: 2);
//
//}
//
//
//public protocol ValueAssociating {
//    func associateValue(value: AnyObject, forKey: String, options: ValueAssociationOptions);
//    func associatedValueForKey<ResultType : AnyObject>(key: String) -> ResultType?;
//    func removeAssociationForKey(key: String) -> Bool;
//}
//
//extension ValueAssociating where Self: AnyObject {
//    private var associationContainer : ValueAssociating {
//        return ValueAssociation.valueAssociations(self);
//    }
//    
//    public func associateValue(value: AnyObject, forKey key: String, options: ValueAssociationOptions) {
//        self.associationContainer.associateValue(value, forKey: key, options: options);
//    }
//    public func  associatedValueForKey<ResultType>(key: String) -> ResultType? {
//        return self.associationContainer.associatedValueForKey(key);
//    }
//    public  func removeAssociationForKey(key: String) -> Bool {
//        return self.associationContainer.removeAssociationForKey(key);
//    }
//}
//
//private final class ValueAssociation : ValueAssociating {
//    private static let AssocationSyncQueue = DispatchQueue.create(DispatchQueueKind.Serial);
//    private static var ValueAssociations : [ObjectIdentifier:ValueAssociation] = [:];
//    
//    private weak var attachedTo : AnyObject?;
//    private var values : [String:WeakReference<AnyObject>] = [:];
//    private let syncQueue = DispatchQueue.create(DispatchQueueKind.Serial);
//    
//    private init(value: AnyObject) {
//        attachedTo = value;
//    }
//    
//    public static func valueAssociations(forObject: AnyObject) -> ValueAssociating {
//        var associtation : ValueAssociation? = nil;
//        
//        AssocationSyncQueue.safeSync() {
//            if let obj = ValueAssociations[ObjectIdentifier(forObject)] {
//                associtation = obj;
//                return;
//            }
//            
//            let newObj = ValueAssociation(value: forObject);
//            ValueAssociations[ObjectIdentifier(forObject)] = newObj;
//            
//            associtation = newObj;
//        };
//        
//        return associtation!;
//    }
//    
//    func associatedValueForKey<ResultType: AnyObject>(key: String) -> ResultType? {
//        var value: WeakReference<AnyObject>? = nil;
//        
//        syncQueue.safeSync() {
//            value = self.values[key];
//        };
//        
//        guard let availValue = value else {
//            return nil;
//        }
//        
//        guard let any = availValue.value else {
//            syncQueue.safeSync() {
//                self.values.removeValueForKey(key);
//            };
//            return nil;
//        }
//        
//        return any as? ResultType;
//    }
//    
//    private func removeAssociationForKey(key: String) -> Bool {
//        syncQueue.safeSync {
//            self.values.removeValueForKey(key);
//        };
//        
//        return false;
//    }
//    private func associateValue(value: AnyObject, forKey key: String, options: ValueAssociationOptions) {
//        let ref : WeakReference<AnyObject>;
//        
//        if options.contains(ValueAssociationOptions.WeakReference) {
//            ref = WeakReference<AnyObject>.takeWeakReference(value);
//        } else {
//            ref = WeakReference<AnyObject>.takeStrongReference(value);
//        }
//        
//        syncQueue.safeSync {
//            self.values[key] = ref;
//        };
//    }
//}