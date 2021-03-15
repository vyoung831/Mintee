//
//  LabelAndTextFieldSection.swift
//  Mintee
//
//  View that contains a label and text field binding. Used by forms throughout Mu.
//
//  Created by Vincent Young on 7/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct LabelAndTextFieldSection: View {
    
    var label: String
    var labelIdentifier: String
    
    @Binding var textField: String
    var textFieldIdentifier: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5, content: {
            Text(self.label)
                .bold()
                .accessibility(identifier: labelIdentifier)
            TextField("Task name", text: self.$textField)
                .foregroundColor(.primary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibility(identifier: self.textFieldIdentifier)
        })
    }
    
}
