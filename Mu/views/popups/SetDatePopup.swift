//
//  SetDatePopup.swift
//  Mu
//
//  Created by Vincent Young on 4/30/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SetDatePopup: View {
    
    @Binding var isBeingPresented: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var isStartDate: Bool = false
    var label: String?
    
    var body: some View {
        
        NavigationView {
            VStack {
                if isStartDate {
                    DatePicker("", selection: self.$startDate, displayedComponents: .date)
                        .labelsHidden()
                        .accessibility(identifier: "start-date-picker")
                } else {
                    DatePicker("", selection: self.$endDate, displayedComponents: .date)
                        .labelsHidden()
                        .accessibility(identifier: "end-date-picker")
                }
            }
            .navigationBarTitle(label ?? "Set \(isStartDate ? "Start": "End" ) Date")
            .navigationBarItems(trailing:
                Button(action: {
                    // If the start date was changed and moved ahead of end date, "fast-forward" end date to match start date
                    if self.isStartDate && self.startDate > self.endDate {
                        self.endDate = self.startDate
                    } else if !self.isStartDate && self.endDate < self.startDate {
                        self.startDate = self.endDate
                    }
                    self.isBeingPresented = false
                }, label: {
                    Text("Done")
                })
                    .accessibility(identifier: "set-date-popup-done-button")
                    .accessibility(label: Text("Tap to finish setting \(isStartDate ? "start": "end" ) date"))
            )
            
        }
        
    }
}
