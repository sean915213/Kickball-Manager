//
//  Player.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation

struct Player: Codable {
    
    var firstName: String
    var lastName: String
    
    var throwing: Int
    var running: Int
    var kicking: Int
}
