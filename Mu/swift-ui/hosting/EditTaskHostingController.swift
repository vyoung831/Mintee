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
        
        // Construct array of TaskTargetSetViews for EditTask to use
        var ttsvArray: [TaskTargetSetView] = []
        if let ttsArray = task.targetSets?.sortedArray(using: [NSSortDescriptor(key: "priority", ascending: true)]) as? [TaskTargetSet] {
            for tts in ttsArray {
                
                // TO-DO: Confirm that this for-in loop goes through ttsArray sequentially
                let ttsv = TaskTargetSetView(target: "ET Target",
                                             selectedDaysOfWeek: tts.getDaysOfWeek().map{ SaveFormatter.getWeekdayString(weekday: $0) },
                                             selectedWeeksOfMonth: tts.getWeeksOfMonth().map{ Int($0) },
                                             selectedDaysOfMonth: tts.getDaysOfMonth().map{ String($0) })
                ttsvArray.append(ttsv)
            }
        }
        
        // TO-DO: Obtain the Task from the TaskInstance provided by TodayCollectionViewController; then, construct the EditTask View
        if let startDateString = task.startDate, let endDateString = task.endDate {
            if let startDate = SaveFormatter.storedStringToDate(startDateString), let endDate = SaveFormatter.storedStringToDate(endDateString) {
                let editTask = EditTask(task: task,
                                        dismiss: dismiss,
                                        taskName: task.name ?? "",
                                        tags: task.getTagNamesArray(),
                                        startDate: startDate,
                                        endDate: endDate,
                                        taskTargetSets: ttsvArray)
                super.init(rootView: editTask)
            } else {
                print("Task's start and/or end date was stored in an incompatible format")
                exit(-1)
            }
        } else {
            print("Nil value found in Task's dates")
            exit(-1)
        }
    }
    
    override init?(coder aDecoder: NSCoder, rootView: EditTask) {
        super.init(coder: aDecoder, rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
