//
//  LegendEntryView.swift
//  Mu
//
//  Created by Vincent Young on 2/18/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct LegendEntryView: View {
    
    @State var label: String
    @State var color: Color
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        HStack {
            
            ColorPicker(self.label, selection: self.$color)
            
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(self.color)
        .border(themeManager.collectionItemBorder, width: 3)
        .cornerRadius(5)
        
    }
    
}
