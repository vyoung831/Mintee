//
//  UIColor-Extensions.swift
//  Mu
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
    
}
