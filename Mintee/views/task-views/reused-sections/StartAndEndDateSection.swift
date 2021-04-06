//
//  StartAndEndDateSection.swift
//  Mintee
//
//  Section for presenting start date and end date in recurring type Tasks, re-used by AddTask and EditTask
//
//  Created by Vincent Young on 7/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct StartAndEndDateSection: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    
    @State var isPresentingSetStartDatePopup: Bool = false
    @State var isPresentingSetEndDatePopup: Bool = false
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            
            /*
             The start and end dates are represented as buttons.
             The bindings to popup presentation and startDate/endDate values are passed in by this class so that the popover modifiers can be specified for each button in this View without having to wrap modifiers in the parent view for a single SelectDateSection
             */
            
            Button(action: {
                self.isPresentingSetStartDatePopup = true
            }, label: {
                Text(startDateLabel + Date.toMDYPresent(self.startDate))
            })
            .foregroundColor(.accentColor)
            .popover(isPresented: self.$isPresentingSetStartDatePopup, content: {
                        SetDatePopup.init(
                            isBeingPresented: self.$isPresentingSetStartDatePopup,
                            startDate: self.$startDate,
                            endDate: self.$endDate,
                            isStartDate: true,
                            label: "Select Start Date")})
            .accessibility(identifier: "start-date")
            
            Button(action: {
                self.isPresentingSetEndDatePopup = true
            }, label: {
                Text(endDateLabel + Date.toMDYPresent(self.endDate))
            })
            .foregroundColor(.accentColor)
            .popover(isPresented: self.$isPresentingSetEndDatePopup, content: {
                        SetDatePopup.init(
                            isBeingPresented: self.$isPresentingSetEndDatePopup,
                            startDate: self.$startDate,
                            endDate: self.$endDate,
                            isStartDate: false,
                            label: "Select End Date")})
            .accessibility(identifier: "end-date")
            
        })
    }
}
