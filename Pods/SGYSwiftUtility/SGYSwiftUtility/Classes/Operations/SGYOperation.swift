//
//  SGYOperation.swift
//  Pods
//
//  Created by Sean G Young on 4/23/16.
//
//

import UIKit

open class SGYOperation: Operation {
    
    // MARK: - Initialization
    
    public override init() {
        logger = Logger(source: NSStringFromClass(type(of: self)))
        super.init()
    }
    
    // MARK: - Properties
    
    open var logger: Logger
}
