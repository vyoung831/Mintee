//
//  AddDatePopup.swift
//  Mu
//
//  Created by Vincent Young on 8/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddDatePopup: View {
    
    @State var date: Date = Date()
    @Binding var isBeingPresented: Bool
    
    var addDate: (Date) -> ()
    
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            VStack {
                DatePicker("", selection: self.$date, displayedComponents: .date)
                    .labelsHidden()
                    .accessibility(identifier: "add-date-popup-picker")
            }
            .navigationBarTitle("Add Date")
            .navigationBarItems(leading:
                                    Button(action: {
                                        self.isBeingPresented = false
                                    }, label: {
                                        Text("Cancel")
                                    })
                                    .foregroundColor(.accentColor)
                                    .accessibility(identifier: "add-date-popup-cancel-button"),
                                trailing:
                                    Button(action: {
                                        self.addDate(self.date)
                                        self.isBeingPresented = false
                                    }, label: {
                                        Text("Done")
                                    })
                                    .foregroundColor(.accentColor)
                                    .accessibility(identifier: "add-date-popup-done-button"))
        }
        .accentColor(themeManager.accent)
        
    }
    
}
