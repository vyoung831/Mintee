//
//  SearchTagPopup.swift
//  Mu
//
//  Created by Vincent Young on 2/20/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct SearchTagPopup: View {
    
    @Binding var isBeingPresented: Bool
    @State var tagText: String = ""
    @State var errorMessage: String = ""
    
    @FetchRequest(
        // TO-DO: Update NSSortDescriptor to use more robust way to sort Tag name
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var tagsFetch: FetchedResults<Tag>
    
    @State var selectedTag: Tag?
    
    // SearchTagPopup expects an error message to be returned from the parent view should the addTag closure fail
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
                    .accessibility(identifier: "search-tag-popup-cancel-button")
                    
                    Spacer()
                    Text("Tag search")
                        .font(.title)
                    Spacer()
                    
                    Button(action: {
                        
                        guard let tag = selectedTag else {
                            self.errorMessage = "Please select a Tag"
                            return
                        }
                        
                        if let addTagErrorMessage = self.addTag(tag._name) {
                            self.errorMessage = addTagErrorMessage
                        } else {
                            self.isBeingPresented = false
                        }
                        
                    }, label: {
                        Text("Done")
                    })
                    .disabled(selectedTag == nil)
                    .foregroundColor(.accentColor)
                    .accessibility(identifier: "search-tag-popup-done-button")
                }
            }
            
            LabelAndTextFieldSection(label: nil, labelIdentifier: "", placeHolder: "Tag name", textField: self.$tagText, textFieldIdentifier: "search-tag-popup-text-field")
            
            if errorMessage.count > 0 {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            // tagsFetch is filtered for Tag names containing the TextField's value
            List(tagsFetch.filter{ TagPopupUtils.tagShouldBeDisplayed($0, self.tagText) || selectedTag == $0 }, id: \.self) { tag in
                if self.selectedTag == tag {
                    HStack {
                        Text(tag._name)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.primary) // TO-DO: Update foregroundColor to accentColor after SwiftUI is updated with ability to change List background color
                    }
                    .onTapGesture {
                        UIUtil.resignFirstResponder()
                    }
                } else {
                    Button(tag._name) {
                        selectedTag = tag
                        UIUtil.resignFirstResponder()
                    }
                }
            }
            .background(themeManager.panel)
            .foregroundColor(.primary) // TO-DO: Update foregroundColor to panelContent after SwiftUI is updated with ability to change List background color
            
        }
        .padding(15)
        .accentColor(themeManager.accent)
        .background(themeManager.panel)
        .foregroundColor(themeManager.panelContent)
        
    }
    
}
