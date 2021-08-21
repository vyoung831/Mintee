//
//  StartAndEndDateSection.swift
//  Mintee
//
//  Section for presenting start date and end date that automatically update.
//  Setting start date to later than the current end date "fast-forwards" end date, and vice versa for setting end date to earlier than start date.
//
//  Created by Vincent Young on 7/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct StartAndEndDateSection: View {
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            HStack(alignment: .center, spacing: 8) {
                Text("Start:")
                DatePicker("", selection: self.$startDate, displayedComponents: [.date])
                    .labelsHidden()
                    .accessibility(identifier: "start-date-picker")
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 16) {
                Text("End:")
                DatePicker("", selection: self.$endDate, displayedComponents: .date)
                    .labelsHidden()
                    .accessibility(identifier: "end-date-picker")
                Spacer()
            }
            
        }
        .onChange(of: startDate, perform: { newStartDate in
            if endDate.lessThanOrEqualToDate(newStartDate) {
                endDate = newStartDate
            }
        })
        .onChange(of: endDate, perform: { newEndDate in
            if newEndDate.lessThanOrEqualToDate(startDate) {
                startDate = newEndDate
            }
        })
    }
}
