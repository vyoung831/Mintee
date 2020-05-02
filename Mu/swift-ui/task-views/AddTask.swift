//
//  AddTask.swift
//  Mu
//
//  Created by Vincent Young on 4/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddTask: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    let taskTypes: [String] = ["Recurring","Specific"]
    
    @Binding var isBeingPresented: Bool
    @State var isPresentingSelectStartDatePopup: Bool = false
    @State var isPresentingSelectEndDatePopup: Bool = false
    @State var saveFailed: Bool = false
    @State var taskName: String = ""
    @State var tags: [String] = ["Tag1","Tag4","Tag3"]
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    private func saveTask() -> Bool {
        let newTask = Task(context: CDCoordinator.moc)
        newTask.name = self.taskName
        newTask.updateTags(newTagNames: self.tags)
        newTask.updateDates(startDate: startDate.toStoredString(), endDate: endDate.toStoredString())
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
                
                // MARK: - Title and buttons
                
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
                
                // MARK: - Task name text field
                
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
                
                // MARK: - Tags
                
                Group {
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
                }
                
                // MARK: - Task type
                
                Group{
                    Text("Task Type")
                        .bold()
                    ForEach(taskTypes,id: \.description) { taskType in
                        Text(taskType)
                    }
                }
                
                // MARK: - Dates
                
                Group {
                    Text("Dates")
                        .bold()
                    
                    Button(action: {
                        self.isPresentingSelectStartDatePopup = true
                    }, label: {
                        Text(startDateLabel + self.startDate.toMYD())
                    }).popover(isPresented: self.$isPresentingSelectStartDatePopup, content: {
                        SelectDatePopup.init(
                            isBeingPresented: self.$isPresentingSelectStartDatePopup,
                            startDate: self.$startDate,
                            endDate: self.$endDate,
                            isStartDate: true,
                            label: "Select Start Date")
                    })
                    
                    Button(action: {
                        self.isPresentingSelectEndDatePopup = true
                    }, label: {
                        Text(endDateLabel + self.endDate.toMYD())
                    }).popover(isPresented: self.$isPresentingSelectEndDatePopup, content: {
                        SelectDatePopup.init(
                            isBeingPresented: self.$isPresentingSelectEndDatePopup,
                            startDate: self.$startDate,
                            endDate: self.$endDate,
                            isStartDate: false,
                            label: "Select End Date")
                    })
                }
                
                // MARK: - Target sets
                
                Group {
                    Text("Target Sets")
                        .bold()
                }
                
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
