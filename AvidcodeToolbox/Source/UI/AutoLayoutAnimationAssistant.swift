//
//  AutoLayoutAnimationAssistant.swift
//  Gane
//
//  Created by Andrew Christiansen on 5/10/16.
//  Copyright © 2016 SimplyTapp. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
@objc public class AutoLayoutAnimationAssistant : NSObject {    
    /** A collection of constraints that need to be activated to produce the animation. */
    @IBOutlet public var activateConstraints : [NSLayoutConstraint]!;
    /** A collection of constraints that need to be deactived to procude the animation. */
    @IBOutlet public var deactivateConstraints : [NSLayoutConstraint]!;

    @IBInspectable public var duration : Double = 0.5;
    @IBInspectable public var delay : Double = 0.0;

    public var options = UIViewAnimationOptions();
    
    public func reset(viewController: UIViewController) {
        NSLayoutConstraint.deactivateConstraints(self.activateConstraints);
        NSLayoutConstraint.activateConstraints(self.deactivateConstraints);

        if viewController.isViewLoaded() {
            viewController.view.setNeedsLayout();
        }
    }
    public func animate(viewController: UIViewController, completion: () -> ()) {
        NSLayoutConstraint.deactivateConstraints(self.deactivateConstraints);
        NSLayoutConstraint.activateConstraints(self.activateConstraints);

        guard viewController.isViewLoaded() else {
            return;
        }
        
        UIView.animationBuilder
            .delay(self.delay)
            .duration(self.duration)
            .options(self.options)
            .single({
                viewController.view.setNeedsLayout();
                viewController.view.layoutIfNeeded();
            })
            .start({
                completion();
            });

    }
}