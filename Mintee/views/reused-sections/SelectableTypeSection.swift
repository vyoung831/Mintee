//
//  SelectableTypeSection.swift
//  Mintee
//
//  Section for presenting SaveFormatter enums that conform to SelectableType and updating the value of one on a form.
//
//  Created by Vincent Young on 7/22/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import SwiftUI

/*
 Enums that have all cases displayed to the user for selection/interaction conform to SelectableType.
 */
protocol SelectableType: Equatable {
    
    // String that's displayed to the user for selection
    var stringValue: String { get }
    
}

struct SelectableTypeSection<Type: SelectableType>: View {
    
    var sectionLabel: String
    
    var options: [Type]
    @Binding var selection: Type
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    /**
     Returns an array of plain GridItems for SelectableType selection. The number of elements is equal to the number of selectable options.
     - returns: Array of GridItems to use in this View's LazyVGrid.
     */
    func getGridItemArray() -> [GridItem] {
        var items: [GridItem] = []
        for _ in 0 ..< options.count {
            items.append(GridItem())
        }
        return items
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(self.sectionLabel)
                .bold()
            
            LazyVGrid(columns: self.getGridItemArray(),
                      alignment: .center,
                      spacing: 10) {
                
                ForEach(0 ..< self.options.count, id: \.self) { idx in
                    Button(self.options[idx].stringValue, action: {
                        self.selection = self.options[idx]
                    })
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .foregroundColor(self.options[idx] == self.selection ? themeManager.buttonText : themeManager.panelContent)
                    .background(self.options[idx] == self.selection ? themeManager.button : Color.clear )
                    .cornerRadius(3)
                }
                
            }
            
        }
        
    }
    
}
