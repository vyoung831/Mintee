//
//  LegendEntryView.swift
//  Mu
//
//  Created by Vincent Young on 2/18/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct LegendEntryView: View {
    
    var delete: () -> ()
    
    var label: String
    var color: Color
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        HStack {
            
            Spacer()
            Text(label)
            
            Spacer()
            Button(action: {
                delete()
            }, label: {
                Image(systemName: "trash")
            })
            
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color)
        .border(themeManager.collectionItemBorder, width: 3)
        .cornerRadius(5)
        
    }
    
}
