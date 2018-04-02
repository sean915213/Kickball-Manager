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
    
    init(firToken: String) {
        self.firToken = firToken
    }
    
    let firToken: String
}

extension KMUser {
    
    static var globalCollection: CollectionReference {
        return Firestore.firestore().collection("users")
    }
    
    var firDocument: DocumentReference {
        return KMUser.globalCollection.document(firToken)
    }
    
    var playersCollection: CollectionReference {
        return firDocument.collection("players")
    }
    
    var teamsCollection: CollectionReference {
        return firDocument.collection("teams")
    }
    
    func getPlayers(completed: @escaping ([Player]?, Error?) -> Void) {
        return playersCollection.getObjects { (players: [Player]?, query, error) in
            completed(players, error)
        }
    }
    
    func getTeams(completed: @escaping ([Team]?, Error?) -> Void) {
        return teamsCollection.getObjects { (teams: [Team]?, query, error) in
            completed(teams, error)
        }
    }
}
