//
//  GetObjectOperation.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility
import Firebase

class GetObjectOperation<T: FirDecodable>: AsyncOperation {
    
    // NOTE: indirect declaration required or a cyclic metadata crash ensues
    indirect enum Result {
        case success(DocumentSnapshot, T), failed(Error)
    }

    // MARK: - Initialization
    
    init(document: DocumentReference) {
        self.document = document
    }
    
    // MARK: - Properties
    
    let document: DocumentReference
    private(set) var result: Result?
    
    // MARK: - Methods
    
    override func main() {
        // Fetch
        document.getDocument { (snapshot, error) in
            // End execution when done
            defer { self.endExecution() }
            // Get snapshot
            guard let snapshot = snapshot else {
                self.result = .failed(error!)
                return
            }
            // Make sure it exists
            guard snapshot.exists else {
                self.result = .failed(FirError.documentNotFound)
                return
            }
            // Get data
            do {
                let object: T = try snapshot.data()!
                self.result = .success(snapshot, object)
            } catch let error {
                self.result = .failed(error)
            }
        }
    }
}
