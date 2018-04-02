//
//  Position.swift
//  Kickball Manager
//
//  Created by Sean G Young on 1/15/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation

enum Position: String, Codable {
    case firstBase,
    secondBase,
    thirdBase,
    shortStop,
    pitcher,
    catcher,
    farLeftField,
    midLeftField,
    midRightField,
    farRightField
    
    static let allValues: [Position] = [.firstBase, .secondBase, .thirdBase, .shortStop, .pitcher, .catcher, .farLeftField, .farRightField, .midLeftField, .midRightField]
}
