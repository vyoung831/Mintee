//
//  EditTaskHostingController.swift
//  Mu
//
//  This UIHostingController hosts the EditTask View
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import Firebase

class EditTaskHostingController: UIHostingController<EditTask> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /**
     Extracts the TaskTargetSets associated with a Task and converts them into an array of TaskTargetSetViews, sorted by priority.
     - parameter task: The task whose TaskTargetSets to extract.
     - returns: (Optional) An array of TaskTargetSetViews representing the TaskTargetSets of the provided Task. Returns nil if invalid data is found in the TaskTargetSets.
     */
    static func extractTTSVArray(task: Task) -> [TaskTargetSetView]? {
        var ttsvArray: [TaskTargetSetView] = []
        if let ttsArray = task._targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                
                /*
                 If the TaskTargetSet's DayPattern is nil or the TaskTargetSet's minOperator and/or maxOperator violate business logic, an error is reported with the Task, the TTS, and the Task's other TTSes
                 */
                guard let pattern = ttsArray[idx]._pattern else {
                    let userInfo: [String : Any] = ["Message" : "EditTaskHostingController.extractTTSVArray found nil _pattern in a TaskTargetSet",
                                                    "TaskTargetSet" : ttsArray[idx]]
                    ErrorManager.recordNonFatal(.persistentStoreContainedInvalidData,
                                                task.mergeDebugDictionary(userInfo: userInfo))
                    return nil
                }
                
                guard let minOperator = SaveFormatter.storedToEqualityOperator(ttsArray[idx]._minOperator),
                      let maxOperator = SaveFormatter.storedToEqualityOperator(ttsArray[idx]._maxOperator) else {
                    let userInfo: [String : Any] = ["Message" : "EditTaskHostingController.extractTTSVArray found invalid _minOperator or _maxOperator in a TaskTargetSet",
                                                    "TaskTargetSet" : ttsArray[idx]]
                    ErrorManager.recordNonFatal(.persistentStoreContainedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
                    return nil
                }
                
                guard let selectedDow = Set( ttsArray[idx].getDaysOfWeek().map { SaveFormatter.storedToDayOfWeek($0) }) as? Set<SaveFormatter.dayOfWeek>,
                      let selectedWom = Set( ttsArray[idx].getWeeksOfMonth().map { SaveFormatter.storedToWeekOfMonth($0) }) as? Set<SaveFormatter.weekOfMonth>,
                      let selectedDom = Set( ttsArray[idx].getDaysOfMonth().map { SaveFormatter.storedToDayOfMonth($0) }) as? Set<SaveFormatter.dayOfMonth> else {
                    return nil
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
    
    /**
     Failable initializer. Returns nil if any data that is needed by EditTask cannot be converted from persistent store back to valid in-memory form.
     - parameter task: Task for which to initialize an instance of EditTask.
     - parameter dismiss: Escaping closure that is called when EditTask's save or cancel buttons are tapped.
     */
    init?(task: Task, dismiss: @escaping (() -> Void)) {
        
        guard let taskType = SaveFormatter.storedToTaskType(storedType: task._taskType) else {
            let userInfo: [String : Any] = ["Message": "EditTaskHostingController.init? found invalid _taskType in a Task"]
            ErrorManager.recordNonFatal(.persistentStoreContainedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            return nil
        }
        
        switch taskType {
        case .recurring:
            
            // Construct array of TaskTargetSetViews for EditTask to use (if Task is of type recurring)
            guard let ttsvArray: [TaskTargetSetView] = EditTaskHostingController.extractTTSVArray(task: task) else {
                return nil
            }
            
            if let startDateString = task._startDate, let endDateString = task._endDate {
                let editTask = EditTask(task: task,
                                        dismiss: dismiss,
                                        taskName: task._name ?? "",
                                        taskType: taskType,
                                        tags: task.getTagNames().sorted{$0 < $1},
                                        startDate: SaveFormatter.storedStringToDate(startDateString),
                                        endDate: SaveFormatter.storedStringToDate(endDateString),
                                        taskTargetSetViews: ttsvArray)
                super.init(rootView: editTask)
            } else {
                Crashlytics.crashlytics().log("EditTaskHostingController attempted to present a recurring Task that had startDate and/or endDate equal to nil")
                Crashlytics.crashlytics().setCustomValue(task._startDate as Any, forKey: "Start date")
                Crashlytics.crashlytics().setCustomValue(task._endDate as Any, forKey: "End date")
                fatalError()
            }
            break
        case .specific:
            
            var dates: [Date] = []
            guard let instances = task._instances else {
                Crashlytics.crashlytics().log("EditTaskHostingController attempted to present a specific Task that had nil instances")
                fatalError()
            }
            for case let instance as TaskInstance in instances {
                if let dateString = instance._date {
                    dates.append(SaveFormatter.storedStringToDate(dateString))
                }
            }
            
            let editTask = EditTask(task: task,
                                    dismiss: dismiss,
                                    taskName: task._name ?? "",
                                    taskType: taskType,
                                    tags: task.getTagNames().sorted{$0 < $1},
                                    dates: dates.sorted())
            super.init(rootView: editTask)
            break
        }
        
    }
    
    override init?(coder aDecoder: NSCoder, rootView: EditTask) {
        super.init(coder: aDecoder, rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
