//
//  LabelAndTextFieldSection.swift
//  Mintee
//
//  View that contains an optional label and text field binding. Used by forms throughout Mintee.
//  This View can be used by a SwiftUI View to present a TextField only, in case the parent view needs to apply background or foregroundColor modifiers to its View that the TextField shouldn't inherit (Ex. AddTagPopup and SearchTagPopup). This view will use the system background color (depending on light/dark theme) for the TextField's background. This solution is used as SwiftUI has not declared system background as a standard `Color`.
//
//  Created by Vincent Young on 7/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct LabelAndTextFieldSection: View {
    
    var label: String?
    var labelIdentifier: String
    var placeHolder: String
    
    @Binding var textField: String
    var textFieldIdentifier: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5, content: {
            
            if let unwrappedLabel = self.label {
                Text(unwrappedLabel)
                    .bold()
                    .accessibility(identifier: labelIdentifier)
            }
            
            TextField(self.placeHolder, text: self.$textField)
                .foregroundColor(.primary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibility(identifier: self.textFieldIdentifier)
            
        })
    }
    
}
