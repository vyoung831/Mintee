//
//  SaveFormatterSelectionSection.swift
//  Mintee
//
//  Section for presenting SaveFormatter enums that conform to SelectableType and updating the value of one on a form.
//
//  Created by Vincent Young on 7/22/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import SwiftUI

struct SaveFormatterSelectionSection<Type: SelectableType>: View {
    
    var sectionLabel: String
    
    var options: [Type]
    @Binding var selection: Type
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(self.sectionLabel)
                .bold()
            
            ForEach(0 ..< self.options.count, id: \.self) { idx in
                Button(self.options[idx].stringValue, action: {
                    self.selection = self.options[idx]
                })
                .padding(12)
                .foregroundColor(self.options[idx] == self.selection ? themeManager.buttonText : themeManager.panelContent)
                .background(self.options[idx] == self.selection ? themeManager.button : Color.clear )
                .cornerRadius(3)
            }
            
        }
        
    }
    
}
