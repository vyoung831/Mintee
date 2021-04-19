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
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            
            // Because the @State property wrapper does not support didSet, this solution for updating startDate/endDate was copied from https://stackoverflow.com/questions/62380203/run-code-when-date-in-datepicker-is-changed-in-swiftui-didset-function
            let startDateBinding = Binding(
                get: { self.startDate },
                set: { newValue in
                    self.startDate = newValue
                    if endDate.lessThanOrEqualToDate(startDate) {
                        endDate = startDate
                    }
                }
            ), endDateBinding = Binding(
                get: { self.endDate },
                set: { newValue in
                    self.endDate = newValue
                    if endDate.lessThanOrEqualToDate(startDate) {
                        startDate = endDate
                    }
                })
            
            HStack(alignment: .center, spacing: 8) {
                Text("Start:")
                DatePicker("", selection: startDateBinding, displayedComponents: [.date])
                    .labelsHidden()
                    .accessibility(identifier: "start-date-picker")
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 16) {
                Text("End:")
                DatePicker("", selection: endDateBinding, displayedComponents: .date)
                    .labelsHidden()
                    .accessibility(identifier: "end-date-picker")
                Spacer()
            }
            
        })
    }
}
