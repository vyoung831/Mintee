//
//  TagsSection.swift
//  Mintee
//
//  Created by Vincent Young on 9/12/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TagsSection: View {
    
    var allowedToAddNewTags: Bool
    var label: String
    
    // Specifies the type of form that is used to present TagsSection. formType is used on error messages when attempting to add a tag that has already been added to a task/analysis form.
    var formType: String
    
    @State var isPresentingAddTagPopup: Bool = false
    @State var isPresentingSearchTagPopup: Bool = false
    @Binding var tags: [String]
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    /**
     Adds a new entry to tags if one with the same name doesn't already exist.
     If one with the same name already exists, returns error message.
     - parameter: Value of the new entry.
     - return: Error message to return to the View attempted to add the entry to tags.
     */
    func addTag(_ newTagName: String) -> String? {
        if self.tags.contains(where: {$0.lowercased() == newTagName.lowercased()}) {
            return "Tag \(newTagName) already exists for this \(formType)"
        } else {
            self.tags.append(newTagName)
            self.tags.sort()
            return nil
        }
    }
    
    var body: some View {
        VStack{
            
            HStack {
                Text(label)
                    .bold()
                    .accessibility(identifier: "tags-section-label")
                
                Button(action: {
                    if allowedToAddNewTags {
                        self.isPresentingAddTagPopup = true
                    } else {
                        self.isPresentingSearchTagPopup = true
                    }
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .accessibility(identifier: "add-tag-button")
                })
                .foregroundColor(themeManager.panelContent)
                .sheet(isPresented: allowedToAddNewTags ? self.$isPresentingAddTagPopup : self.$isPresentingSearchTagPopup, content: {
                    if allowedToAddNewTags {
                        AddTagPopup(isBeingPresented: self.$isPresentingAddTagPopup, addTag: { newTagName in
                            return addTag(newTagName)
                        }).environment(\.managedObjectContext, CDCoordinator.moc)
                    } else {
                        SearchTagPopup(isBeingPresented: self.$isPresentingSearchTagPopup, addTag: { newTagName in
                            return addTag(newTagName)
                        }).environment(\.managedObjectContext, CDCoordinator.moc)
                    }
                })
                
                Spacer()
                
            }
            
            ForEach(0 ..< self.tags.count, id: \.self) { idx in
                
                HStack {
                    
                    TagView(name: self.tags[idx],
                            removable: true,
                            remove: {
                                self.tags.remove(at: idx)
                            })
                    
                    Spacer()
                    
                }
                
            }
        }
    }
}

struct TagView: View {
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var name: String
    var removable: Bool
    var remove: () -> ()
    
    var body: some View {
        
        HStack {
            
            Text(name)
            if removable {
                Button(action: {
                    self.remove()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                })
                .accessibility(identifier: "tag-remove-button")
            }
            
        }
        .padding(12)
        .foregroundColor(themeManager.buttonText)
        .background(themeManager.button)
        .cornerRadius(3)
        .accessibility(identifier: "tag")
        
    }
    
    
}
