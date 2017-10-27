//
//  NSManagedObjectContextExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func existingObject<T: NSManagedObject>(with objectID: NSManagedObjectID) throws -> T {
        // Force cast since object not found will throw and if an object is found of the wrong type the caller messed up.
        return try existingObject(with: objectID) as! T
    }
    
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> T? {
        // We only expect one entry so limit request
        request.fetchLimit = 1
        return try fetch(request).first
    }
}
