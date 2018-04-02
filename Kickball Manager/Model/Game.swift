//
//  Game.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

class Game: FirCodable, PlayerContainer {
    
    init(number: Int, team: Team) {
        self.number = number
        firPath = team.gamesCollection.document(String(number)).path
    }
    
    var number: Int
    var playerPaths = Set<String>()
    
    var firPath: String
}

extension Game {
    
    var kickersCollection: CollectionReference {
        return firDocument.collection("kickers")
    }
    
    var inningsCollection: CollectionReference {
        return firDocument.collection("innings")
    }
}
