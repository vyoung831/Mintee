//
//  AddTagPopup.swift
//  Mintee
//
//  Created by Vincent Young on 9/12/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

struct AddTagPopup: View {
    
    @Binding var isBeingPresented: Bool
    @State var tagText: String = ""
    @State var errorMessage: String = ""
    
    @FetchRequest(
        // TO-DO: Update NSSortDescriptor to use more robust way to sort Tag name 
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var tagsFetch: FetchedResults<Tag>
    
    // AddTagPopup expects an error message to be returned from the containing view should the addTag closure fail
    var addTag: (String) -> String?
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 30) {
            
            Group {
                HStack {
                    Button(action: {
                        self.isBeingPresented = false
                    }, label: {
                        Text("Cancel")
                    })
                    .foregroundColor(.accentColor)
                    .accessibility(identifier: "add-tag-popup-cancel-button")
                    
                    Spacer()
                    Text("Add Tag")
                        .font(.title)
                    Spacer()
                    
                    Button(action: {
                        
                        if self.tagText.count == 0 {
                            self.isBeingPresented = false
                        } else if let addTagErrorMessage = self.addTag(self.tagText) {
                            self.errorMessage = addTagErrorMessage
                        } else {
                            self.isBeingPresented = false
                        }
                        
                    }, label: {
                        Text("Done")
                    })
                    .foregroundColor(.accentColor)
                    .accessibility(identifier: "add-tag-popup-done-button")
                }
            }
            
            LabelAndTextFieldSection(label: nil, labelIdentifier: "", placeHolder: "Tag name", textField: self.$tagText, textFieldIdentifier: "add-tag-popup-text-field")
            
            if errorMessage.count > 0 {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            // tagsFetch is filtered for Tag names containing the TextField's value
            List(tagsFetch.filter{
                AddTagPopup.tagShouldBeDisplayed($0, self.tagText)
            }, id: \.self) { tag in
                if let tagName = tag._name {
                    Button(tagName) {
                        // Sets the TextField value to the tapped Tag
                        self.tagText = tagName // TO-DO: Add foregroundColor modifier as panelContent when SwiftUI is updated with ability to change List background color
                    }
                }
            }
            .foregroundColor(.primary) // TO-DO: Update foregroundColor to panelContent after SwiftUI is updated with ability to change List background color
            
        }
        .padding(15)
        .accentColor(themeManager.accent)
        .background(themeManager.panel)
        .foregroundColor(themeManager.panelContent)
        
    }
}

extension AddTagPopup {
    
    /**
     Compares a Tag's name to the content in a TextField to determine if the Tag should be displayed to the user to be selected.
     Also used by SearchTagPopup.
     - parameter tag: Tag to evaluate
     - parameter textFieldContent: Content of TextField to evaluate against Tag in question.
     - returns: True if tagText is a substring of tag's name
     */
    static func tagShouldBeDisplayed(_ tag: Tag,_ textFieldContent: String) -> Bool {
        if let tagName = tag._name {
            if tagName.lowercased().contains(textFieldContent.lowercased()) || textFieldContent.count == 0 {
                return true
            }
        }
        return false
    }
    
}
