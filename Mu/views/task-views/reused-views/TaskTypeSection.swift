//
//  TaskTypeSection.swift
//  Mu
//
//  Section for presenting task type selection, re-used by AddTask and EditTask
//
//  Created by Vincent Young on 7/22/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import SwiftUI

struct TaskTypeSection: View {
    
    var taskTypes: [String]
    @Binding var taskTypeIndex: Int
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 7) {
            
            Text("Task Type")
                .bold()
            
            ForEach(0 ..< self.taskTypes.count, id: \.self) { idx in
                Button(taskTypes[idx], action: {
                    self.taskTypeIndex = idx
                })
                .padding(12)
                .foregroundColor(self.taskTypeIndex == idx ? Color("default-button-text-colors") : Color("default-disabled-text-colors"))
                .background(self.taskTypeIndex == idx ? Color("default-button-colors") : Color.clear )
                .cornerRadius(3)
            }
            
        }
        
    }
    
}
