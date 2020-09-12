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
            .popover(isPresented: self.$isPresentingAddTagPopup, content: {
                AddTagPopup(isBeingPresented: self.$isPresentingAddTagPopup, addTag: { newTagName in
                    if tags.contains(where: {$0.lowercased() == newTagName.lowercased()}) {
                        return "Tag \(newTagName) already exists for this task"
                    } else {
                        tags.append(newTagName)
                        tags.sort()
                        return nil
                    }
                })
            })
            
        }
        ForEach(self.tags,id: \.description) { tag in
            Text(tag)
                .padding(.all, 8)
                .foregroundColor(.white)
                .background(Color.black)
                .accessibility(identifier: "tag")
                .accessibility(value: Text("\(tag)"))
        }
    }
}
