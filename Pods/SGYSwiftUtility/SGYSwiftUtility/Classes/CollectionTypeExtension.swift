//
//  CollectionTypeExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation

extension Sequence {
    
    /**
     Returns an array of values that could be cast to `T`.
     - returns: An array of values that could be cast to `T`.
     */
    public func cast<T>() -> [T] {
        return filter({ $0 is T }).map { $0 as! T }
    }
}

extension Set {
    
    /**
     Returns a `Set` of values that could be cast to `T`.
     - returns: A `Set` of values that could be cast to `T`.
     */
    public func cast<T>() -> Set<T> {
        return Set<T>(filter({ $0 is T }).map { $0 as! T })
    }
}
