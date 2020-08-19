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
                                        isBeingPresented = false
                                    }, label: {
                                        Text("Cancel")
                                    })
                                    .accessibility(identifier: "add-date-popup-cancel-button")
                                    .accessibility(hint: Text("Tap to cancel date selection")),
                                trailing:
                                    Button(action: {
                                        addDate(self.date)
                                        isBeingPresented = false
                                    }, label: {
                                        Text("Done")
                                    })
                                    .accessibility(identifier: "add-date-popup-done-button")
                                    .accessibility(label: Text("Tap to finish adding date")))
        }
        
    }
    
}
