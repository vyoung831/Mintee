//
//  AddTask.swift
//  Mu
//
//  Created by Vincent Young on 4/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddTask: View {
    
    let dates: [String] = ["Start Date: ","End Date: "]
    let taskTypes: [String] = ["Recurring","Specific"]
    
    @Binding var isBeingPresented: Bool
    @State var saveFailed: Bool = false
    @State var taskName: String = ""
    @State var tags: [String] = ["Tag1","Tag4","Tag3"]
    @State var startDate: Date = Date(timeIntervalSinceNow: 0)
    @State var endDate: Date = Date(timeIntervalSinceNow: 86400)
    
    private func saveTask() -> Bool {
        let newTask = Task(context: CDCoordinator.moc)
        newTask.name = self.taskName
        newTask.updateTags(newTagNames: self.tags)
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            CDCoordinator.moc.delete(newTask)
            return false
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 15, content: {
                
                HStack {
                    Button(action: {
                        if self.saveTask() {
                            self.isBeingPresented = false
                        } else {
                            // Display failure message in UI if saveTask() failed
                            self.saveFailed = true
                        }
                    }, label: {
                        Text("Save")
                    })
                    Spacer()
                    
                    Text("Add Task")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    Button(action: {
                        self.isBeingPresented = false
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                VStack (alignment: .leading, spacing: 5, content: {
                    Text("Task name")
                        .bold()
                    TextField("Task name", text: self.$taskName)
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
                ForEach(dates,id: \.description) {date in
                    Text(date +
                        (self.dates.firstIndex(of: date) == 0 ? self.startDate.getMYD() : self.endDate.getMYD())
                    )
                }
                
                Text("Target Sets")
                    .bold()
                
            })
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        })
    }
}

struct AddTask_Previews: PreviewProvider {
    static var previews: some View {
        AddTask(isBeingPresented: .constant(true))
    }
}
