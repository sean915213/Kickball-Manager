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

final class FirestoreHelper {
    
    // MARK: - Static
    
    private static let instance: FirestoreHelper = {
        return FirestoreHelper()
    }()
    
    static var store: Firestore {
        return instance.store
    }
    
    // MARK: - Instance
    
    private init() {
        FirebaseApp.configure()
    }
    
    private var store: Firestore {
        return Firestore.firestore()
    }
}

extension CollectionReference {
    
    func addDocument<T: Encodable>(object: T, completion: ((Error?) -> Void)? = nil) -> DocumentReference {
        // Encode into json
        let json = try! encoder.encode(object)
        // Decode into dictionary
        let dict = try! JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        // Call add with dictionary
        return addDocument(data: dict, completion: completion)
    }
}

extension QuerySnapshot {
    
    func getObjects<T: Decodable>() -> [T] {
        var objects = [T]()
        // Iterate over documents
        for document in documents {
            let data = document.data()
            // Get json data from dictionary
            let json = try! JSONSerialization.data(withJSONObject: data, options: [])
            // Decode into type and add to array
            let object = try! decoder.decode(T.self, from: json)
            objects.append(object)
        }
        return objects
    }
}
