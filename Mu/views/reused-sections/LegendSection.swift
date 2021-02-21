//
//  LegendSection.swift
//  Mu
//
//  Created by Vincent Young on 2/19/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct LegendSection: View {
    
    @Binding var isPresentingLegendEntryPopup: Bool
    @Binding var legendEntries: [LegendEntryView]
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        Group {
            HStack {
                Text("Legend")
                Button(action: {
                    self.isPresentingLegendEntryPopup = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(themeManager.panelContent)
                        .accessibility(identifier: "add-legend-entry-button")
                })
                .scaleEffect(1.5)
            }
            
            VStack {
                ForEach(0 ..< self.legendEntries.count, id: \.self) { idx in
                    legendEntries[idx]
                }
            }
        }
        
    }
}
