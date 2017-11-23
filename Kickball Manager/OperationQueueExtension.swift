//
//  OperationQueueExtension.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation

fileprivate let queue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "Shared Async"
    return queue
}()

extension OperationQueue {
    static let sharedAsync = queue
}
