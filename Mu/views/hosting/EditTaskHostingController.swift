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
    
    init(task: Task, dismiss: @escaping (() -> Void)) {
        
        // Construct array of TaskTargetSetViews for EditTask to use (if Task is of type recurring)
        var ttsvArray: [TaskTargetSetView] = []
        if let ttsArray = task.targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for tts in ttsArray {
                
                guard let pattern = tts.pattern as? DayPattern else {
                    print("EditTaskHostingController could not read pattern from a TaskTargetSet \(tts.debugDescription)"); exit(-1)
                }
                
                let ttsv = TaskTargetSetView(type: pattern.type,
                                             minTarget: tts.min,
                                             minOperator: SaveFormatter.getOperatorString(tts.minOperator),
                                             maxTarget: tts.max,
                                             maxOperator: SaveFormatter.getOperatorString(tts.maxOperator),
                                             selectedDaysOfWeek: Set(tts.getDaysOfWeek().map{ SaveFormatter.getWeekdayString(weekday: $0) }),
                                             selectedWeeksOfMonth: Set(tts.getWeeksOfMonth().map{ SaveFormatter.getWeekOfMonthString(wom: $0) }),
                                             selectedDaysOfMonth: Set(tts.getDaysOfMonth().map{ String($0) }))
                ttsvArray.append(ttsv)
                
            }
        }
        
        // TO-DO: Add startDate and endDate getters and setters to Task
        let taskType = SaveFormatter.storedToTaskType(storedType: task.taskType)
        switch taskType {
        case .recurring:
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
            let editTask = EditTask(task: task,
                                    dismiss: dismiss,
                                    taskName: task.name ?? "",
                                    taskType: taskType,
                                    tags: task.getTagNames().sorted{$0 < $1})
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
