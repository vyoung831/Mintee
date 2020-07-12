//
//  SelectDateSection.swift
//  Mu
//
//  Section for presenting start date and end date, re-used by AddTask and EditTask
//
//  Created by Vincent Young on 7/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SelectDateSection: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    
    @State var isPresentingSelectStartDatePopup: Bool = false
    @State var isPresentingSelectEndDatePopup: Bool = false
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            Text("Dates")
                .bold()
            
            /*
             The start and end dates are represented as buttons.
             The bindings to popup presentation and startDate/endDate values are passed in by this class so that the popover modifiers can be specified for each button in this View without having to wrap modifiers in the parent view for a single SelectDateSection
             */
            
            Button(action: {
                self.isPresentingSelectStartDatePopup = true
            }, label: {
                Text(startDateLabel + Date.toMDYPresent(self.startDate))
            }).popover(isPresented: self.$isPresentingSelectStartDatePopup, content: {
                SelectDatePopup.init(
                    isBeingPresented: self.$isPresentingSelectStartDatePopup,
                    startDate: self.$startDate,
                    endDate: self.$endDate,
                    isStartDate: true,
                    label: "Select Start Date")
            })
            
            Button(action: {
                self.isPresentingSelectEndDatePopup = true
            }, label: {
                Text(endDateLabel + Date.toMDYPresent(self.endDate))
            }).popover(isPresented: self.$isPresentingSelectEndDatePopup, content: {
                SelectDatePopup.init(
                    isBeingPresented: self.$isPresentingSelectEndDatePopup,
                    startDate: self.$startDate,
                    endDate: self.$endDate,
                    isStartDate: false,
                    label: "Select End Date")
            })
            
        })
    }
}
