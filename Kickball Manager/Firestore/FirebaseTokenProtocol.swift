//
//  FirTokenProtocol.swift
//  Kickball Manager
//
//  Created by Sean G Young on 2/16/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

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

extension FirebaseTokenProtocol where Self: FirEncodable {
    
    func addOrOverwrite(completion: ((Error?) -> Void)? = nil) throws {
        try firDocument.setObject(object: self, completion: completion)
    }
}

extension FirebaseTokenProtocol where Self: NSObject {
    
    func update(property: String, completion: ((Error?) -> Void)?) {
        let value = self.value(forKey: property) ?? FieldValue.delete()
        firDocument.updateData([property: value], completion: completion)
    }
}
