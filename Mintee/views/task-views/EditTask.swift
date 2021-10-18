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
        
        guard let type = SaveFormatter.storedToTaskType(task._taskType) else {
            let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                                task.mergeDebugDictionary("EditTask.init() found a Task with an _taskType that could not be converted to valid in-memory form."))
            NotificationCenter.default.post(name: .editTask_initFailed, object: nil)
            return
        }
        
        switch type {
        case .recurring:
            if let recurringProperties = EditTask.getRecurringProperties(task) {
                self._startDate = State(initialValue: recurringProperties.startDate)
                self._endDate = State(initialValue: recurringProperties.endDate)
                self._taskTargetSetViews = State(initialValue: recurringProperties.ttsvArray)
            } else {
                NotificationCenter.default.post(name: .editTask_initFailed, object: nil)
                return
            }
            break
        case .specific:
            if let specificDates = EditTask.getSpecificDates(task) {
                self._dates = State(initialValue: specificDates)
            } else {
                NotificationCenter.default.post(name: .editTask_initFailed, object: nil)
                return
            }
            break
        }
        
        self._taskName = State(initialValue: task._name)
        self._tags = State(initialValue: Array(task.getTagNames()))
        self._taskType = State(initialValue: type)
        self.task = task
        
    }
    
    /**
     Update the Task's relationships and saves it.
     Since this function may be called as part of a completion handler, View dismissal is performed in this function.
     */
    private func saveTask() {
        
        guard let unwrappedTask = self.task else { return }
        
        var tagObjects: Set<Tag> = Set()
        let childContext = CDCoordinator.getChildContext()
        if let childTask = childContext.object(with: unwrappedTask.objectID) as? Task {
            childContext.perform {
                do {
                    for idx in 0 ..< self.tags.count {
                        let tag = try Tag.getOrCreateTag(tagName: self.tags[idx], childContext)
                        tagObjects.insert(tag)
                    }
                    childTask.updateTags(newTags: tagObjects, childContext)
                    
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
                    try childContext.save()
                    try CDCoordinator.mainContext.save()
                    return
                } catch {
                    CDCoordinator.mainContext.rollback()
                    NotificationCenter.default.post(name: .taskUpdateFailed, object: nil)
                    let _ = ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                        ["Message" : "EditTask.saveTask() failed to save changes",
                                                         "error.localizedDescription" : error.localizedDescription])
                    return
                }
            }
        } else {
            let _ = ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                ["Message" : "EditTask.saveTask() failed to retrieve a Task in a child MOC"])
            NotificationCenter.default.post(name: .taskUpdateFailed, object: nil)
            return
        }
        
        // Dismiss this `EditTask` View
        self.isBeingPresented.wrappedValue = false
        
    }
    
    private func deleteTask() {
        let childContext = CDCoordinator.getChildContext()
        if let unwrappedTask = self.task,
           let childTask = childContext.object(with: unwrappedTask.objectID) as? Task {
            childContext.perform {
                do {
                    try childTask.deleteSelf(childContext)
                    try childContext.save()
                    try CDCoordinator.mainContext.save()
                } catch {
                    childContext.rollback()
                    NotificationCenter.default.post(name: .taskDeleteFailed, object: nil)
                }
            }
        } else {
            NotificationCenter.default.post(name: .taskDeleteFailed, object: nil)
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
        
        var ttsvArray: [TaskTargetSetView]
        do {
            ttsvArray = try EditTask.extractTTSVArray(task)
        } catch {
            return nil
        }
        
        guard let startDateString = task._startDate,
              let endDateString = task._endDate,
              let startDate = SaveFormatter.storedStringToDate(startDateString),
              let endDate = SaveFormatter.storedStringToDate(endDateString) else {
                  ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                              task.mergeDebugDictionary("EditTask.getRecurringProperties() found nil startDate and/or endDate for a recurring-type task, or could not convert them to Dates."))
                  return nil
              }
        
        return (startDate, endDate, ttsvArray)
        
    }
    
    /**
     Unwraps and returns the dates of TaskInstances associated with the provided Task (assumes task is specific-type).
     If instances are nil, an instance's date is nil, or an instance's date cannot be converted to a Date object, nil is returned.
     - returns: (Optional) Array of Dates representing the dates of TaskInstances associated with the provided Task.
     */
    static func getSpecificDates(_ task: Task) -> [Date]? {
        
        // TO-DO: Implement something more robust to replace TaskTargetSet sorting using hard-coded key
        guard let instances = task._instances?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as? [TaskInstance] else {
            var userInfo: [String : Any] = ["Message" : "EditTask.getSpecificDates() could not convert a specific-type Task's _instances to an array of TaskInstance",
                                            "Task._instances" : task._instances]
            task.mergeDebugDictionary(userInfo: &userInfo)
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
        }
        
        var dates: [Date] = []
        for instance in instances {
            guard let date = SaveFormatter.storedStringToDate(instance._date) else {
                ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                            ["Message" : "ManageViewCard.getSpecificDates() found nil in a TaskInstance's _date or could not convert it to a valid Date",
                                             "TaskInstance._date" : instance._date])
                return nil
            }
            dates.append(date)
        }
        
        return dates
        
    }
    
    /**
     Extracts the TaskTargetSets associated with a Task and converts them into an array of TaskTargetSetViews, sorted by priority.
     - parameter task: The task whose TaskTargetSets to extract.
     - returns: (Optional) An array of TaskTargetSetViews representing the TaskTargetSets of the provided Task. Returns nil if invalid data is found in the TaskTargetSets.
     */
    static func extractTTSVArray(_ task: Task) throws -> [TaskTargetSetView] {
        var ttsvArray: [TaskTargetSetView] = []
        // TO-DO: Implement something more robust to replace TaskTargetSet sorting using hard-coded key
        if let ttsArray = task._targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                
                /*
                 If the TaskTargetSet's minOperator and/or maxOperator can't be instantiated as enums, an error is reported with the Task, the TTS, and the Task's other TTSes
                 */
                guard let minOperator = ttsArray[idx]._minOperator,
                      let maxOperator = ttsArray[idx]._maxOperator else {
                          var userInfo: [String : Any] = ["Message" : "EditTaskHostingController.extractTTSVArray() found invalid _minOperator or _maxOperator in a TaskTargetSet",
                                                          "TaskTargetSet" : ttsArray[idx]]
                          task.mergeDebugDictionary(userInfo: &userInfo)
                          throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
                      }
                
                let pattern = ttsArray[idx]._pattern
                guard let selectedDow = Set( pattern.daysOfWeek.map{ SaveFormatter.storedToDayOfWeek($0) }) as? Set<SaveFormatter.dayOfWeek>,
                      let selectedWom = Set( pattern.weeksOfMonth.map{ SaveFormatter.storedToWeekOfMonth($0) }) as? Set<SaveFormatter.weekOfMonth>,
                      let selectedDom = Set( pattern.daysOfMonth.map{ SaveFormatter.storedToDayOfMonth($0) }) as? Set<SaveFormatter.dayOfMonth> else {
                          var userInfo: [String : Any] = ["Message" : "EditTaskHostingController.extractTTSVArray() could not convert a TaskTargetSet's dow, wom, and/or dom to Sets of corresponding values that conform to SaveFormatter.Day",
                                                          "TaskTargetSet" : ttsArray[idx]]
                          task.mergeDebugDictionary(userInfo: &userInfo)
                          throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
                      }
                
                let ttsv = TaskTargetSetView(type: pattern.type,
                                             minTarget: ttsArray[idx]._min,
                                             minOperator: minOperator,
                                             maxTarget: ttsArray[idx]._max,
                                             maxOperator: maxOperator,
                                             selectedDaysOfWeek: selectedDow,
                                             selectedWeeksOfMonth: selectedWom,
                                             selectedDaysOfMonth: selectedDom)
                ttsvArray.append(ttsv)
                
            }
        }
        return ttsvArray
    }
    
}
