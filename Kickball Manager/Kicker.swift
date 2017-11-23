//
//  Kicker.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

class Kicker: FirCodable, PlayerContainer {
    
    init(number: Int, game: Game) {
        self.number = number
        firPath = game.firPathURL!.appendingPathComponent(String(number)).absoluteString
    }
    
    var number: Int
    var playerPaths = Set<String>()
    
    var firPath: String?
}
