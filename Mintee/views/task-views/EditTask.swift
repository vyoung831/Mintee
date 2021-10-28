//
//  EditTask.swift
//  Mintee
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import Firebase
import CoreData

struct EditTask: View {
    
    let saveTaskDeleteMessage: String = "Because you changed your dates, task type, and/or target sets, you will lose data from the following dates. Are you sure you want to continue?"
    let deleteTaskDeleteMessage: String = "Are you sure you want to delete this Task? You will lose all data that you have previously entered for it."
    
    var isBeingPresented: Binding<Bool>
    
    var task: Task?
    @State var datesToDelete: [String] = []
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    @State var isPresentingEditTaskTargetSetPopup: Bool = false
    @State var isPresentingConfirmDeletePopupForSaveTask: Bool = false
    @State var isPresentingConfirmDeletePopupForDeleteTask: Bool = false
    
    @State var saveErrorMessage: String = ""
    @State var deleteErrorMessage: String = ""
    
    // Default values in case View initialization fails
    @State var taskName: String = ""
    @State var taskType: SaveFormatter.taskType = .recurring
    @State var tags: [String] = []
    
    // Vars for recurring Tasks
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var taskTargetSetViews: [TaskTargetSetView] = []
    
    // Vars for specific Tasks
    @State var dates: [Date] = []
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    init(task: Task, presented: Binding<Bool>) {
        
        self.isBeingPresented = presented
        
        var type: SaveFormatter.taskType
        do {
            type = try task._taskType
            self._tags = State(initialValue: (try task._tags).map{ $0._name })
        } catch {
            NotificationCenter.default.post(name: .editTask_initFailed, object: nil); return
        }
        
        switch type {
        case .recurring:
            guard let recurringProperties = EditTask.getRecurringProperties(task) else {
                NotificationCenter.default.post(name: .editTask_initFailed, object: nil)
                return
            }
            self._startDate = State(initialValue: recurringProperties.startDate)
            self._endDate = State(initialValue: recurringProperties.endDate)
            self._taskTargetSetViews = State(initialValue: recurringProperties.ttsvArray)
            break
        case .specific:
            guard let instances = EditTask.getSpecificDates(task) else {
                NotificationCenter.default.post(name: .editTask_initFailed, object: nil)
                return
            }
            self._dates = State(initialValue: instances)
            break
        }
        
        self._taskName = State(initialValue: task._name)
        self._taskType = State(initialValue: type)
        self.task = task
        
    }
    
    /**
     Update the Task's relationships and saves it.
     Since this function may be called as part of a completion handler, View dismissal is performed in this function.
     */
    private func saveTask() {
        
        guard let existingTask = self.task else { return }
        
        let childContext = CDCoordinator.getChildContext()
        guard let childTask = childContext.childTask(existingTask.objectID) else {
            NotificationCenter.default.post(name: .taskUpdateFailed, object: nil); return
        }
        
        childContext.perform {
            do {
                try childTask.updateTags(newTagNames: Set(self.tags), childContext)
                
                // Update the Task's taskType, dates, targetSets and instances.
                switch self.taskType {
                case .recurring:
                    var taskTargetSets: [TaskTargetSet] = []
                    if self.taskType == .recurring {
                        for i in 0 ..< taskTargetSetViews.count {
                            let ttsv = taskTargetSetViews[i]
                            let tts = try TaskTargetSet(entity: TaskTargetSet.entity(), insertInto: childContext,
                                                        min: ttsv.minTarget, max: ttsv.maxTarget,
                                                        minOperator: ttsv.minOperator, maxOperator: ttsv.maxOperator,
                                                        priority: Int16(i),
                                                        pattern: DayPattern(dow: Set((ttsv.selectedDaysOfWeek ?? [])),
                                                                            wom: Set((ttsv.selectedWeeksOfMonth ?? [])),
                                                                            dom: Set((ttsv.selectedDaysOfMonth ?? []))))
                            taskTargetSets.append(tts)
                        }
                    }
                    try childTask.updateRecurringInstances(startDate: self.startDate, endDate: self.endDate, targetSets: Set(taskTargetSets), childContext)
                    break
                case .specific:
                    try childTask.updateSpecificInstances(dates: self.dates, childContext)
                    break
                }
            } catch {
                NotificationCenter.default.post(name: .taskUpdateFailed, object: nil)
            }
            
            do {
                try CDCoordinator.saveAndMergeChanges(childContext)
            } catch {
                NotificationCenter.default.post(name: .taskUpdateFailed, object: nil)
            }
            
        }
        
        // Dismiss this `EditTask` View
        self.isBeingPresented.wrappedValue = false
        
    }
    
    private func deleteTask() {
        guard let existingTask = self.task else { return }
        
        let childContext = CDCoordinator.getChildContext()
        guard let childTask = childContext.childTask(existingTask.objectID) else {
            NotificationCenter.default.post(name: .taskDeleteFailed, object: nil); return
        }
        
        childContext.perform {
            do {
                try childTask.deleteSelf(childContext)
                try CDCoordinator.saveAndMergeChanges(childContext)
            } catch {
                NotificationCenter.default.post(name: .taskDeleteFailed, object: nil)
            }
        }
        self.isBeingPresented.wrappedValue = false
    }
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: true, content: {
                VStack(alignment: .leading, spacing: 15, content: {
                    
                    // MARK: - Task name text field
                    
                    LabelAndTextFieldSection(label: "Task name",
                                             labelIdentifier: "task-name-label",
                                             placeHolder: "Task name",
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
                    
                    SelectableTypeSection<SaveFormatter.taskType>(sectionLabel: "Task type",
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
                                .cornerRadius(3)
                        }).disabled(self.task == nil)
                        
                        if (deleteErrorMessage.count > 0) {
                            Text(deleteErrorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    
                })
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)) // VStack insets
            })
                .onTapGesture {
                    UIUtil.resignFirstResponder()
                }
                .navigationTitle("Edit Task")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {
                        
                        guard let unwrappedTask = self.task else { return }
                        
                        switch self.taskType {
                        case .recurring:
                            if taskTargetSetViews.count < 1 {
                                self.saveErrorMessage = "Please add one or more target sets"; return
                            }
                            break
                        case .specific:
                            if self.dates.count < 1 {
                                self.saveErrorMessage = "Please add one or more dates"; return
                            }
                            break
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
                                self.datesToDelete = try unwrappedTask.getDeltaInstancesRecurring(startDate: self.startDate, endDate: self.endDate, dayPatterns: dayPatterns).map{ Date.toMDYPresent($0) }
                                break
                                
                            case .specific:
                                self.datesToDelete = try unwrappedTask.getDeltaInstancesSpecific(dates: Set(self.dates))
                                break
                            }
                            
                        } catch {
                            NotificationCenter.default.post(name: .taskSaveFailed, object: nil)
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
                        .disabled(self.taskName.count < 1 || self.task == nil)
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
                        self.isBeingPresented.wrappedValue = false
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

// MARK: - Helper functions

extension EditTask {
    
    /**
     Unwraps and returns a Task's startDate, endDate, and targetSets (represented as an array of TaskTargetSetView).
     If any of those properties are nil or can't be converted to valid in-memory form, nil is returned.
     - returns: (Optional) Named tuple containing representations of the provided Task's startDate, endDate, and targetSets.
     */
    static func getRecurringProperties(_ task: Task) -> (startDate: Date, endDate: Date, ttsvArray: [TaskTargetSetView])? {
        do {
            guard let startDate = try task._startDate,
                  let endDate = try task._endDate,
                  let ttsvs = try EditTask.extractTTSVArray(task) else {
                      return nil
                  }
            return (startDate, endDate, ttsvs)
        } catch {
            return nil
        }
    }
    
    /**
     Unwraps and returns the dates of TaskInstances associated with the provided Task (assumes task is specific-type).
     If instances are nil, an instance's date is nil, or an instance's date cannot be converted to a Date object, nil is returned.
     - returns: (Optional) Array of Dates representing the dates of TaskInstances associated with the provided Task.
     */
    static func getSpecificDates(_ task: Task) -> [Date]? {
        do {
            let instances = try task._instances.sorted(by: {try $0._date.lessThanDate(try $1._date)})
            return try instances.map{
                try $0._date
            }
        } catch {
            return nil
        }
    }
    
    /**
     Extracts the TaskTargetSets associated with a Task and converts them into an array of TaskTargetSetViews, sorted by priority.
     - parameter task: The task whose TaskTargetSets to extract.
     - returns: (Optional) An array of TaskTargetSetViews representing the TaskTargetSets of the provided Task.
     */
    static func extractTTSVArray(_ task: Task) throws -> [TaskTargetSetView]? {
        let sets = try task._targetSets.sorted(by: {$0._priority < $1._priority})
        return try sets.map({
            TaskTargetSetView(type: $0._pattern.type,
                              minTarget: $0._min,
                              minOperator: try $0._minOperator,
                              maxTarget: $0._max,
                              maxOperator: try $0._maxOperator,
                              selectedDaysOfWeek: $0._pattern.daysOfWeek,
                              selectedWeeksOfMonth: $0._pattern.weeksOfMonth,
                              selectedDaysOfMonth: $0._pattern.daysOfMonth)
        })
    }
    
}
