//
//  DayBubbleLabels.swift
//  Mu
//
//  This class handles the content that is displayed in BubbleRows and BubbleRowsToggleable.
//  Because the bubbles labels must be able to be translated the following ways, this class' APIs/functions are centered around labels' short representations
//  - Converted to save data to persist to storage
//  - Converted to long representations for accessibility labels
//  - Localized
//  All conversion to/from save data is still handled by SaveFormatter. Thus, the constants in this class must be kept up to date with those in SaveFormatter
//
//  Created by Vincent Young on 7/14/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation

class DayBubbleLabels {
    
    static let daysOfWeek: [String] = ["M","T","W","R","F","S","U"]
    static let weeksOfMonth: [String] = ["1st","2nd","3rd","4th","Last"]
    static let daysOfMonth: [String] = ["1","2","3","4","5","6","7","8","9",
                                        "10","11","12","13","14","15","16","17","18","19",
                                        "20","21","22","23","24","25","26","27","28","29",
                                        "30","31","Last"]
    
    /**
     Returns a representation of day bubbles that BubbleRows and BubbleRowsToggleable need to display their content
     - parameter bubblesPerRow: The max number of bubbles to be in each sub-array
     - parameter patternType: The type of labels to return
     - returns: An array of arrays of Strings, with each sub-array representing a row of bubble labels
     */
    static func getDividedBubbleLabels(bubblesPerRow: Int, patternType: DayPattern.patternType) -> [[String]] {
        var sourceLabels: [String]
        switch patternType {
        case .dow:
            sourceLabels = daysOfWeek
            break
        case .wom:
            sourceLabels = weeksOfMonth
            break
        case .dom:
            sourceLabels = daysOfMonth
            break
        }
        var dividedLabels: [[String]] = []
        for x in stride(from: 0, to: sourceLabels.count, by: bubblesPerRow) {
            let labelSlice = sourceLabels[x ... min(x + Int(bubblesPerRow) - 1, sourceLabels.count - 1)]
            dividedLabels.append( Array(labelSlice) )
        }
        return dividedLabels
    }
    
    /**
     Returns the long representation of a day label to be used for accessibility
     - parameter label: short representation of dayLabel taken from DayBubble's constants
     - returns: Long representation of day label
     */
    static func getLongLabel(_ label: String) -> String {
        switch label {
        case "M":
            return "Monday"
        case "T":
            return "Tuesday"
        case "W":
            return "Wednesday"
        case "R":
            return "Thursday"
        case "F":
            return "Friday"
        case "S":
            return "Saturday"
        case "U":
            return "Sunday"
        default:
            return label + " of each month"
        }
    }
    
}
