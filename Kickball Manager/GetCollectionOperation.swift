//
//  GetCollectionOperation.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility
import Firebase

class GetCollectionOperation<T: FirDecodable>: AsyncOperation {
    
    // MARK: - Initialization
    
    init(documents: [DocumentReference]) {
        self.documents = documents
        super.init()
    }
    
    // MARK: - Properties
    
    let documents: [DocumentReference]
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "GetCollectionOperation Queue"
        return queue
    }()
    
    private(set) var results = [(DocumentSnapshot, T)]()
    private(set) var errors = [String: Error]()
    
    // MARK: - Methods

    override func main() {
        guard !documents.isEmpty else {
            endExecution()
            return
        }
        // Add operations to queue
        
        
    }
}
