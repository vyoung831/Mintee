//
//  DayBubbleLabels.swift
//  Mintee
//
//  This class handles the content that is displayed in BubbleRows.
//
//  Created by Vincent Young on 7/14/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreGraphics

struct DayBubbleLabels {
    
    /**
     Returns a representation of day bubbles that BubbleRows needs to display content.
     - parameter bubblesPerRow: The max number of bubbles allowed in each sub-array.
     - returns: An array of arrays of type SaveFormatter.dayOfWeek. Each sub-array represents a row of bubble labels.
     */
    static func getDividedBubbles_daysOfWeek(bubblesPerRow: Int) -> [[SaveFormatter.dayOfWeek]] {
        
        var dividedLabels: [[SaveFormatter.dayOfWeek]] = []
        let sourceLabels = SaveFormatter.dayOfWeek.allCases
        for x in stride(from: 0, to: sourceLabels.count, by: bubblesPerRow) {
            let labelSlice = sourceLabels[x ... min(x + Int(bubblesPerRow) - 1, sourceLabels.count - 1)]
            dividedLabels.append( Array(labelSlice) )
        }
        return dividedLabels
        
    }
    
    /**
     Returns a representation of day bubbles that BubbleRows needs to display content.
     - parameter bubblesPerRow: The max number of bubbles allowed in each sub-array.
     - returns: An array of arrays of type SaveFormatter.weekOfMonth. Each sub-array represents a row of bubble labels.
     */
    static func getDividedBubbles_weeksOfMonth(bubblesPerRow: Int) -> [[SaveFormatter.weekOfMonth]] {
        
        var dividedLabels: [[SaveFormatter.weekOfMonth]] = []
        let sourceLabels = SaveFormatter.weekOfMonth.allCases
        for x in stride(from: 0, to: sourceLabels.count, by: bubblesPerRow) {
            let labelSlice = sourceLabels[x ... min(x + Int(bubblesPerRow) - 1, sourceLabels.count - 1)]
            dividedLabels.append( Array(labelSlice) )
        }
        return dividedLabels
        
    }
    
    /**
     Returns a representation of day bubbles that BubbleRows needs to display content.
     - parameter bubblesPerRow: The max number of bubbles allowed in each sub-array.
     - returns: An array of arrays of type SaveFormatter.dayOfMonth. Each sub-array represents a row of bubble labels.
     */
    static func getDividedBubbles_daysOfMonth(bubblesPerRow: Int) -> [[SaveFormatter.dayOfMonth]] {
        
        var dividedLabels: [[SaveFormatter.dayOfMonth]] = []
        let sourceLabels = SaveFormatter.dayOfMonth.allCases
        for x in stride(from: 0, to: sourceLabels.count, by: bubblesPerRow) {
            let labelSlice = sourceLabels[x ... min(x + Int(bubblesPerRow) - 1, sourceLabels.count - 1)]
            dividedLabels.append( Array(labelSlice) )
        }
        return dividedLabels
        
    }
    
}
