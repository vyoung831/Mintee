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
        // TO-DO: Obtain the Task from the TaskInstance provided by TodayCollectionViewController; then, construct the EditTask View
        if let startDateString = task.startDate, let endDateString = task.endDate {
            if let startDate = Date.storedStringToDate(storedString: startDateString), let endDate = Date.storedStringToDate(storedString: endDateString) {
                let editTask = EditTask(task: task,
                                        dismiss: dismiss,
                                        taskName: task.name ?? "",
                                        tags: task.getTagNamesArray(),
                                        startDate: startDate,
                                        endDate: endDate)
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
