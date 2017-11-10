//
//  Player.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Contacts

class Player: FirCodable {
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var firstName: String
    var lastName: String
    
    var throwing: Int = 0
    var running: Int = 0
    var kicking: Int = 0
    
    var firID: String?
}

extension Player {
    convenience init(contact: CNContact) {
        self.init(firstName: contact.givenName, lastName: contact.familyName)
    }
}
