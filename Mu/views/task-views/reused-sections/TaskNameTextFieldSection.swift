//
//  TaskNameTextFieldSection.swift
//  Mu
//
//  Text field for entering task name, re-used in AddTask and EditTask
//
//  Created by Vincent Young on 7/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TaskNameTextFieldSection: View {
    
    @Binding var taskName: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5, content: {
            Text("Task name")
                .bold()
                .accessibility(identifier: "task-name-label")
            TextField("Task name", text: self.$taskName)
                .foregroundColor(.primary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibility(identifier: "task-name-text-field")
                .accessibility(label: Text("Name"))
                .accessibility(hint: Text("Enter the task name here"))
                .accessibility(value: Text(taskName))
        })
    }
    
}
