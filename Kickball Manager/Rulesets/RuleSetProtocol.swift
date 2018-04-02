//
//  RuleSetProtocol.swift
//  Kickball Manager
//
//  Created by Sean G Young on 4/1/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation

struct RuleSetError: Error {
    let message: String
}

// NOTE: Type erasure pattern taken from here:
// https://www.bignerdranch.com/blog/breaking-down-type-erasures-in-swift/

protocol RuleSet {
    associatedtype TestType
    func tryApply(on collection: [TestType]) throws -> [TestType]
}

private class _AnyRuleSetBase<TestType>: RuleSet {
    init() {
        guard type(of: self) != _AnyRuleSetBase.self else {
            fatalError("_AnyRuleSetBase<Model> instances can not be created; create a subclass instance instead.")
        }
    }
    
    func tryApply(on collection: [TestType]) throws -> [TestType] {
        fatalError("Must override.")
    }
}

private final class _AnyRuleSetBox<Concrete: RuleSet>: _AnyRuleSetBase<Concrete.TestType> {
    // variable used since we're calling mutating functions
    var concrete: Concrete
    
    init(_ concrete: Concrete) {
        self.concrete = concrete
    }
    
    override func tryApply(on collection: [Concrete.TestType]) throws -> [Concrete.TestType] {
        return try concrete.tryApply(on: collection)
    }
}

final class AnyRuleSet<TestType>: RuleSet {
    private let box: _AnyRuleSetBase<TestType>
    
    // Initializer takes our concrete implementer of RuleSet
    init<Concrete: RuleSet>(_ concrete: Concrete) where Concrete.TestType == TestType {
        box = _AnyRuleSetBox(concrete)
    }
    
    func tryApply(on collection: [TestType]) throws -> [TestType] {
        return try box.tryApply(on: collection)
    }
}



class GenderRuleSet: RuleSet {
    
    func tryApply(on collection: [Player]) throws -> [Player] {
        guard collection.first(where: { $0.gender == nil }) == nil else {
            throw RuleSetError(message: "All players must have an assigned gender to implement this rule set.")
        }
        // TODO: IMPLEMENT ACTUAL RULESET
        return collection.reversed()
    }
}
