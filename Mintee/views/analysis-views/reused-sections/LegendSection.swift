//
//  LegendSection.swift
//  Mu
//
//  Created by Vincent Young on 2/19/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct LegendSection: View {
    
    @State var legendEntryViews: [LegendEntryView] = [ LegendEntryView(type: .categorized, color: .green, category: .reachedTarget),
                                                       LegendEntryView(type: .categorized, color: .red, category: .overTarget),
                                                       LegendEntryView(type: .categorized, color: .red, category: .underTarget)]
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                Text("Legend")
                    .bold()
                Spacer()
            }
            
            ForEach(0 ..< legendEntryViews.count, id: \.self) { idx in
                legendEntryViews[idx]
            }
            
        }
        
    }
}
