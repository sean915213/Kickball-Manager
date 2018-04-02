//
//  RulsetProtocol.swift
//  Kickball Manager
//
//  Created by Sean G Young on 4/1/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation

protocol RuleSet {
    associatedtype TestType
    
    func canApplyRuleset
    
    
}
