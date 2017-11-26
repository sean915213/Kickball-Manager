//
//  OutfieldPosition.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation

class OutfieldPosition: FirCodable {
    
    init(position: String, inning: Inning) {
        self.position = position
        firPath = inning.firPositionsCollection.document(position).path
    }
    
    var position: String
    var playerPath: String?
    
    var firPath: String
}
