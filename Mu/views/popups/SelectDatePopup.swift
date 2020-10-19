//
//  SelectDatePopup.swift
//  Mu
//
//  Created by Vincent Young on 10/19/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SelectDatePopup: View {
    
    @Binding var isBeingPresented: Bool
    @Binding var date: Date
    var label: String
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            VStack {
                DatePicker("", selection: self.$date, displayedComponents: .date)
                    .labelsHidden()
                    .accessibility(identifier: "end-date-picker")
            }
            .navigationBarTitle(label)
            .navigationBarItems(trailing:
                Button(action: {
                    self.isBeingPresented = false
                }, label: {
                    Text("Done")
                })
                    .accessibility(identifier: "select-date-popup-done-button")
                    .accessibility(label: Text("Tap to finish selecting date"))
            )
            
        }
        
    }
}
