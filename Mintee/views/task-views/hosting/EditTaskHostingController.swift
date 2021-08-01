//
//  EditTaskHostingController.swift
//  Mintee
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
    static func extractTTSVArray(task: Task) throws -> [TaskTargetSetView] {
        var ttsvArray: [TaskTargetSetView] = []
        // TO-DO: Implement something more robust to replace TaskTargetSet sorting using hard-coded key
        if let ttsArray = task._targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                
                /*
                 If the TaskTargetSet's minOperator and/or maxOperator can't be instantiated as enums, an error is reported with the Task, the TTS, and the Task's other TTSes
                 */
                guard let minOperator = SaveFormatter.storedToEqualityOperator(ttsArray[idx]._minOperator),
                      let maxOperator = SaveFormatter.storedToEqualityOperator(ttsArray[idx]._maxOperator) else {
                    let userInfo: [String : Any] = ["Message" : "EditTaskHostingController.extractTTSVArray() found invalid _minOperator or _maxOperator in a TaskTargetSet",
                                                    "TaskTargetSet" : ttsArray[idx]]
                    let error = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
                    throw error
                }
                
                let pattern = ttsArray[idx]._pattern
                guard let selectedDow = Set( pattern.daysOfWeek.map{ SaveFormatter.storedToDayOfWeek($0) }) as? Set<SaveFormatter.dayOfWeek>,
                      let selectedWom = Set( pattern.weeksOfMonth.map{ SaveFormatter.storedToWeekOfMonth($0) }) as? Set<SaveFormatter.weekOfMonth>,
                      let selectedDom = Set( pattern.daysOfMonth.map{ SaveFormatter.storedToDayOfMonth($0) }) as? Set<SaveFormatter.dayOfMonth> else {
                    let userInfo: [String : Any] = ["Message" : "EditTaskHostingController.extractTTSVArray() could not convert a TaskTargetSet's dow, wom, and/or dom to Sets of corresponding values that conform to SaveFormatter.Day",
                                                    "TaskTargetSet" : ttsArray[idx]]
                    let error = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
                    throw error
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
    init(task: Task, dismiss: @escaping (() -> Void)) throws {
        
        guard let taskType = SaveFormatter.storedToTaskType(task._taskType) else {
            let userInfo: [String : Any] = ["Message": "EditTaskHostingController.init()? found invalid _taskType in a Task"]
            throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
        }
        
        switch taskType {
        case .recurring:
            
            /*
             Construct array of TaskTargetSetViews for EditTask to use (if Task is of type recurring).
             Nil is returned here and no further debug data is reported because EditTaskHostingController.extractTTSVArray should have already provided needed userInfo to Crashlytics.
             */
            let ttsvArray: [TaskTargetSetView] = try EditTaskHostingController.extractTTSVArray(task: task)
            
            guard let startDateString = task._startDate,
                  let endDateString = task._endDate,
                  let startDate = SaveFormatter.storedStringToDate(startDateString),
                  let endDate = SaveFormatter.storedStringToDate(endDateString) else {
                let userInfo: [String : Any] = ["Message" : "EditTaskHostingController.init()? found a recurring type Task with invalid or nil startDate and/or endDate"]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            }
            
            let editTask = EditTask(isBeingPresented: .constant(true),
                                    dismiss: dismiss,
                                    task: task,
                                    taskName: task._name,
                                    taskType: taskType,
                                    tags: task.getTagNames().sorted{$0 < $1},
                                    startDate: startDate,
                                    endDate: endDate,
                                    taskTargetSetViews: ttsvArray)
            super.init(rootView: editTask)
            
            break
        case .specific:
            
            var dates: [Date] = []
            guard let instances = task._instances else {
                let userInfo: [String : Any] = ["Message" : "EditTaskHostingController.init()? found nil in specific-type Task's _instances"]
                throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            }
            for case let instance as TaskInstance in instances {
                
                guard let date = SaveFormatter.storedStringToDate(instance._date) else {
                    let userInfo: [String : Any] = ["Message" : "EditTaskHostingController.init()? found a TaskInstance with a nil or invalid date belonging to a specific type task",
                                                    "TaskInstance" : instance]
                    throw ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
                }
                dates.append(date)
                
            }
            
            let editTask = EditTask(isBeingPresented: .constant(true),
                                    dismiss: dismiss,
                                    task: task,
                                    taskName: task._name,
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
