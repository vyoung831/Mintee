//
//  SelectDatePopup.swift
//  Mu
//
//  Created by Vincent Young on 4/30/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SelectDatePopup: View {
    
    @Binding var isBeingPresented: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var isStartDate: Bool = false
    var label: String?
    
    var body: some View {
        
        NavigationView {
            VStack{
                if isStartDate {
                    DatePicker("", selection: self.$startDate, displayedComponents: .date)
                        .labelsHidden()
                } else {
                    DatePicker("", selection: self.$endDate, in: startDate..., displayedComponents: .date)
                        .labelsHidden()
                }
            }
            .navigationBarTitle(label ?? "Select Date")
            .navigationBarItems(trailing:
                Button(action: {
                    // If the start date was changed and moved ahead of end date, "fast-forward" end date to match start date
                    if self.isStartDate && self.startDate > self.endDate {
                        self.endDate = self.startDate
                    }
                    self.isBeingPresented = false
                }, label: {
                    Text("Done")
                }))
            
        }
        
    }
}

//struct SelectDatePopup_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectDatePopup()
//    }
//}
