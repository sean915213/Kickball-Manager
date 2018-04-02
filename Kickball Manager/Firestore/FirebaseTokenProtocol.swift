//
//  FirTokenProtocol.swift
//  Kickball Manager
//
//  Created by Sean G Young on 2/16/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

// TODO: Can make shared instances? Thread-safe?
private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

protocol FirebaseTokenProtocol {
    var firPath: String { get }
}

typealias FirEncodable = Encodable & FirebaseTokenProtocol
typealias FirDecodable = Decodable & FirebaseTokenProtocol
typealias FirCodable = Codable & FirebaseTokenProtocol

extension FirebaseTokenProtocol {
    
    var firPathURL: URL {
        return URL(string: firPath)!
    }
    
    var firDocument: DocumentReference {
        return Firestore.firestore().document(firPath)
    }
}

extension Equatable where Self: FirebaseTokenProtocol {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.firPath == rhs.firPath
    }
}

extension Hashable where Self: FirebaseTokenProtocol {
    var hashValue: Int {
        return firPath.hashValue
    }
}

extension FirebaseTokenProtocol where Self: CustomStringConvertible {
    var description: String { return firPath }
}

extension FirebaseTokenProtocol where Self: FirEncodable {
    
    func addOrOverwrite(completion: ((Error?) -> Void)? = nil) throws {
        try firDocument.setObject(object: self, completion: completion)
    }
    
    // TODO: I bet I can find a way to combine these with one type expression
    func update<T: Encodable>(property: KeyPath<Self, T>, named name: String, completion: ((Error?) -> Void)? = nil) throws {
        let value = self[keyPath: property]
        // Encode into json
        let json = try encoder.encode([name: value])
        // Decode into dictionary
        let dict = try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        // Send update
        firDocument.updateData(dict, completion: completion)
    }

    func update<T: Encodable>(property: KeyPath<Self, T?>, named name: String, completion: ((Error?) -> Void)? = nil) throws {
        // Attempt getting value
        guard let value = self[keyPath: property] else {
            // Send dictionary with delete value
            firDocument.updateData([name: FieldValue.delete()], completion: completion)
            return
        }
        // Encode into json
        let json = try encoder.encode([name: value])
        // Decode into dictionary
        let dict = try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        // Send update
        firDocument.updateData(dict, completion: completion)
    }
}

