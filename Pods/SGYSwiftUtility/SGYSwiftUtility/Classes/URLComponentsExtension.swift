//
//  URLComponentsExtension.swift
//  Pods-SGYSwiftUtility_Tests
//
//  Created by Sean G Young on 11/13/17.
//

import Foundation

extension URLComponents {
    
    func queryValues(for name: String) -> [String?]? {
        return queryItems?.filter({ $0.name == name }).map { $0.value }
    }
}
