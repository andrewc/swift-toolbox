//
//  AlertPresentationUtil.swift
//  SwiftToolbox
//
//  Created by Andrew Christiansen on 5/18/16.
//  Copyright © 2016 Avidcode. All rights reserved.
//

import Foundation

//
//public extension String {
//    public func presentAsAlertMessageFromViewController(viewController: UIViewController, title: String, animated:Bool, completion: () -> ()) -> UIAlertController {
//        return self.presentAsAlertMessageFromViewController(
//            viewController,
//            title: title,
//            actions: UIAlertAction(title: "Alert.Buttons.Dismiss".localized(orDefault: "Dismiss"),
//                style: .Cancel,
//                handler: { (_) in
//                    DispatchQueue.Main.async() {
//                        completion();  
//                    };
//                }
//            )
//        );
//    }
//    public func presentAsAlertMessageFromViewController(viewController: UIViewController, animated: Bool = true, title: String, actions: UIAlertAction ...) -> UIAlertController {
//        let controller = UIAlertController(title: title, message: self, preferredStyle: .Alert);
//        actions.forEach({ controller.addAction($0) });
//        viewController.presentViewController(controller, animated: animated) {}
//        return controller;
//    }
//}