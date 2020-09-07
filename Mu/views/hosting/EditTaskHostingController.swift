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
        if let ttsArray = task.targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for idx in 0 ..< ttsArray.count {
                
                guard let pattern = ttsArray[idx].pattern as? DayPattern else {
                    print("EditTaskHostingController could not read pattern from a TaskTargetSet \(ttsArray[idx].debugDescription)"); exit(-1)
                }
                
                let ttsv = TaskTargetSetView(type: pattern.type,
                                             minTarget: ttsArray[idx].min,
                                             minOperator: SaveFormatter.getOperatorString(ttsArray[idx].minOperator),
                                             maxTarget: ttsArray[idx].max,
                                             maxOperator: SaveFormatter.getOperatorString(ttsArray[idx].maxOperator),
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
        let taskType = SaveFormatter.storedToTaskType(storedType: task.taskType)
        switch taskType {
        case .recurring:
            
            // Construct array of TaskTargetSetViews for EditTask to use (if Task is of type recurring)
            let ttsvArray: [TaskTargetSetView] = EditTaskHostingController.extractTTSVArray(task: task)
            
            if let startDateString = task.startDate, let endDateString = task.endDate {
                let editTask = EditTask(task: task,
                                        dismiss: dismiss,
                                        taskName: task.name ?? "",
                                        taskType: taskType,
                                        tags: task.getTagNames().sorted{$0 < $1},
                                        startDate: SaveFormatter.storedStringToDate(startDateString),
                                        endDate: SaveFormatter.storedStringToDate(endDateString),
                                        taskTargetSetViews: ttsvArray)
                super.init(rootView: editTask)
            } else {
                print("Nil value found in Task's dates")
                exit(-1)
            }
            break
        case .specific:
            
            var dates: [Date] = []
            guard let instances = task.instances else {
                print("EditTaskHostingController found nil value when accessing Task's instances"); exit(-1)
            }
            for case let instance as TaskInstance in instances {
                if let dateString = instance.date {
                    dates.append(SaveFormatter.storedStringToDate(dateString))
                }
            }
            
            let editTask = EditTask(task: task,
                                    dismiss: dismiss,
                                    taskName: task.name ?? "",
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
