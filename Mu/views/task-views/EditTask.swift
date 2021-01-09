//
//  EditTask.swift
//  Mu
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import Firebase

struct EditTask: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    let taskTypes: [SaveFormatter.taskType] = SaveFormatter.taskType.allCases
    let saveTaskDeleteMessage: String = "Because you changed your dates, task type, and/or target sets, you will lose data from the following dates. Are you sure you want to continue?"
    let deleteTaskDeleteMessage: String = "Are you sure you want to delete this Task? You will lose all data that you have previously entered for it."
    
    var task: Task
    var dismiss: (() -> Void)
    @State var datesToDelete: [String] = []
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    @State var isPresentingEditTaskTargetSetPopup: Bool = false
    @State var isPresentingConfirmDeletePopupForSaveTask: Bool = false
    @State var isPresentingConfirmDeletePopupForDeleteTask: Bool = false
    @State var taskName: String
    @State var taskType: SaveFormatter.taskType
    @State var saveErrorMessage: String = ""
    @State var tags: [String]
    @State var deleteErrorMessage: String = ""
    
    // For recurring Tasks
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var taskTargetSetViews: [TaskTargetSetView] = []
    
    // For specific Tasks
    @State var dates: [Date] = []
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    private func saveTask() {
        
        task._name = self.taskName
        
        var tagObjects: Set<Tag> = Set()
        for idx in 0 ..< self.tags.count {
            if let tag = Tag.getOrCreateTag(tagName: self.tags[idx]) {
                tagObjects.insert(tag)
            } else {
                self.saveErrorMessage = "Save failed. An attempt was made to create a Tag with an empty name."
                return
            }
        }
        task.updateTags(newTags: tagObjects)
        
        // Update the Task's taskType, dates, targetSets and instances.
        switch self.taskType {
        case .recurring:
            var taskTargetSets: [TaskTargetSet] = []
            if self.taskType == .recurring {
                for i in 0 ..< taskTargetSetViews.count {
                    let ttsv = taskTargetSetViews[i]
                    let tts = TaskTargetSet(entity: TaskTargetSet.entity(),
                                            insertInto: CDCoordinator.moc,
                                            min: ttsv.minTarget,
                                            max: ttsv.maxTarget,
                                            minOperator: ttsv.minOperator,
                                            maxOperator: ttsv.maxOperator,
                                            priority: Int16(i),
                                            pattern: DayPattern(dow: Set((ttsv.selectedDaysOfWeek ?? [])),
                                                                wom: Set((ttsv.selectedWeeksOfMonth ?? [])),
                                                                dom: Set((ttsv.selectedDaysOfMonth ?? []))))
                    taskTargetSets.append(tts)
                }
            }
            task.updateRecurringInstances(startDate: self.startDate, endDate: self.endDate, targetSets: Set(taskTargetSets))
            break
        case .specific:
            task.updateSpecificInstances(dates: [])
            break
        }
        
        do {
            try CDCoordinator.moc.save()
            self.dismiss()
        } catch {
            self.saveErrorMessage = "Save failed. Please check if another Task with this name already exists."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: self.saveErrorMessage)
            }
        }
        
    }
    
    private func deleteTask() {
        task.deleteSelf()
        do {
            try CDCoordinator.moc.save()
            self.dismiss()
        } catch {
            self.deleteErrorMessage = "Delete failed"
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 15, content: {
                
                // MARK: - Title and buttons
                
                HStack {
                    Button(action: {
                        
                        switch self.taskType {
                        case .recurring:
                            if self.taskTargetSetViews.count < 1 {
                                self.saveErrorMessage = "Please add one or more target sets"; return
                            }
                        case .specific:
                            if self.dates.count < 1 {
                                self.saveErrorMessage = "Please add one or more dates"; return
                            }
                        }
                        
                        /*
                         Call Task's getDelta functions to get the instances that would be deleted given the user's updated input (TaskTargetSets and Dates)
                         If returned count > 0, existing TaskInstances would be deleted, so ConfirmDeletePopup is presented with the closure to call saveTask() if the user confirms deletion
                         Otherwise, no TaskInstances would be deleted and saveTask is called directly
                         */
                        switch self.taskType {
                        case .recurring:
                            // Creates a Set of DayPatterns to first call Task.getDeltaInstances with.
                            var dayPatterns: Set<DayPattern> = Set()
                            let newTaskTargetSets: [TaskTargetSetView] = self.taskType == .recurring ? self.taskTargetSetViews : []
                            for tts in newTaskTargetSets {
                                
                                // TaskTargetSetPopup only sets dows, woms, and doms based on the type, so there's no need to check the TaskTargetSet type again here
                                let dp = DayPattern(dow: Set((tts.selectedDaysOfWeek ?? [])),
                                                    wom: Set((tts.selectedWeeksOfMonth ?? [])),
                                                    dom: Set((tts.selectedDaysOfMonth ?? [])))
                                
                                dayPatterns.insert(dp)
                            }
                            self.datesToDelete = self.task.getDeltaInstancesRecurring(startDate: self.startDate, endDate: self.endDate, dayPatterns: dayPatterns).map{ Date.toMDYPresent($0) }
                            break
                        case .specific:
                            self.datesToDelete = self.task.getDeltaInstancesSpecific(dates: Set(self.dates))
                            break
                        }
                        
                        if self.datesToDelete.count > 0 {
                            self.isPresentingConfirmDeletePopupForSaveTask = true
                        }
                        else { self.saveTask() }
                        
                    }, label: {
                        Text("Save")
                    })
                    .foregroundColor(.accentColor)
                    .accessibility(identifier: "edit-task-save-button")
                    .accessibility(label: Text("Save"))
                    .accessibility(hint: Text("Tap to save changes to task"))
                    .disabled(self.taskName == "")
                    .sheet(isPresented: self.isPresentingConfirmDeletePopupForSaveTask ? self.$isPresentingConfirmDeletePopupForSaveTask : self.$isPresentingConfirmDeletePopupForDeleteTask, content: {
                        self.isPresentingConfirmDeletePopupForSaveTask ?
                            ConfirmDeletePopup(deleteMessage: self.saveTaskDeleteMessage,
                                               deleteList: self.datesToDelete,
                                               delete: self.saveTask,
                                               isBeingPresented: self.$isPresentingConfirmDeletePopupForSaveTask) :
                            ConfirmDeletePopup(deleteMessage: self.deleteTaskDeleteMessage,
                                               deleteList: [],
                                               delete: self.deleteTask,
                                               isBeingPresented: self.$isPresentingConfirmDeletePopupForDeleteTask)
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
                    .foregroundColor(.accentColor)
                }
                
                // MARK: - Task name text field
                
                TaskNameTextFieldSection(taskName: self.$taskName)
                if (saveErrorMessage.count > 0) {
                    Text(saveErrorMessage)
                        .foregroundColor(.red)
                        .accessibility(identifier: "edit-task-save-error-message")
                        .accessibility(hidden: true)
                }
                
                // MARK: - Tags
                
                TagsSection(tags: self.$tags)
                
                // MARK: - Task type
                
                TaskTypeSection(taskTypes: self.taskTypes, taskType: self.$taskType)
                
                // MARK: - Dates
                
                if self.taskType == .recurring {
                    StartAndEndDateSection(startDate: self.$startDate,
                                           endDate: self.$endDate)
                } else {
                    SelectDatesSection(dates: self.$dates)
                }
                
                // MARK: - Target sets
                
                if self.taskType == .recurring {
                    TaskTargetSetSection(taskTargetSetViews: self.$taskTargetSetViews)
                }
                
                // MARK: - Task deletion
                
                Group {
                    Button(action: {
                        self.isPresentingConfirmDeletePopupForDeleteTask = true
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
        .accentColor(themeManager.accent)
        .background(themeManager.panel)
        .foregroundColor(themeManager.panelContent)
    }
}
