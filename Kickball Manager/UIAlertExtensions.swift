//
//  UIAlertControllerExtension.swift
//  Kickball Manager
//
//  Created by Sean G Young on 2/1/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func display(completion: (() -> Void)? = nil) {
        // Create new window
        let newWindow = UIWindow(frame: UIScreen.main.bounds)
        // Set to alert level and unhide
        newWindow.windowLevel = UIWindowLevelAlert
        newWindow.isHidden = false
        // Create and assign view controller for presentation
        newWindow.rootViewController = UIViewController()
        // Present alert
        newWindow.rootViewController!.present(self, animated: true, completion: completion)
    }
}

extension UIAlertAction {
    
    static func cancel(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel, handler: handler)
    }
}
