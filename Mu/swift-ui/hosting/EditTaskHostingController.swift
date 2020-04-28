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
        let editTask = EditTask(task: task, dismiss: dismiss, taskName: task.taskName ?? "", tags: task.getTagNamesArray(), startDate: Date(timeIntervalSinceNow: 0), endDate: Date(timeIntervalSinceNow: 86400))
        super.init(rootView: editTask)
    }
    
    override init?(coder aDecoder: NSCoder, rootView: EditTask) {
        super.init(coder: aDecoder, rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
