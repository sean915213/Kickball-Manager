//
//  Kicker.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

class Kicker: FirCodable, Equatable, PlayerLinked {
    
    init(number: Int, player: Player, game: Game) {
        self.number = number
        self.playerPath = player.firPath
        firPath = game.firKickersCollection.document(String(number)).path
    }
    
    var number: Int
    var playerPath: String
    
    var firPath: String
}
