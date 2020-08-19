//
//  SelectDatesSection.swift
//  Mu
//
//  Section for presenting dates in specific type Tasks, re-used by AddTask and EditTask
//
//  Created by Vincent Young on 8/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI


struct SelectDatesSection: View {
    
    @State var isPresentingAddDatePopup: Bool = false
    @Binding var dates: [Date]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            
            HStack {
                Text("Dates")
                    .bold()
                Button(action: {
                    self.isPresentingAddDatePopup = true
                    print("Add date")
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(Color("default-panel-icon-colors"))
                })
                .accessibility(identifier: "add-date-button")
                .accessibility(label: Text("Add"))
                .accessibility(hint: Text("Tap to add a date"))
            }
            
            ForEach(0 ..< dates.count, id: \.self) { idx in
                HStack {
                    Text(Date.toMDYPresent(self.dates[idx]))
                    
                    Button(action: {
                        self.dates.remove(at: idx)
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(Color("default-button-text-colors"))
                    })
                    .accessibility(identifier: "date-delete-button")
                    .accessibility(label: Text("Delete date"))
                    .accessibility(hint: Text("Tap to delete date"))
                }
                .padding(12)
                .foregroundColor(Color("default-button-text-colors"))
                .background(Color("default-button-colors"))
                .cornerRadius(3)
                .accessibility(identifier: "date")
                .accessibilityElement(children: .combine)
            }
            
        })
        .popover(isPresented: self.$isPresentingAddDatePopup, content: {
            AddDatePopup(isBeingPresented: self.$isPresentingAddDatePopup, addDate: { date in
                self.dates.append(date)
                self.dates.sort()
            })
        })
    }
    
}
