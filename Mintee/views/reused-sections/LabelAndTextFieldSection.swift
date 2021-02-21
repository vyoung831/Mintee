//
//  LabelAndTextFieldSection.swift
//  Mintee
//
//  View that contains a label and text field binding. Used by forms throughout Mintee.
//  This View can also be used by a SwiftUI View to present a TextField only, in case the parent view needs to apply background or foregroundColor modifiers to its View that the TextField shouldn't inherit (Ex. AddTagPopup and SearchTagPopup).
//
//  Created by Vincent Young on 7/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct LabelAndTextFieldSection: View {
    
    var label: String?
    var labelIdentifier: String
    
    @Binding var textField: String
    var textFieldIdentifier: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5, content: {
            
            if let label = self.label {
                Text(label)
                    .bold()
                    .accessibility(identifier: labelIdentifier)
            }
            
            TextField("Task name", text: self.$textField)
                .foregroundColor(.primary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibility(identifier: self.textFieldIdentifier)
            
        })
    }
    
}
