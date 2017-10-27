//
//  NSUserDefaultsExtension.swift
//  Pods
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation

extension UserDefaults {
    
    /**
     Provides a method for retrieval and casting of `NSUserDefaults` values to type `T`.
     
     - parameter defaultName: The key for the object in `NSUserDefaults`.
     
     - returns: A instance of `T` retrieved from this `NSUserDefaults` instance or `nil` if no object was found or could not be cast to `T`.
     */
    public func objectForKey<T>(_ defaultName: String) -> T? {
        return object(forKey: defaultName) as? T
    }
}
