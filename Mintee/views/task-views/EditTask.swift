//
//  EditTask.swift
//  Mintee
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import Firebase

struct EditTask: View {
    
    let saveTaskDeleteMessage: String = "Because you changed your dates, task type, and/or target sets, you will lose data from the following dates. Are you sure you want to continue?"
    let deleteTaskDeleteMessage: String = "Are you sure you want to delete this Task? You will lose all data that you have previously entered for it."
    
    @Binding var isBeingPresented: Bool
    var dismiss: (() -> Void)
    
    var task: Task
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
        
        do {
            
            for idx in 0 ..< self.tags.count {
                let tag = try Tag.getOrCreateTag(tagName: self.tags[idx])
                tagObjects.insert(tag)
            }
            task.updateTags(newTags: tagObjects)
            
            // Update the Task's taskType, dates, targetSets and instances.
            switch self.taskType {
            case .recurring:
                var taskTargetSets: [TaskTargetSet] = []
                if self.taskType == .recurring {
                    for i in 0 ..< taskTargetSetViews.count {
                        let ttsv = taskTargetSetViews[i]
                        let tts = try TaskTargetSet(entity: TaskTargetSet.entity(),
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
                
                try task.updateRecurringInstances(startDate: self.startDate, endDate: self.endDate, targetSets: Set(taskTargetSets))
                
                break
            case .specific:
                try task.updateSpecificInstances(dates: self.dates)
                break
            }
        } catch {
            self.saveErrorMessage = ErrorManager.unexpectedErrorMessage
            CDCoordinator.moc.rollback()
            return
        }
        
        do {
            try CDCoordinator.moc.save()
            self.dismiss(); self.isBeingPresented = false;
        } catch {
            CDCoordinator.moc.rollback()
            self.saveErrorMessage = "Save failed. Please check that another task with this name doesn't already exist."
        }
        
    }
    
    private func deleteTask() {
        do {
            try task.deleteSelf()
            try CDCoordinator.moc.save()
            self.dismiss(); self.isBeingPresented = false;
        } catch {
            self.deleteErrorMessage = ErrorManager.unexpectedErrorMessage
            CDCoordinator.moc.rollback()
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: true, content: {
                VStack(alignment: .leading, spacing: 15, content: {
                    
                    // MARK: - Task name text field
                    
                    LabelAndTextFieldSection(label: "Task name",
                                             labelIdentifier: "task-name-label",
                                             textField: self.$taskName,
                                             textFieldIdentifier: "task-name-text-field")
                    if (saveErrorMessage.count > 0) {
                        Text(saveErrorMessage)
                            .foregroundColor(.red)
                            .accessibility(identifier: "edit-task-save-error-message")
                    }
                    
                    // MARK: - Tags
                    
                    TagsSection(allowedToAddNewTags: true,
                                label: "Tags",
                                formType: "task",
                                tags: self.$tags)
                    
                    // MARK: - Task type
                    
                    SaveFormatterSelectionSection<SaveFormatter.taskType>(sectionLabel: "Task type",
                                                                          options: SaveFormatter.taskType.allCases,
                                                                          selection: self.$taskType)
                    
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
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    
                    switch self.taskType {
                    case .recurring:
                        if taskTargetSetViews.count < 1 {
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
                    do {
                        
                        switch self.taskType {
                        case .recurring:
                            // Creates a Set of DayPatterns to first call Task.getDeltaInstances with.
                            var dayPatterns: Set<DayPattern> = Set()
                            let newTaskTargetSets: [TaskTargetSetView] = self.taskType == .recurring ? taskTargetSetViews : []
                            for tts in newTaskTargetSets {
                                
                                // TaskTargetSetPopup only sets dows, woms, and doms based on the type, so there's no need to check the TaskTargetSet type again here
                                let dp = DayPattern(dow: Set((tts.selectedDaysOfWeek ?? [])),
                                                    wom: Set((tts.selectedWeeksOfMonth ?? [])),
                                                    dom: Set((tts.selectedDaysOfMonth ?? [])))
                                
                                dayPatterns.insert(dp)
                            }
                            
                            // Attempt to get the TaskInstances that would be deleted given the new start date, end date, and target sets.
                            self.datesToDelete = try self.task.getDeltaInstancesRecurring(startDate: self.startDate, endDate: self.endDate, dayPatterns: dayPatterns).map{ Date.toMDYPresent($0) }
                            break
                            
                        case .specific:
                            self.datesToDelete = try self.task.getDeltaInstancesSpecific(dates: Set(self.dates))
                            break
                        }
                        
                    } catch {
                        self.saveErrorMessage = ErrorManager.unexpectedErrorMessage
                        return
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
                .disabled(self.taskName == "")
                .sheet(isPresented: self.isPresentingConfirmDeletePopupForSaveTask ?
                        self.$isPresentingConfirmDeletePopupForSaveTask : self.$isPresentingConfirmDeletePopupForDeleteTask, content: {
                            if self.isPresentingConfirmDeletePopupForSaveTask {
                                ConfirmDeletePopup(deleteMessage: self.saveTaskDeleteMessage,
                                                   deleteList: self.datesToDelete,
                                                   delete: self.saveTask,
                                                   isBeingPresented: self.$isPresentingConfirmDeletePopupForSaveTask)
                            } else {
                                ConfirmDeletePopup(deleteMessage: self.deleteTaskDeleteMessage,
                                                   deleteList: [],
                                                   delete: self.deleteTask,
                                                   isBeingPresented: self.$isPresentingConfirmDeletePopupForDeleteTask)
                            }
                        }),
                trailing: Button(action: {
                    CDCoordinator.moc.rollback()
                    self.dismiss(); self.isBeingPresented = false;
                }, label: {
                    Text("Cancel")
                })
                .foregroundColor(.accentColor)
            )
            .background(themeManager.panel)
            .foregroundColor(themeManager.panelContent)
            
        }
        .accentColor(themeManager.accent)
    }
}
