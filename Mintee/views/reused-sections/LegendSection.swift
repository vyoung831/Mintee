//
//  LegendSection.swift
//  Mu
//
//  Created by Vincent Young on 2/19/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct LegendSection: View {
    
    @Binding var legendEntries: [LegendEntryView]
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                Text("Legend")
                    .bold()
                Spacer()
            }
            
            ForEach(0 ..< legendEntries.count, id: \.self) { idx in
                legendEntries[idx]
            }
            
        }
        
    }
}
