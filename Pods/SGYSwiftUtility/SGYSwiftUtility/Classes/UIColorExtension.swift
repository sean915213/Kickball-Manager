//
//  UIColorExtension.swift
//  Pods
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation

extension UIColor {
    
    /**
     Creates an instance of `UIColor` from a hexadecimal string.
     
     - parameter hexString: The hexadecimal string.
     - precondition: The string must be prefaced with '#'.
     
     - returns: An initialized `UIColor` instance or `nil` if the hexadecimal string could not be parsed into RGB values.
     */
    public convenience init?(hexString: String) {
        precondition(!hexString.isEmpty && hexString.first == "#", "Hex strings must not be empty and must begin with '#'.")
        
        let scanner = Scanner(string: hexString)
        // Bypass '#' char
        scanner.scanLocation = 1
        var rgbValue: UInt32 = 0
        scanner.scanHexInt32(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)
        let green = CGFloat((rgbValue & 0xFF00) >> 7)
        let blue = CGFloat(rgbValue & 0xFF)
        
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
}
