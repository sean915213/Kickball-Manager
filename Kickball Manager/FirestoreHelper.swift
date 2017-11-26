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
    var firPath: String { get }
}

typealias FirEncodable = Encodable & FirebaseTokenProtocol
typealias FirDecodable = Decodable & FirebaseTokenProtocol
typealias FirCodable = Codable & FirebaseTokenProtocol

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

enum FirError: Error {
    case documentNotFound
}

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
                    objects.append(object)
                } catch let coderErr as NSError {
                    completion(objects, query, coderErr)
                }
            }
            completion(objects, query, error)
        }
    }
    
    // TODO: Doesn't belong here since using full object path instead of this collection's reference
    func addObject<T: FirEncodable>(object: T, completion: ((Error?) -> Void)? = nil) throws -> DocumentReference {
        // Create reference
        let document = Firestore.firestore().document(object.firPath)
        // Set data
        try document.setObject(object: object, completion: completion)
        // Return document
        return document
    }
}

extension DocumentReference {
    
    func setObject<T: FirEncodable>(object: T, completion: ((Error?) -> Void)? = nil) throws {
        // Encode into json
        let json = try encoder.encode(object)
        // Decode into dictionary
        let dict = try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        // Set
        setData(dict, completion: completion)
    }
    
    func getObject<T: FirDecodable>(completion: @escaping (T?, DocumentSnapshot?, Error?) -> Void) {
        getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil, nil, error)
                return
            }
            guard snapshot.exists else {
                completion(nil, snapshot, FirError.documentNotFound)
                return
            }
            do {
                let object: T = try snapshot.data()!
                completion(object, snapshot, error)
            } catch let error {
                completion(nil, snapshot, error)
            }
        }
    }
}

extension DocumentSnapshot {
    func data<T: FirDecodable>() throws -> T? {
        guard exists else { return nil }
        // Get json data from dictionary
        let json = try JSONSerialization.data(withJSONObject: data(), options: [])
        // Decode into type
        return try decoder.decode(T.self, from: json)
    }
}

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

extension FirebaseTokenProtocol where Self: FirCodable {
    
    func addOrOverwrite(completion: ((Error?) -> Void)? = nil) throws {
        try firDocument.setObject(object: self, completion: completion)
    }
}

extension Sequence where Element: DocumentReference {
    
    func getObjects<T: FirDecodable>(queue: OperationQueue, completion: @escaping ([(DocumentSnapshot, T)], [String: Error]) -> Void) {
        // Create operations
        let operations = map { GetObjectOperation<T>(document: $0) }
        // Callback
        let callback = BlockOperation {
            var results = [(DocumentSnapshot, T)]()
            var errors = [String: Error]()
            for operation in operations {
                guard !operation.isCancelled else { continue }
                switch operation.result! {
                case let .success(snapshot, object):
                    results.append((snapshot, object))
                case let .failed(error):
                    errors[operation.document.path] = error
                }
            }
            // Execute callback
            completion(results, errors)
        }
        // Add operations as dependancy
        operations.forEach { callback.addDependency($0) }
        // Add to queues
        queue.addOperations(operations, waitUntilFinished: false)
        OperationQueue.main.addOperation(callback)
    }
}
