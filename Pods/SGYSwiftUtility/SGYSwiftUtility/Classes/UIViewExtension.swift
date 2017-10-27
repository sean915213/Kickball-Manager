//
//  UIViewExtension.swift
//  Pods
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation

extension UIView {
    
    /**
     Initializes a `UIView` instance and sets the provided `translatesAutoresizingMask` parameter.
     
     - parameter translatesAutoresizingMask: The value to set for the view's `translatesAutoResizingMaskIntoConstraints` property.
     
     - returns: An initialized `UIView` instance.
     */
    public convenience init(translatesAutoresizingMask: Bool) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMask
    }
    
    /**
     Adds the array of `UIView` to the view.
     
     - parameter views: An array of `UIView` instances to add to this view.
     */
    public func addSubviews(_ views: [UIView]) {
        for view in views { addSubview(view) }
    }
}
