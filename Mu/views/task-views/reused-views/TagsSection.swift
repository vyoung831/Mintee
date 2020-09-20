//
//  TagsSection.swift
//  Mu
//
//  Created by Vincent Young on 9/12/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TagsSection: View {
    
    @State var isPresentingAddTagPopup: Bool = false
    @Binding var tags: [String]
    
    var body: some View {
        VStack{
            
            HStack {
                Text("Tags")
                    .bold()
                    .accessibility(identifier: "tags-section-label")
                    .accessibility(label: Text("Tags"))
                    .accessibility(addTraits: .isHeader)
                
                Button(action: {
                    self.isPresentingAddTagPopup = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(Color("default-panel-icon-colors"))
                        .accessibility(identifier: "add-tag-button")
                        .accessibility(label: Text("Add"))
                        .accessibility(hint: Text("Tap to add a tag"))
                })
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
            }
            
            ForEach(0 ..< self.tags.count, id: \.self) { idx in
                
                HStack {
                    Text(self.tags[idx])
                    
                    Button(action: {
                        self.tags.remove(at: idx)
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color("default-button-text-colors"))
                    })
                        .accessibility(identifier: "tag-remove-button")
                        .accessibility(label: Text("Remove tag"))
                        .accessibility(hint: Text("Tap to remove tag"))
                }
                .padding(12)
                .foregroundColor(Color("default-button-text-colors"))
                .background(Color("default-button-colors"))
                .cornerRadius(3)
                .accessibility(identifier: "tag")
                .accessibilityElement(children: .combine)
                
            }
        }
    }
}
