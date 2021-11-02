//
//  UIColor-Extensions.swift
//  Mintee
//
//  Created by Vincent Young on 3/5/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /**
     - parameter hex: 8 digit hex string representing the desired color
     */
    public convenience init?(hex: String) {
        
        let hexColor = String(hex[hex.startIndex...])
        if hexColor.count == 8 {
            
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            // After scanning hex string into a UInt64, use bitwise-AND and shift-right operators to separate each r/g/b/a value.
            if scanner.scanHexInt64(&hexNumber) {
                let r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                let g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                let b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                let a = CGFloat(hexNumber & 0x000000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
            
        }
        return nil
        
    }
    
    /**
     Returns the 8-character hex String representing this UIColor.
     - returns: (Optional) String representing this UIColor's hex value, including alpha.
     */
    func toHex() -> String? {
        
        guard let components = self.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        // Get cgColor's rgb components and round as Floats to Ints
        let r = lroundf( Float(components[0]) * 255 )
        let g = lroundf( Float(components[1]) * 255 )
        let b = lroundf( Float(components[2]) * 255 )
        
        var a: Int = 255
        if components.count >= 4 {
            a = lroundf( Float(components[3]) * 255 )
        }

        return String(format: "%02X%02X%02X%02X", r, g, b, a)
        
    }
    
}
