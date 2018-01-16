//
//  Inning.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

class Inning: FirCodable {
    
    init(number: Int, game: Game) {
        self.number = number
        firPath = game.firInningsCollection.document(String(number)).path
    }
    
    var number: Int
    
    var firPath: String
}

extension Inning {
    
    var firPositionsCollection: CollectionReference {
        return firDocument.collection("positions")
    }
    
    func getPositions(_ completion: @escaping ([PlayerPosition]?, Error?) -> Void) {
        firPositionsCollection.getObjects { (positions: [PlayerPosition]?, snapshot, error) in
            completion(positions, error)
        }
    }
}
