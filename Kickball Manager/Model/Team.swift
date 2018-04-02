//
//  Team.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/14/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

class Team: FirCodable, PlayerContainer {
    
    init(name: String, owner: KMUser) {
        self.name = name
        firPath = URL(string: owner.teamsCollection.path)!.appendingPathComponent(UUID().uuidString).absoluteString
    }
    
    var name: String
    var playerPaths = Set<String>()
    
    var firPath: String
}

extension Team {
    
    var gamesCollection: CollectionReference {
        return firDocument.collection("games")
    }
}

