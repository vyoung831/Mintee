//
//  EditTask.swift
//  Mu
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct EditTask: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    let taskTypes: [String] = ["Recurring","Specific"]
    
    var task: Task
    var dismiss: (() -> Void)
    @State var isPresentingSelectStartDatePopup: Bool = false
    @State var isPresentingSelectEndDatePopup: Bool = false
    @State var saveFailed: Bool = false
    @State var deleteFailed: Bool = false
    @State var taskName: String
    @State var tags: [String]
    @State var startDate: Date
    @State var endDate: Date
    
    private func saveTask() -> Bool {
        task.name = self.taskName
        task.updateTags(newTagNames: self.tags)
        task.updateDates(startDate: startDate.toStoredString(), endDate: endDate.toStoredString())
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            return false
        }
    }
    
    private func deleteTask() -> Bool {
        task.deleteSelf()
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
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
                
                // MARK: - Task name text field
                
                VStack (alignment: .leading, spacing: 5, content: {
                    Text("Task name")
                        .bold()
                    TextField(task.name ?? "", text: self.$taskName)
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
                
                Group {
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
                
                // MARK: - Task deletion
                
                Group {
                    Button(action: {
                        if self.deleteTask() {
                            self.dismiss()
                        } else {
                            self.deleteFailed = true
                        }
                    }, label: {
                        Text("Delete Task")
                            .padding(.all, 10)
                            .background(Color.red)
                            .foregroundColor(.white)
                    })
                    
                    if (self.deleteFailed) {
                        Text("Delete failed")
                            .foregroundColor(.red)
                    }
                }
                
            })
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        })
    }
}
