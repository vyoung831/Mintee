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
     Extracts the TaskTargetSets associated with a Task and converts them into an array of TaskTargetSetViews
     The Array's TaskTargetSetViews are sorted by priority
     parm task:
     */
    static func extractTTSVArray(task: Task) -> [TaskTargetSetView] {
        var ttsvArray: [TaskTargetSetView] = []
        if let ttsArray = task._targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                
                guard let pattern = ttsArray[idx]._pattern as? DayPattern else {
                    Crashlytics.crashlytics().log("EditTaskHostingController could not read pattern from a TaskTargetSet \(ttsArray[idx].debugDescription)")
                    Crashlytics.crashlytics().setCustomValue(ttsvArray[idx], forKey: "TaskTargetSet")
                    fatalError()
                }
                
                let ttsv = TaskTargetSetView(type: pattern.type,
                                             minTarget: ttsArray[idx]._min,
                                             minOperator: SaveFormatter.getOperatorString(ttsArray[idx]._minOperator),
                                             maxTarget: ttsArray[idx]._max,
                                             maxOperator: SaveFormatter.getOperatorString(ttsArray[idx]._maxOperator),
                                             selectedDaysOfWeek: Set(ttsArray[idx].getDaysOfWeek().map{ SaveFormatter.getWeekdayString(weekday: $0) }),
                                             selectedWeeksOfMonth: Set(ttsArray[idx].getWeeksOfMonth().map{ SaveFormatter.getWeekOfMonthString(wom: $0) }),
                                             selectedDaysOfMonth: Set(ttsArray[idx].getDaysOfMonth().map{ String($0) }))
                ttsvArray.append(ttsv)
                
            }
        }
        return ttsvArray
    }
    
    init(task: Task, dismiss: @escaping (() -> Void)) {
        
        // TO-DO: Add startDate and endDate getters and setters to Task
        let taskType = SaveFormatter.storedToTaskType(storedType: task._taskType)
        switch taskType {
        case .recurring:
            
            // Construct array of TaskTargetSetViews for EditTask to use (if Task is of type recurring)
            let ttsvArray: [TaskTargetSetView] = EditTaskHostingController.extractTTSVArray(task: task)
            
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
