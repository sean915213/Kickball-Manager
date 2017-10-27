//
//  CollectionTypeExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation

extension Array {
    
    /**
     Returns an array of values that could be cast to `T`.
     - returns: An array of values that could be cast to `T`.
     */
    public func typeOf<T>() -> [T] {
        return filter({ $0 is T }).map { $0 as! T }
    }
}

extension Set {
    
    /**
     Provides an implementation of `SequenceType`'s `map` for Swift's `Set`.
     
     - parameter transform: A function that transform's each of `Set`'s `Element` to the provided type `T`.
     
     - throws: Rethrows any errors encountered executing `transform`.
     
     - returns: A new `Set` with values mapped using `transform`.
     */
    public func map<T: Hashable>(transform: (Element) throws -> T) rethrows -> Set<T> {
        var mappedSet = Set<T>()
        for obj in self { mappedSet.insert(try transform(obj)) }
        return mappedSet
    }
    
    /**
     Returns a `Set` of values that could be cast to `T`.
     - returns: A `Set` of values that could be cast to `T`.
     */
    public func typeOf<T>() -> Set<T> {
        return Set<T>(filter({ $0 is T }).map { $0 as! T })
    }
}

extension Dictionary {
    
    /**
     Merges in-place the contents of `dictionary` with this dictionary's keys and values.
     
     - parameter dictionary: A dictionary with the same `Key` and `Value` types.
     */
    public mutating func merge(otherDictionary dictionary: [Key: Value]) {
        for (k, v) in dictionary { updateValue(v, forKey: k) }
    }
}
