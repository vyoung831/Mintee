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
    
    var taskTypes: [SaveFormatter.taskType]
    @Binding var taskType: SaveFormatter.taskType
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 7) {
            
            Text("Task Type")
                .bold()
            
            ForEach(0 ..< self.taskTypes.count, id: \.self) { idx in
                Button(self.taskTypes[idx].stringValue, action: {
                    self.taskType = self.taskTypes[idx]
                })
                .padding(12)
                .foregroundColor(self.taskTypes[idx] == self.taskType ? themeManager.buttonText : themeManager.panelContent)
                .background(self.taskTypes[idx] == self.taskType ? themeManager.button : Color.clear )
                .cornerRadius(3)
            }
            
        }
        
    }
    
}
