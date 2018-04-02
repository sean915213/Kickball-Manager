//
//  Talent.swift
//  Kickball Manager
//
//  Created by Sean G Young on 2/27/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation

enum Talent: String, Codable {
    case running, kicking, throwing, fielding, pitching
    
    static let min: Int = 0
    static let max: Int = 100
    static let allValues: [Talent] = [.running, .kicking, .throwing, .fielding, .pitching]
}
