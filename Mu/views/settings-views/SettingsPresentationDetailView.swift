//
//  SettingsPresentationDetailView.swift
//  Mu
//
//  Created by Vincent Young on 10/7/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsPresentationDetailView: View {
    
    // The name of the key saved to UserDefaults and its possible values
    var option: String
    var values: [String]
    
    // Binding to the current value saved to UserDefaults under option
    @Binding var savedValue: String
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        List(self.values, id: \.self) { value in
            Button(action: {
                savedValue = value
            }, label: {
                HStack {
                    Text(value) // TO-DO: Add foregroundColor modifier when List background is able to be set to themeManager.panel
                    Spacer()
                    if savedValue == value {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            })
        }
        .navigationTitle(Text(option))
        
    }
}
