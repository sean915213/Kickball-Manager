//
//  AsyncOperation.swift
//
//  Created by Sean G Young on 3/30/16.
//  Copyright © 2016 Sean G Young. All rights reserved.

import Foundation

open class AsyncOperation: SGYOperation {
    
    // MARK: Required NSOperation properties to support asynchronous execution

    // Indicates we do not finish when `main` exits.  Does not matter when used in an NSOperationQueue (as this generally will be), but this declaration ensures this operation works as intended outside a queue.
    open override var isAsynchronous: Bool { return true }
    
    private var _executing: Bool = false
    override open var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            self.willChangeValue(forKey: "executing")
            self.willChangeValue(forKey: "isExecuting")
            _executing = newValue
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "executing")
        }
    }
    
    private var _finished: Bool = false
    override open var isFinished: Bool {
        get {
            return _finished
        }
        set {
            self.willChangeValue(forKey: "finished")
            self.willChangeValue(forKey: "isFinished")
            _finished = newValue
            self.didChangeValue(forKey: "isFinished")
            self.didChangeValue(forKey: "finished")
        }
    }
    
    // MARK: Methods
    
    open override func start() {
        // Cancel check
        guard !isCancelled else {
            endExecution()
            return
        }
        // Toggle executing
        isExecuting = true
        // Run main
        main()
    }
    
    // Required properties to set in order to indicate completion of operation
    open func endExecution() {
        isExecuting = false
        isFinished = true
    }
}
