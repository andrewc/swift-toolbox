////
////  MappingModel.swift
////  SimplyTappToolbox
////
////  Created by Andrew Christiansen on 5/17/16.
////  Copyright © 2016 SimplyTapp. All rights reserved.
////
//
//import Foundation
//
//public enum MappingModelErrors : ErrorType {
//    case MappingToTargetUnreachable;
//}
//
//
//public struct Mapping<SourceType, TargetType> {
//    private let transformer: AnyMappingTransformer<SourceType, TargetType>;
//    
//    public init(_ transformer: AnyMappingTransformer<SourceType, TargetType>){
//        self.transformer = transformer;
//    }
//    
//    public func map(source: SourceType) throws -> TargetType {
//        return try self.transformer.transform(source);
//    }
//}
///** Defines an interface for objects which can transform a value from one type to another (and optionally back again). */
//public protocol MappingTransformer {
//    associatedtype SourceType;
//    associatedtype TargetType;
//    
//    /** Transforms the given source value to the target type. */
//    func transform(source: SourceType) throws -> TargetType;
//    
//    /**
//     Transforms the value in the reverse direction.
//     - attention: Reverse transformation is not a requirement, so check for `nil` before attempting to reverse transform..
//     */
//    var reverseTransform : Optional<(source: TargetType) throws -> SourceType> { get }
//}
//
//infix operator >> {
//    associativity left
//}
//public func >> <SourceType, TargetType>(lhs: AnyMapBinding<SourceType>, rhs: AnyMappingTransformer<SourceType, TargetType>) -> AnyMapBinding<TargetType> {
//    let tmb = TransformedMapBinding(binding: lhs, transformer: rhs);
//    return AnyMapBinding(tmb);
//}
//
//
///** Defines an interface for an object which can bind (and optionally unbind) values to or from an object. */
//public protocol MapBinding {
//    associatedtype ValueType;
//
//    /** Binds a value by retreiving it from the source. */
//    func bind() throws -> ValueType;
//    
//    /**
//     Unbinds a value by applying it back to the source.
//     - attention: Unbinding a value is not a requirement, so check for `nil` before attempting to unbind.
//    */
//    var unbind : AnyMapBinding<ValueType>.Unbinder? { get }
//}
//
//public enum MapTransformers {
//    public static func cast<SourceType, TargetType>() -> AnyMappingTransformer<SourceType, TargetType?> {
//        return MapTransformers.make {
//            if let casted = $0 as? TargetType {
//                return casted;
//            }
//            
//            return nil;
//        } as AnyMappingTransformer<SourceType, TargetType?>;
//    }
//    public static func cast<SourceType, TargetType>(uncastableDefault: (SourceType) throws -> TargetType) -> AnyMappingTransformer<SourceType, TargetType> {
//        let transformer : AnyMappingTransformer<SourceType, TargetType> = MapTransformers.make {
//            if let casted = $0 as? TargetType {
//                return casted;
//            }
//            
//            return try uncastableDefault($0);
//        };
//        return transformer;
//    }
//    public static func make<SourceType, TargetType>(transformer: (SourceType) throws -> TargetType) -> AnyMappingTransformer<SourceType, TargetType> {
//        return AnyMappingTransformer(ClosureTransformer(forward: transformer));
//    }
//}
//public enum MapBindings {
//    public static func key<SourceType, ValueType>(key: String, _ source: () -> SourceType, _ retreiver: (SourceType) -> (String) -> ValueType) -> AnyMapBinding<ValueType> {
//
//          return MapBindings.make({ () -> SourceType in return source() }, { (s) -> ValueType in return  retreiver(s)(key); });
//    }
//    /** Binds using closures. */
//    public static func make<SourceType, ValueType>(source: () -> SourceType, _ getter: (SourceType) throws -> ValueType, _ setter: Optional<(SourceType, ValueType) throws -> ()>= nil) -> AnyMapBinding<ValueType> {
//        return AnyMapBinding(ClosureMapBinding<SourceType, ValueType>(source: source, getter: getter, setter: setter));
//    }
//
//}
//
//public extension AnyMappingTransformer {
//    public func makeReversable(transformer: (TargetType) throws -> SourceType) -> AnyMappingTransformer<SourceType, TargetType> {
//        return AnyMappingTransformer(ReverseTransformer<SourceType, TargetType>(base: self, reverse: transformer));
//    }
//}
//
//// MARK: - Map Bindings
//private struct ReverseTransformer<S, T> : MappingTransformer {
//    let base : AnyMappingTransformer<S, T>;
//    let reverse: (T) throws -> S;
//    
//    private func transform(source: S) throws -> T {
//        return try base.transform(source);
//    }
//    private var reverseTransform: Optional<(source: T) throws -> S> {
//        return reverse;
//    }
//}
//private struct ClosureTransformer<S, T> : MappingTransformer {
//    let forward: (S) throws -> T;
//    
//    private func transform(source: S) throws -> T {
//        return try forward(source);
//    }
//    
//    private var reverseTransform: Optional<(source: T) throws -> S> {
//        return nil;
//    }
//    
//    
//}
//private struct TransformedMapBinding<SourceValueType, TargetValueType> : MapBinding {
//    let binding: AnyMapBinding<SourceValueType>;
//    let transformer: AnyMappingTransformer<SourceValueType, TargetValueType>;
//    
//    private func bind() throws -> TargetValueType {
//        let bound = try binding.bind();
//        let transformed = try transformer.transform(bound);
//        return transformed;
//    }
//    private var unbind: AnyMapBinding<TargetValueType>.Unbinder? {
//        guard let unbinder = binding.unbind, reverseTransformer = transformer.reverseTransform else {
//            return nil;
//        }
//        
//        
//        return { (value) throws -> () in
//            let transformed = try reverseTransformer(source: value);
//            try unbinder(value: transformed);
//        };
//    }
//}
//
//
//private struct ClosureMapBinding<SourceType, ValueType> : MapBinding {
//    let source : () -> SourceType;
//     let getter:  (SourceType) throws -> ValueType;
//    let setter: Optional<(SourceType, ValueType) throws -> ()>;
//
//    private func bind() throws -> ValueType {
//        return try getter(source());
//    }
//    private var unbind: AnyMapBinding<ValueType>.Unbinder? {
//        guard let setter = self.setter else {
//            return nil;
//        }
//        
//        return { (value) throws -> () in
//            try setter(self.source(), value);
//        };
//    }
//}
//
//// MARK - Type Erased Map Transformer
//public final class AnyMappingTransformer<SourceType, TargetType> : MappingTransformer {
//
//    private let box : _AnyMappingTransformerBase<SourceType, TargetType>;
//    
//    public init<MappingTransformerType: MappingTransformer where MappingTransformerType.SourceType == SourceType, MappingTransformerType.TargetType == TargetType>(_ base: MappingTransformerType) {
//        box = _AnyMappingTransformer(base);
//    }
//
//    public func transform(source: SourceType) throws -> TargetType {
//        return try self.box.transform(source);
//    }
//    public var reverseTransform: Optional<(source: TargetType) throws -> SourceType> {
//        return self.box.reverseTransform;
//    }
//}
//
//private class _AnyMappingTransformerBase<TSourceType, TTargetType> : MappingTransformer {
//
//    private func transform(source: TSourceType) throws -> TTargetType {
//        fatalError()
//    }
//    private var reverseTransform: Optional<(source: TTargetType) throws -> TSourceType> {
//        fatalError()
//    }
//}
//private class _AnyMappingTransformer<TMappingTransformer : MappingTransformer> : _AnyMappingTransformerBase<TMappingTransformer.SourceType, TMappingTransformer.TargetType> {
//    typealias TSourceType  = TMappingTransformer.SourceType;
//    typealias TTargetType = TMappingTransformer.TargetType;
//    
//    private let base : TMappingTransformer;
//    
//    init(_ base: TMappingTransformer) {
//        self.base = base;
//    }
//    
//    private override func transform(source: TSourceType) throws -> TTargetType {
//        return try self.base.transform(source);
//    }
//    private override var reverseTransform: Optional<(source: TTargetType) throws -> TSourceType> {
//        return self.base.reverseTransform;
//    }
//}
//
//// MARK: - Type Erased Map Binding
//public final class AnyMapBinding<ValueType> : MapBinding {
//    public typealias Unbinder = (value: ValueType) throws -> ();
//
//    private let box : _AnyMapBindingBase<ValueType>;
//    
//    public init<MapBindingType: MapBinding where MapBindingType.ValueType == ValueType>(_ base: MapBindingType) {
//        box = _AnyMapBinding(base);
//    }
//
//    public func bind() throws -> ValueType {
//        return try box.bind();
//    }
//
//    public var unbind : AnyMapBinding<ValueType>.Unbinder? {
//        return box.unbind;
//    }
//
//}
//private class _AnyMapBindingBase<TValueType> : MapBinding {
//    private func bind() throws -> TValueType {
//        fatalError();
//    }
//
//    private var unbind : AnyMapBinding<TValueType>.Unbinder? {
//        fatalError();
//    }
//}
//private class _AnyMapBinding<TMapBinding : MapBinding> : _AnyMapBindingBase<TMapBinding.ValueType> {
//    typealias TValueType  = TMapBinding.ValueType;
//    
//    private let base : TMapBinding;
//    
//    init(_ base: TMapBinding) {
//        self.base = base;
//    }
//    
//    private override func bind() throws -> TValueType {
//        return try base.bind();
//    }
//    private override var unbind : AnyMapBinding<TValueType>.Unbinder? {
//        return base.unbind;
//    }
//}
//
////public class MappingBuilder<SourceType, TargetType> {
////    private var mappings: [MappingBuilder<SourceType, TargetType>] = [];
////    private var mapping: Mapping? = nil;
////    
////    public init() {
////        
////    }
////    private init(mapping: Mapping) {
////        self.mapping = mapping;
////    }
////    
////    public func take<TakenValueType>(taker: (SourceType) throws -> TakenValueType?) -> MappingBuilder<SourceType, TargetType> {
////        let m = MappingBuilder<SourceType, TargetType>(mapping: TakeValueMapping<SourceType, TakenValueType>() { (source) in
////            return try taker(source);
////        });
////        self.mappings.append(m);
////        return self;
////    }
////    
////    public func compile(mapper: (SourceType) throws -> TargetType) -> (SourceType) throws -> TargetType {
////        return { (source) in
////            var current : Any? = source;
////            for m in self.mappings {
////                guard let mm = m.mapping else {
////                    continue;
////                }
////                guard let mappedValue = try mm.map(current!) else {
////                    break;
////                }
////                current = mappedValue;
////            }
////            
////            if current == nil {
////                throw MappingModelErrors.MappingToTargetUnreachable;
////            }
////            
////            guard let final = current as? TargetType else {
////                throw MappingModelErrors.MappingToTargetUnreachable;
////            }
////            
////            return final;
////        };
////        
////    }
////}
////
////private final class TakeValueMapping<SourceType, ValueType> : Mapping {
////    typealias Getter = (SourceType) throws -> ValueType?;
////
////    private let getter: Getter;
////    
////    init(_ getter: Getter) {
////        self.getter = getter;
////    }
////    private func map(source: Any) throws -> Any? {
////        return try self.getter(self as! SourceType) as ValueType?;
////    }
////}
////private final class ClosureMapping<SourceType, ValueType, TargetType> : Mapping {
////    typealias Mapper = (ValueType) throws -> TargetType;
////    typealias Getter = (SourceType) -> ValueType;
////    
////    private let mapper : Mapper;
////    private let getter: Getter;
////    init(_ getter: Getter, _ mapper: Mapper) {
////        self.mapper = mapper;
////        self.getter = getter;
////    }
////    private func map(source: SourceType) throws -> TargetType {
////        let value = self.getter(source);
////        let mapped = try self.mapper(value);
////        return mapped;
////    }
////}