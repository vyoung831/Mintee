//
//  SettingsPresentationDetailView.swift
//  Mu
//
//  Created by Vincent Young on 10/7/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsPresentationDetailView: View {
    
    var option: String
    var values: [String]
    
    // Binding to value saved to UserDefaults. Value that the parent sets should have the @AppStorage wrapper
    @Binding var savedValue: String
    
    var body: some View {
        
        List(self.values, id: \.self) { value in
            Button(action: {
                savedValue = value
            }, label: {
                HStack {
                    Text(value)
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
