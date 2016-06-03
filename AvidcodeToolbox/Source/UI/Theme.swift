//
//  Theme.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/4/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation
import UIKit;

public protocol ThemeApplicator {
    func apply(animated: Bool);
}

public extension ThemeApplicator {
    public func apply() {
        self.apply(false);
    }
}

@IBDesignable
@objc public class Theme : NSObject, ThemeApplicator {
    @IBOutlet
    public var constraints: [ThemeConstraint] = [];
    
    @IBInspectable
    public var name: String?;
    
    /** The default navigation bar tint color. */
    @IBInspectable
    public var barTintColor : UIColor?;
  
    /** The default activity indicator spinner color. */
    @IBInspectable
    public var activityIndicatorColor : UIColor?;
    
    @IBInspectable
    public var imageTintColor: UIColor?;
    
    @IBOutlet
    public var theme: Theme? = nil;
    

    public lazy var appearances : [ThemeAppearance] = ({
        let navBarApplier = ThemeApplier<UINavigationBar>{ (view, animated) -> () in view.barTintColor = self.barTintColor };
        let activityApplier = ThemeApplier<UIActivityIndicatorView>{ (view, animated) -> () in view.color = self.activityIndicatorColor };
        let imageTintApplier = ThemeApplier<UIImageView>{ (view, animated) -> () in view.tintColor = self.imageTintColor };
        
        return [navBarApplier, activityApplier, imageTintApplier];
    })();
    
    public func apply(animated: Bool) {
        let useContraints = (self.constraints.count == 0 ? [ThemeConstraint()] : self.constraints);
        
        for constraint in useContraints {
            for a in self.appearances {
                a.apply(constraint, animated: animated);
            }
        }
        
        if let theme = self.theme {
            theme.apply(animated);
        }
    }
}

public protocol ThemeAppearance {
    func apply(to: ThemeConstraint, animated: Bool);
    
}
public struct ThemeApplier<TAppearance : UIAppearance> : ThemeAppearance {
    private let applier : (TAppearance, Bool) -> ();
    
    public init(_ applier: (TAppearance, Bool) ->()) {
        self.applier = applier;
    }
    public func apply(target: TAppearance, animated: Bool) {
        applier(target, animated);
    }
    public func apply(to: ThemeConstraint, animated: Bool) {
        let proxy = to.appearanceProxy(TAppearance);
        self.apply(proxy, animated: animated);
    }
}

@IBDesignable
@objc public class ThemeConstraint : NSObject {
    @IBInspectable
    public var containerClass: String?;
    
    public func appearanceProxy<UIElementType : UIAppearance>(source: UIElementType.Type) -> UIElementType {
        if let containClass = self.containerClass, objcClass = NSClassFromString(containClass) {
            return source.appearanceWhenContainedInInstancesOfClasses([objcClass]);
        }
        
        return source.appearance();
    }
}