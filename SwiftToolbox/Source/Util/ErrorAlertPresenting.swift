//
//  ErrorAlertPresenting.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/18/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation
import UIKit;


public extension UIViewController {
    public final func presentViewControllerForError(error: ErrorType, willPresent: (UIViewController) -> () = {_ in }, completion: (ErrorRecoveryOption) -> ()) {
        let recovery = error.recovery ?? ErrorRecovery.Unexpected;
        
        let controller = self.makeViewControllerForErrorRecovery(recovery) { completion($0) };
        willPresent(controller);
        
        self.presentViewController(controller, animated: true) {
            
        };
    }
    
    public func makeViewControllerForErrorRecovery(recovery: ErrorRecovery, completion: (ErrorRecoveryOption) -> ()) -> UIViewController {
        return UIAlertController.makeForErrorRecovery(recovery) { completion($0) };
    }
}

public extension  UIAlertController {
    class public func makeForErrorRecovery(recovery: ErrorRecovery, optionHandler: (ErrorRecoveryOption) -> ()) -> UIAlertController {
        let alertStyle : UIAlertControllerStyle = .Alert;
        let alert = self.init(title: recovery.title, message: recovery.message, preferredStyle: alertStyle);
        
        var options = recovery.recoveryOptions;
        if options.count == 0 {
            options.append(ErrorRecoveryOption.Dismiss);
        }
        
        options.forEach() { (option) in
            let style : UIAlertActionStyle;
            switch option.kind {
            case .Standard:
                style = .Default;
            case .Destructive:
                style = .Destructive;
            case .Cancel:
                style = .Cancel;
            }
            let action = UIAlertAction(title: option.title, style: style) { (action) in
                DispatchQueue.Main.async() {
                    optionHandler(option);
                };
            };
            alert.addAction(action);
        };
        
        return alert;
    }
}
