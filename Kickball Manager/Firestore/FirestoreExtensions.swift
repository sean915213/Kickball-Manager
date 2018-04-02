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

enum FirError: Error { case documentNotFound }

extension Firestore {
    
    func addObject<T: FirEncodable>(_ object: T, completion: ((Error?) -> Void)? = nil) throws -> DocumentReference {
        // Create reference
        let document = Firestore.firestore().document(object.firPath)
        // Set data
        try document.setObject(object: object, completion: completion)
        // Return document
        return document
    }
}

extension CollectionReference {
    
    /// Fetches documents and deserializes into objects of type `T`.
    ///
    /// - Parameter completion: Called with typed results of query or an error.
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
                } catch let coderErr {
                    completion(objects, query, coderErr)
                }
            }
            completion(objects, query, error)
        }
    }
}

extension DocumentReference {
    
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

    func setObject<T: FirEncodable>(object: T, completion: ((Error?) -> Void)? = nil) throws {
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
        let json = try JSONSerialization.data(withJSONObject: data()!, options: [])
        // Decode into type
        return try decoder.decode(T.self, from: json)
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
