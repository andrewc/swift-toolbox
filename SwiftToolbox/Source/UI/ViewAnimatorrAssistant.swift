//
//  ViewAnimatorrAssistant.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/10/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation
import UIKit

public enum ViewAnimationTimingFunction {
    case Linear;
    case EaseIn;
    case EaseOut;
    case EaseInOut;
}

public typealias ViewAnimator = () -> ();
public typealias ViewAnimationGroupCompletionHandler = () -> ();

/** Defines a protocol for building UIKit animations in a concise way. */
public protocol ViewAnimationBuilder {
    /** Sets the animation duration for subsequent animation definitions. */
    func duration(seconds: Double) -> ViewAnimationBuilder;
    /** Sets the animation delay for subsequent animation definitions. */
    func delay(seconds: Double) -> ViewAnimationBuilder;
    /** Sets the animation timing function. */
    func options(options: UIViewAnimationOptions) -> ViewAnimationBuilder;
    
    /** Adds the definition of the animation to the builder, returning another builder instance which becomes its child. */
    func add(animator: ViewAnimator) -> ViewAnimationBuilder;
    /** Signals the end of this group of animation definitions. */
    func done(handler: ViewAnimationGroupCompletionHandler) -> ViewAnimationBuilder;
    
    /** Starts the carrying the animations defined in the builder. */
    func start(completion: ViewAnimationGroupCompletionHandler);
}

public extension ViewAnimationBuilder {
    public func single(animator: ViewAnimator) -> ViewAnimationBuilder {
        return self.add(animator).done();
    }

    public func easeIn() -> ViewAnimationBuilder {
        return self.options(UIViewAnimationOptions.CurveEaseIn);
    }
    public func easeInOut() -> ViewAnimationBuilder {
        return self.options(UIViewAnimationOptions.CurveEaseInOut);
    }
    public func easeOut() -> ViewAnimationBuilder {
        return self.options(UIViewAnimationOptions.CurveEaseOut);
    }
    public func linear() -> ViewAnimationBuilder {
        return self.options(UIViewAnimationOptions.CurveLinear);
    }
    public func done() -> ViewAnimationBuilder {
        return self.done({});
    }
    public func start() {
        self.start({});
    }
}
public extension UIView  {
    public class var animationBuilder : ViewAnimationBuilder {
        get {
            return ViewAnimationBuilderImpl();
        }
    }
}

private class ViewAnimationBuilderImpl : ViewAnimationBuilder {
    private var _animator : ViewAnimator?;
    private var _children = [ViewAnimationBuilderImpl]();
    private var _doneHandler: ViewAnimationGroupCompletionHandler?;
    private var _options = AnimationBuidlerOptions();
    private weak var _parent : ViewAnimationBuilderImpl?;
    private var _strongParent : ViewAnimationBuilderImpl?;

    
    private struct AnimationBuidlerOptions {
        var duration : Double = 0.0;
        var delay: Double = 0.0;
        var options = UIViewAnimationOptions();
    }
    deinit {
    }

    func duration(seconds: Double) -> ViewAnimationBuilder {
        _options.duration = seconds;
        return self;
    }
    func delay(seconds: Double) -> ViewAnimationBuilder {
        _options.delay = seconds;
        return self;
    }
    func options(options: UIViewAnimationOptions) -> ViewAnimationBuilder {
        _options.options.unionInPlace(options);
        return self;
    }
    func add(animator: ViewAnimator) -> ViewAnimationBuilder {
        let child = ViewAnimationBuilderImpl();
        child._animator = animator;
        child._parent = self;
        child._strongParent = self;
        child._options = _options;
        _children.append(child);
        return child;
    }
    
    func done(handler: ViewAnimationGroupCompletionHandler) -> ViewAnimationBuilder {
        _doneHandler = handler;
        
        if let p = self._parent {
            return p;
        }
        
        return self;
    }
    
    func start(completion: ViewAnimationGroupCompletionHandler) {
        
        self._strongParent = self._parent;
        
        let handleCompletion : ()->() = {
            if let doneHandler = self._doneHandler {
                doneHandler();
            }
            
            var rchildren = self._children;
            var next : ViewAnimationGroupCompletionHandler!;
            
            next = {
                if (rchildren.count == 0) {
                    self._strongParent = nil;
                    next = nil;
                    completion();
                    return;
                }
                
                let child = rchildren[0];
                rchildren.removeAtIndex(0);
                child.start {
                    next();
                };
                
            };
            
            next();

        };
        
        guard let animator = self._animator else {
            handleCompletion();
            return;
        }
        
        UIView.animateWithDuration(
            _options.duration,
            delay: _options.delay,
            options: _options.options,
            animations: {
                animator();
            },
            completion: { (completed) in
                handleCompletion();
            }
        );
    }
    func animate(first: Bool, inout remainingChildren: [ViewAnimationBuilderImpl]) {

    }
}