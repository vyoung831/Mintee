//
//  LegendEntryView.swift
//  Mu
//
//  Created by Vincent Young on 2/18/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct LegendEntryView: View {
    
    @State var type: AnalysisLegend.EntryType
    @State var color: Color
    
    // vars for if type == .categorized
    @State var category: CategorizedLegendEntry.Category = .reachedTarget
    
    // vars for if type == .completion
    @State var min: Float = 0
    @State var max: Float = 0
    @State var minOperator: SaveFormatter.equalityOperator = .na
    @State var maxOperator: SaveFormatter.equalityOperator = .na
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    /**
     Based on the EntryType assigned to this View, returns the text label for this View's ColorPicker
     - returns: String representing the label to be assigned as this View's ColorPicker
     */
    func getLabel() -> String {
        switch self.type {
        case .categorized:
            switch category {
            case .overTarget: return "Over target"
            case .underTarget: return "Under target"
            case .reachedTarget: return "Reached target"
            }
        case .completion:
            return TaskTargetSetView.getTargetString(minOperator: minOperator, maxOperator: maxOperator, minTarget: min, maxTarget: max)
        }
    }
    
    var body: some View {
        
        HStack {
            ColorPicker(self.getLabel(), selection: self.$color)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(self.color)
        .border(themeManager.collectionItemBorder, width: 3)
        .cornerRadius(5)
        
    }
    
}
