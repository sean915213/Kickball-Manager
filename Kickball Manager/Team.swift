//
//  Team.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/14/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

class Team: FirCodable {
    
    init(name: String) {
        self.name = name
    }
    
    var name: String
    var playerIds = Set<String>()
    
    var firPath: String?
}

