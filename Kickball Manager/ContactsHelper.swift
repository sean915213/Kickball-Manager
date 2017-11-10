//
//  ContactsHelper.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/31/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import Foundation
import Contacts
import SGYSwiftUtility

final class ContactsHelper {
    
    class var authorizationStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    // MARK: - Properties
    
    private lazy var store = CNContactStore()
    // Use 'User Initiated' QoS because generally the user will be waiting for results.  But methods below perform I/O so should be kept off main queue.
    private lazy var queue = DispatchQueue.global(qos: .userInitiated)
    
    private lazy var logger = Logger(source: "ContactsHelper")
    
    // MARK: - Methods
    // MARK: Public
    
    func requestAccess(completed: @escaping (Bool) -> Void) {
        store.requestAccess(for: .contacts) { (success, error) in
            // Log error if present
            if let error = error {
                self.logger.log("Error requesting access: \(error.localizedDescription).", level: .warning)
            }
            // Execute callback on main thread
            DispatchQueue.main.async { completed(success) }
        }
    }
    
    func search(forRecordsWithName name: String, keysToFetch keys: [CNKeyDescriptor], completed: @escaping ([CNContact]?) -> Void) {
        // Apple suggests always performing off main thread
        queue.async {
            // Create predicate searching name
            let predicate = CNContact.predicateForContacts(matchingName: name)
            // Fetch contacts. Specify that we only want identifier back
            let records = try? self.store.unifiedContacts(matching: predicate, keysToFetch: keys)
            // Execute callback on main thread
            DispatchQueue.main.async { completed(records) }
        }
    }
    
    func add(_ records: [CNContact], completed: @escaping (Bool) -> Void) {
        // Apple suggests always performing off main thread
        queue.async {
            var success = true
            // Create request
            let saveRequest = CNSaveRequest()
            records.forEach { saveRequest.add($0.mutableCopy() as! CNMutableContact, toContainerWithIdentifier: nil) }
            do {
                // Attempt saving
                try self.store.execute(saveRequest)
            } catch {
                self.logger.log("Error adding contact records: \(error.localizedDescription).", level: .warning)
                // Toggle success
                success = false
            }
            // Execute callback on main thread
            DispatchQueue.main.async { completed(success) }
        }
    }
    
    func update(_ records: [CNContact], completed: @escaping (Bool) -> Void) {
        // Apple suggests always performing off main thread
        queue.async {
            var success = true
            // Create request
            let saveRequest = CNSaveRequest()
            records.forEach { saveRequest.update($0.mutableCopy() as! CNMutableContact) }
            do {
                // Attempt saving
                try self.store.execute(saveRequest)
            } catch {
                self.logger.log("Error updating contact records: \(error.localizedDescription).", level: .warning)
                // Toggle success
                success = false
            }
            // Execute callback on main thread
            DispatchQueue.main.async { completed(success) }
        }
    }
    
    func delete(_ records: [CNContact], completed: @escaping (Bool) -> Void) {
        // Apple suggests always performing off main thread
        queue.async {
            var success = true
            // Create delete request
            let saveRequest = CNSaveRequest()
            records.forEach { saveRequest.delete($0.mutableCopy() as! CNMutableContact) }
            do {
                // Attempt saving
                try self.store.execute(saveRequest)
            } catch let error as NSError {
                self.logger.log("Error deleting contact records: \(error.localizedDescription).", level: .warning)
                // Toggle success
                success = false
            }
            // Execute before leaving
            DispatchQueue.main.async { completed(success) }
        }
    }
}
