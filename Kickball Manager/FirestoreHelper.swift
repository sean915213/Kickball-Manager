//
//  FirestoreHelper.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

protocol FirebaseTokenProtocol {
    var firID: String? { get set }
}

typealias FirEncodable = Encodable & FirebaseTokenProtocol
typealias FirDecodable = Decodable & FirebaseTokenProtocol
typealias FirCodable = Codable & FirebaseTokenProtocol

extension CollectionReference {
    
    func getObjects<T: FirDecodable>(completion: @escaping ([T]?, QuerySnapshot?, Error?) -> Void) {
        getDocuments { (query, error)  in
            guard let query = query else {
                completion(nil, nil, error)
                return
            }
            // Create objects
            var objects = [T]()
            // Iterate over documents
            for document in query.documents {
                do {
                    guard var object: T = try document.data() else { continue }
                    // Add object id and append
                    object.firID = document.documentID
                    objects.append(object)
                } catch let coderErr as NSError {
                    completion(objects, query, coderErr)
                }
            }
            completion(objects, query, error)
        }
    }
    
    func addDocument<T: FirEncodable>(object: T, completion: ((Error?) -> Void)? = nil) throws -> (T, DocumentReference) {
        // Technically encodable can be a struct so create mutable copy
        var returnObject = object
        // Encode into json
        let json = try encoder.encode(object)
        // Decode into dictionary
        let dict = try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        // Add
        var document: DocumentReference! = nil
        document = addDocument(data: dict, completion: completion)
        // Assign token to object
        returnObject.firID = document.documentID
        // Return object and result
        return (returnObject, document)
    }
}

//extension QuerySnapshot {
//
//    func getObjects<T: Decodable>() throws -> [T] {
//        var objects = [T]()
//        // Iterate over documents
//        for document in documents {
//            // Since object is part of the returned query we do not expect it to have no data
//            let object: T = try document.data()!
//            objects.append(object)
//        }
//        return objects
//    }
//}

extension DocumentSnapshot {
    
    func data<T: Decodable>() throws -> T? {
        guard exists else { return nil }
        // Get json data from dictionary
        let json = try JSONSerialization.data(withJSONObject: data(), options: [])
        // Decode into type and add to array
        return try decoder.decode(T.self, from: json)
    }
    
}
