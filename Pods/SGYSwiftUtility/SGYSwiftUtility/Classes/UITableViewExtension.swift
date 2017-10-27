//
//  UITableViewExtension.swift
//  Pods
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation

extension UITableView {
    
    public func dequeueReusableCell<T: UITableViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
    
    /**
     Attempts dequeueing a registered `UITableViewHeaderFooterView` and casting to type `T` before returning.
     
     - parameter identifier: The view's registered `reuseIdentifier`.
     
     - returns: A dequeued `UITableViewHeaderFooterView` cast to `T`.  Returns `nil` if no reusable view was found in the queue.
     */
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withIdentifier identifier: String) -> T? {
        // Check view can be returned before force casting
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: identifier) else { return nil }
        // Force cast
        return (view as! T)
    }
}
