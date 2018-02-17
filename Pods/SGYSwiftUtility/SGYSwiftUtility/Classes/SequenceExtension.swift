//
//  SequenceExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation

extension Sequence {
    
    public func sorted<Value>(by keyPath: KeyPath<Element, Value>, ascending: Bool = true) -> [Element] where Value: Comparable {
        if ascending { return sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] } }
        else { return sorted { $0[keyPath: keyPath] > $1[keyPath: keyPath] } }
    }
    
    public mutating func sort<Value>(by keyPath: KeyPath<Element, Value>, ascending: Bool = true) where Value: Comparable {
        self = sorted(by: keyPath, ascending: ascending) as! Self
    }
}
