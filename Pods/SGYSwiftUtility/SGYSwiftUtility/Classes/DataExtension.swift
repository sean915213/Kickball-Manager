//
//  DataExtension.swift
//
//  Created by Sean G Young on 8/2/16.
//

import Foundation

private let sanitizedCharacters = ["/", " "]

extension Data {
    
    public init?(hexString string: String) {
        // Make sure this string CAN be converted (ie. has even number of characters)
        guard !string.isEmpty && string.lengthOfBytes(using: String.Encoding.utf8) % 2 == 0 else { return nil }
        // Array to store bytes
        var byteArray = Array<UInt8>()
        // Grab the bytes from the string in 2 character chunks
        var index = string.startIndex
        repeat {
            let byteString = string[index..<string.index(index, offsetBy: 2)]
            // Convert to UInt8 representation of the C string
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            // Append to array
            byteArray.append(num)
            // Increment index by 2 spaces
            index = string.index(index, offsetBy: 2)
        } while index < string.endIndex
        // Initialize
        self.init(bytes: byteArray)
    }
    
    public func writeToTempFile(_ fileName: String) -> URL? {
        let fileManager = FileManager.default
        // Create unique directory inside temp folder
        let tempPath = NSTemporaryDirectory()
        do {
            let containingDirectory = URL(fileURLWithPath: tempPath).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
            try fileManager.createDirectory(at: containingDirectory, withIntermediateDirectories: false, attributes: nil)
            // Sanitize fileName
            var sanitizedFileName = fileName
            sanitizedCharacters.forEach { sanitizedFileName = sanitizedFileName.replacingOccurrences(of: $0, with: "") }
            // Create url in this directory
            let dataUrl = containingDirectory.appendingPathComponent(sanitizedFileName)
            // Finally write data
            try write(to: dataUrl)
            // Return url
            return dataUrl
        } catch let error as NSError {
            NSLog("[NSDataExtension] Warning - writeToTempFile failed with error: \(error.localizedDescription).")
            return nil
        }
    }
    
    public func hexString() -> String? {
        guard count > 0 else { return nil }
        var hexString = String()
        // Append to string
        for byte in self { hexString += String(format: "%02x", UInt(byte)) }
        return hexString
    }
}
