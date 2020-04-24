//
//  EditTask.swift
//  Mu
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct EditTask: View {
    
    let dateLabels: [String] = ["Start Date: ","End Date: "]
    let taskTypes: [String] = ["Recurring","Specific"]
    
    var task: Task
    var dismiss: (() -> Void)
    @State var saveFailed: Bool = false
    @State var taskName: String
    @State var tags: [String]
    @State var startDate: Date
    @State var endDate: Date
    
    private func saveTask() -> Bool {
        task.taskName = self.taskName
        task.processTags(newTagNames: self.tags)
        do {
            try task.managedObjectContext?.save()
            return true
        } catch {
            return false
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 15, content: {
                
                HStack {
                    Button(action: {
                        if self.saveTask() {
                            self.dismiss()
                        } else {
                            // Display failure message in UI if saveTask() failed
                            self.saveFailed = true
                        }
                    }, label: {
                        Text("Save")
                    })
                    Spacer()
                    
                    Text("Edit Task")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    Button(action: {
                        self.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                VStack (alignment: .leading, spacing: 5, content: {
                    Text("Task name")
                        .bold()
                    TextField(task.taskName ?? "", text: self.$taskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if (self.saveFailed) {
                        Text("Save failed")
                            .foregroundColor(.red)
                    }
                })
                
                HStack {
                    Text("Tags")
                        .bold()
                    Image(systemName: "plus")
                }
                ForEach(self.tags,id: \.description) { tag in
                    Text(tag)
                        .padding(.all, 8)
                        .foregroundColor(.white)
                        .background(Color.black)
                }
                
                Text("Task Type")
                    .bold()
                ForEach(taskTypes,id: \.description) { taskType in
                    Text(taskType)
                }
                
                Text("Dates")
                    .bold()
                ForEach(dateLabels,id: \.description) {date in
                    Text(date +
                        (self.dateLabels.firstIndex(of: date) == 0 ? self.startDate.getMYD() : self.endDate.getMYD())
                    )
                }
                
                Text("Target Sets")
                    .bold()
                
            })
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        })
    }
}
