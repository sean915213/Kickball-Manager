//
//  KMUser.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/31/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

class KMUser: Codable {
    
//    static var current: KMUser?
    
    init(firToken: String) {
        self.firToken = firToken
    }
    
    let firToken: String
}

extension KMUser {
    
    static var firCollection: CollectionReference {
        return Firestore.firestore().collection("users")
    }
    
    var firDocument: DocumentReference {
        return KMUser.firCollection.document(firToken)
    }
    
    var firPlayersCollection: CollectionReference {
        return firDocument.collection("players")
    }
    
    var firTeamsCollection: CollectionReference {
        return firDocument.collection("teams")
    }
    
    func getPlayers(completed: @escaping ([Player]?, Error?) -> Void) {
        return firPlayersCollection.getObjects { (players: [Player]?, query, error) in
            completed(players, error)
        }
    }
    
    func getTeams(completed: @escaping ([Team]?, Error?) -> Void) {
        return firTeamsCollection.getObjects { (teams: [Team]?, query, error) in
            completed(teams, error)
        }
    }
}
