//
//  Float+Extensions.swift
//  Mintee
//
//  Created by Vincent Young on 6/9/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Float {
    
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
}
