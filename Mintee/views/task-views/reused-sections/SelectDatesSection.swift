//
//  SelectDatesSection.swift
//  Mintee
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
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            
            HStack {
                Text("Dates")
                    .bold()
                Button(action: {
                    UIUtil.resignFirstResponder()
                    self.isPresentingAddDatePopup = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                })
                .accessibility(identifier: "add-date-button")
            }
            .foregroundColor(themeManager.panelContent)
            
            ForEach(0 ..< dates.count, id: \.self) { idx in
                HStack {
                    Text(Date.toMDYPresent(self.dates[idx]))
                    
                    Button(action: {
                        UIUtil.resignFirstResponder()
                        self.dates.remove(at: idx)
                    }, label: {
                        Image(systemName: "trash")
                    })
                    .foregroundColor(themeManager.buttonText)
                    .accessibility(identifier: "date-delete-button")
                }
                .padding(12)
                .foregroundColor(themeManager.buttonText)
                .background(themeManager.button)
                .cornerRadius(3)
                .accessibility(identifier: "date")
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
