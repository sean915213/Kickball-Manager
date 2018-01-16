//
//  OutfieldPosition.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation

class PlayerPosition: FirCodable, PlayerLinked {
    
    init(position: Position, player: Player, inning: Inning) {
        self.position = position
        self.playerPath = player.firPath
        firPath = inning.firPositionsCollection.document(position.rawValue).path
    }
    
    var position: Position
    var playerPath: String
    
    var firPath: String
}
