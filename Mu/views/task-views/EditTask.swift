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
    let deleteMessage: String = "Because you changed your dates and/or target sets, you will lose data from the following dates. Are you sure you want to continue?"
    
    var task: Task
    var dismiss: (() -> Void)
    @State var datesToDelete: [String] = []
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    @State var isPresentingEditTaskTargetSetPopup: Bool = false
    @State var isPresentingConfirmDeletePopup: Bool = false
    @State var taskName: String
    @State var saveErrorMessage: String = ""
    @State var tags: [String]
    @State var startDate: Date
    @State var endDate: Date
    @State var taskTargetSetViews: [TaskTargetSetView] = []
    @State var deleteErrorMessage: String = ""
    
    private func saveTask() {
        
        task.name = self.taskName
        task.updateTags(newTagNames: self.tags)
        task.updateDates(startDate: self.startDate, endDate: self.endDate)
        
        var taskTargetSets: [TaskTargetSet] = []
        for i in 0 ..< taskTargetSetViews.count {
            let ttsv = taskTargetSetViews[i]
            let tts = TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: ttsv.minTarget,
                                    max: ttsv.maxTarget,
                                    minOperator: SaveFormatter.getOperatorNumber(ttsv.minOperator),
                                    maxOperator: SaveFormatter.getOperatorNumber(ttsv.maxOperator),
                                    priority: Int16(i),
                                    pattern: DayPattern(dow: Set((ttsv.selectedDaysOfWeek ?? []).map{ SaveFormatter.getWeekdayNumber(weekday: $0) }),
                                                        wom: Set((ttsv.selectedWeeksOfMonth ?? []).map{ SaveFormatter.getWeekOfMonthNumber(wom: $0) }),
                                                        dom: Set((ttsv.selectedDaysOfMonth ?? []).map{ Int16($0) ?? 0 })))
            taskTargetSets.append(tts)
        }
        
        task.updateTaskTargetSets(targetSets: taskTargetSets)
        
        do {
            try CDCoordinator.moc.save()
            self.dismiss()
        } catch {
            self.saveErrorMessage = "Save failed. Please check if another Task with this name already exists"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: self.saveErrorMessage)
            }
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
                        
                        if self.taskTargetSetViews.count < 1 { self.saveErrorMessage = "Please add one or more target sets"; return }
                        
                        /*
                         Creates a Set of DayPatterns to first call Task.getDeltaInstances with.
                         If count > 0, the new TaskTargetSets would result in existing TaskInstances being deleted, so ConfirmDeletePopup is presented with the closure to call saveTask() if the user selects yes
                         Otherwise, no TaskInstances would be deleted and saveTask is called directly
                         */
                        var dayPatterns: Set<DayPattern> = Set()
                        for tts in self.taskTargetSetViews {
                            
                            // TaskTargetSetPopup only sets dows, woms, and doms based on the type, so there's no need to check the TaskTargetSet type again here
                            let dp = DayPattern(dow: Set((tts.selectedDaysOfWeek ?? []).map{ SaveFormatter.getWeekdayNumber(weekday: $0) }),
                                                wom: Set((tts.selectedWeeksOfMonth ?? []).map{ SaveFormatter.getWeekOfMonthNumber(wom: $0) }),
                                                dom: Set((tts.selectedDaysOfMonth ?? []).map{ Int16($0) ?? 0 }))
                            
                            dayPatterns.insert(dp)
                        }
                        self.datesToDelete = self.task.getDeltaInstances(startDate: self.startDate, endDate: self.endDate, dayPatterns: dayPatterns)
                        if self.datesToDelete.count > 0 { self.isPresentingConfirmDeletePopup = true }
                        else { self.saveTask() }
                        
                    }, label: {
                        Text("Save")
                    })
                        .accessibility(identifier: "edit-task-save-button")
                        .accessibility(label: Text("Save"))
                        .accessibility(hint: Text("Tap to save changes to task"))
                        .disabled(self.taskName == "")
                        .sheet(isPresented: self.$isPresentingConfirmDeletePopup, content: {
                            ConfirmDeletePopup(deleteMessage: self.deleteMessage,
                                               deleteList: self.datesToDelete,
                                               delete: self.saveTask,
                                               isBeingPresented: self.$isPresentingConfirmDeletePopup)
                        })
                    
                    Spacer()
                    
                    Text("Edit Task")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    Button(action: {
                        CDCoordinator.moc.rollback()
                        self.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                // MARK: - Task name text field
                
                TaskNameTextField(taskName: self.$taskName)
                if (saveErrorMessage.count > 0) {
                    Text(saveErrorMessage)
                        .foregroundColor(.red)
                        .accessibility(identifier: "edit-task-save-error-message")
                        .accessibility(hidden: true)
                }
                
                // MARK: - Tags
                Group {
                    HStack {
                        Text("Tags")
                            .bold()
                            .accessibility(label: Text("Tags"))
                            .accessibility(addTraits: .isHeader)
                        Image(systemName: "plus")
                            .accessibility(identifier: "add-tag-button")
                            .accessibility(label: Text("Add"))
                            .accessibility(hint: Text("Tap to add a tag"))
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
                
                // MARK: - Task type
                
                Group {
                    Text("Task Type")
                        .bold()
                    ForEach(taskTypes,id: \.description) { taskType in
                        Text(taskType)
                    }
                }
                
                // MARK: - Dates
                
                SelectDateSection(startDate: self.$startDate,
                                  endDate: self.$endDate)
                
                // MARK: - Target sets
                
                TaskTargetSetSection(taskTargetSetViews: self.$taskTargetSetViews)
                
                // MARK: - Task deletion
                
                Group {
                    Button(action: {
                        if self.deleteTask() {
                            self.dismiss()
                        } else {
                            self.deleteErrorMessage = "Delete failed"
                        }
                    }, label: {
                        Text("Delete Task")
                            .padding(.all, 10)
                            .background(Color.red)
                            .foregroundColor(.white)
                    })
                    
                    if (deleteErrorMessage.count > 0) {
                        Text(deleteErrorMessage)
                            .foregroundColor(.red)
                    }
                }
                
            })
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)) // VStack insets
        })
    }
}
