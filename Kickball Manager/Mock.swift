//
//  Mock.swift
//  Kickball Manager
//
//  Created by Sean G Young on 2/27/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import Firebase
import SGYSwiftUtility

final class Mock {
    
    private static let logger = Logger(source: "Mock")
    
    static func seedPlayers(forUser user: KMUser) {
        // Generate players
        for i in 0..<10 {
            let player = Player(firstName: "FIRST \(i)", lastName: "LAST \(i)", owner: user)
            try! player.addOrOverwrite { (error) in
                if let error = error {
                    logger.logWarning("Failed to add mock player w/ error: \(error)")
                } else {
                    logger.logInfo("Seeded new player: \(player)")
                }
            }
        }
    }
}
