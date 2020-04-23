//
//  Date+Extensions.swift
//  Mu
//
//  Created by Vincent Young on 4/15/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

extension Date {
    
    func getMYD() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        return dateFormatterPrint.string(from: self)
    }
    
}
