//
//  FirestoreHelper.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseTokenProtocol {
    var firPath: String? { get set }
}

typealias FirEncodable = Encodable & FirebaseTokenProtocol
typealias FirDecodable = Decodable & FirebaseTokenProtocol
typealias FirCodable = Codable & FirebaseTokenProtocol

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

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
                    guard let object: T = try document.data() else { continue }
                    
                    print("&& GOT OBJECT: \(object), FIRPATHG: \(object.firPath), FIRDOCUMENT: \(object.firDocument)")
                    
                    objects.append(object)
                } catch let coderErr as NSError {
                    completion(objects, query, coderErr)
                }
            }
            completion(objects, query, error)
        }
    }
    
    func addDocument<T: FirEncodable>(object: T, completion: ((Error?) -> Void)? = nil) throws -> T {
        // Technically encodable can be a struct so create mutable copy
        var returnObject = object
        // Encode into json
        let json = try encoder.encode(object)
        // Decode into dictionary
        let dict = try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        // Add
        let document = addDocument(data: dict, completion: completion)
        // Assign path to object
        returnObject.firPath = document.path
        // Return object
        return returnObject
    }
}

extension DocumentReference {
    func setData<T: FirEncodable>(object: T, completion: ((Error?) -> Void)? = nil) throws {
        // Encode into json
        let json = try encoder.encode(object)
        // Decode into dictionary
        let dict = try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        // Set
        setData(dict, completion: completion)
    }
}

extension DocumentSnapshot {
    
    func data<T: FirDecodable>() throws -> T? {
        guard exists else { return nil }
        // Get json data from dictionary
        let json = try JSONSerialization.data(withJSONObject: data(), options: [])
        // Decode into type
        var object = try decoder.decode(T.self, from: json)
        // Assign document id and return
        object.firPath = reference.path
        return object
    }
}

extension FirebaseTokenProtocol {
    
    var firDocument: DocumentReference? {
        guard let path = firPath else { return nil }
        return Firestore.firestore().document(path)
    }
}

extension FirebaseTokenProtocol where Self: FirCodable {
    
    func overwrite(completion: ((Error?) -> Void)? = nil) throws {
        
        print("&& FIR DOCUMENT ON: \(self), PATH: \(firPath), DOCUMENT: \(firDocument)")
        
        guard let document = firDocument else {
            fatalError("HANDLE THIS")
        }
        try document.setData(object: self, completion: completion)
    }
}
