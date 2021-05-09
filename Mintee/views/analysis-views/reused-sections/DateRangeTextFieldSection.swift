//
//  DateRangeTextFieldSection.swift
//  Mintee
//
//  Created by Vincent Young on 4/6/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct DateRangeTextFieldSection: View {
    
    @Binding var dateRange: String
    
    var body: some View {
        
        HStack {
            Text("Last")
            TextField("", text: self.$dateRange)
                .keyboardType(.decimalPad)
                .frame(width: 160)
                .foregroundColor(.primary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("Days")
            Spacer()
        }
        
    }
    
}
