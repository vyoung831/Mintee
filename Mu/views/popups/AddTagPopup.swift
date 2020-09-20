//
//  AddTagPopup.swift
//  Mu
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
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
    ) var tagsFetch: FetchedResults<Tag>
    
    // AddTagPopup expects an error message to be returned from the containing view should the addTag closure fail
    var addTag: (String) -> String?
    
    /**
     Compares a Tag's name to the content in the tag name TextField and determines if the Tag should be displayed to the user to be selected
     - parameter tag: Tag to evaluate
     - returns: True if tag's name is
     */
    func tagShouldBeDisplayed(_ tag: Tag) -> Bool {
        if let tagName = tag.name {
            if tagName.lowercased().contains(self.tagText.lowercased()) || self.tagText.count == 0 {
                return true
            }
        }
        return false
    }
    
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 30) {
            
            Group {
                HStack {
                    Button(action: {
                        self.isBeingPresented = false
                    }, label: {
                        Text("Cancel")
                    })
                    .accessibility(identifier: "add-tag-popup-cancel-button")
                    .accessibility(hint: Text("Tap to cancel adding tag"))
                    
                    Spacer()
                    Text("Add Tag")
                        .font(.title)
                    Spacer()
                    
                    Button(action: {
                        if let closureErrorMessage = self.addTag(self.tagText) {
                            self.errorMessage = closureErrorMessage
                        } else {
                            self.isBeingPresented = false
                        }
                    }, label: {
                        Text("Done")
                    })
                    .accessibility(identifier: "add-tag-popup-done-button")
                    .accessibility(label: Text("Tap to finish adding tag"))
                }
            }
            
            TextField("Tag name", text: self.$tagText)
                .padding(10)
                .foregroundColor(Color.init("default-disabled-text-colors"))
                .border(Color.init("default-border-colors"), width: 2)
                .cornerRadius(3)
            
            if errorMessage.count > 0 {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            // tagsFetch is filtered for Tag names containing the TextField's value
            List(tagsFetch.filter{
                tagShouldBeDisplayed($0)
            }, id: \.self) { tag in
                if let tagName = tag.name {
                    Button(tagName) {
                        // Sets the TextField value to the tapped Tag
                        self.tagText = tagName
                    }
                }
            }
            
            Spacer()
        }
        .padding(15)
        
    }
}
