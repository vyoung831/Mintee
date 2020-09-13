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
    
    @State var tag: String = ""
    @Binding var isBeingPresented: Bool
    @State var errorMessage: String = ""
    
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
    ) var tagsFetch: FetchedResults<Tag>
    
    // AddTagPopup expects an error message to be returned from the containing view should the addTag closure fail
    var addTag: (String) -> String?
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 30) {
            
            Group {
                HStack {
                    Button(action: {
                        isBeingPresented = false
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
                        if let closureErrorMessage = addTag(self.tag) {
                            self.errorMessage = closureErrorMessage
                        } else {
                            isBeingPresented = false
                        }
                    }, label: {
                        Text("Done")
                    })
                    .accessibility(identifier: "add-tag-popup-done-button")
                    .accessibility(label: Text("Tap to finish adding tag"))
                }
            }
            
            TextField("Tag name", text: self.$tag)
                .padding(10)
                .foregroundColor(Color.init("default-disabled-text-colors"))
                .border(Color.init("default-border-colors"), width: 2)
                .cornerRadius(3)
            
            if errorMessage.count > 0 {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            // tagsFetch is filtered for Tag names containing the TextField's value
            List(tagsFetch.filter{ tag in
                if let tagName = tag.name {
                    if tagName.lowercased().contains(self.tag.lowercased()) || self.tag.count == 0 {
                        return true
                    }
                }
                return false
            }, id: \.self) { tag in
                if let tagName = tag.name {
                    Button(tagName) {
                        // Sets the TextField value to the tapped Tag
                        self.tag = tagName
                    }
                }
            }
            
            Spacer()
        }
        .padding(15)
        
    }
}
