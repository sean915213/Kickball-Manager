//
//  Player.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Contacts
import Firebase

class Player: FirCodable, Equatable {
    
    init(firstName: String, lastName: String, owner: KMUser) {
        self.firstName = firstName
        self.lastName = lastName
        firPath = URL(string: owner.firPlayersCollection.path)!.appendingPathComponent(firstName + "." + lastName).absoluteString
    }
    
    var firstName: String
    var lastName: String
    
    var throwing: Int = 0
    var running: Int = 0
    var kicking: Int = 0
    
    var firPath: String
}

extension Player {
    convenience init(contact: CNContact, owner: KMUser) {
        self.init(firstName: contact.givenName, lastName: contact.familyName, owner: owner)
    }
    
    var displayName: String {
        // TODO: Create contact var and use formatter here
        return firstName + " " + lastName
    }
}

// MARK: PlayerContainer Protocol

protocol PlayerContainer {
    var playerPaths: Set<String> { get }
}

extension PlayerContainer {
    func getPlayers(completion: @escaping ([Player], [String: Error]) -> Void) {
        let documents = playerPaths.map { Firestore.firestore().document($0) }
        documents.getObjects(queue: .sharedAsync) { (results: [(DocumentSnapshot, Player)], errors) in
            let players = results.map { $0.1 }
            completion(players, errors)
        }
    }
}

// MARK: PlayerLinked Protocol

protocol PlayerLinked {
    var playerPath: String { get }
}

extension PlayerLinked {
    func getPlayer(completion: @escaping (Player?, Error?) -> Void) {
        Firestore.firestore().document(playerPath).getObject { (player: Player?, snapshot, error) in
            completion(player, error)
        }
    }
}





