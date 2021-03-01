//
//  TagsSection.swift
//  Mu
//
//  Created by Vincent Young on 9/12/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TagsSection: View {
    
    var label: String
    
    @State var isPresentingAddTagPopup: Bool = false
    @Binding var tags: [String]
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        VStack{
            
            HStack {
                Text(label)
                    .bold()
                    .accessibility(identifier: "tags-section-label")
                
                Button(action: {
                    self.isPresentingAddTagPopup = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .accessibility(identifier: "add-tag-button")
                })
                .foregroundColor(themeManager.panelContent)
                .sheet(isPresented: self.$isPresentingAddTagPopup, content: {
                    AddTagPopup(isBeingPresented: self.$isPresentingAddTagPopup, addTag: { newTagName in
                        if self.tags.contains(where: {$0.lowercased() == newTagName.lowercased()}) {
                            return "Tag \(newTagName) already exists for this task"
                        } else {
                            self.tags.append(newTagName)
                            self.tags.sort()
                            return nil
                        }
                    }).environment(\.managedObjectContext, CDCoordinator.moc)
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
