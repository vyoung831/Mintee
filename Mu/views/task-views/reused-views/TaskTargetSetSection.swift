//
//  TaskTargetSetSection.swift
//  Mu
//
//  Section for presenting TaskTargetSets, re-used by AddTask and EditTask
//
//  Created by Vincent Young on 7/11/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TaskTargetSetSection: View {
    
    @Binding var taskTargetSetViews: [TaskTargetSetView]
    
    @State var isPresentingEditTaskTargetSetPopup: Bool = false
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("Target Sets")
                    .bold()
                
                Button(action: {
                    self.isPresentingAddTaskTargetSetPopup = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(themeManager.panelContent)
                        .accessibility(identifier: "add-task-target-set-button")
                        .accessibility(label: Text("Add"))
                        .accessibility(hint: Text("Tap to add a target set"))
                }).sheet(isPresented: self.$isPresentingAddTaskTargetSetPopup, content: {
                            TaskTargetSetPopup.init(title: "Add Target Set",
                                                    isBeingPresented: self.$isPresentingAddTaskTargetSetPopup,
                                                    save: { ttsv in self.taskTargetSetViews.append(ttsv) })})
            }
            
            ForEach(0 ..< taskTargetSetViews.count, id: \.self) { idx in
                TaskTargetSetView(type: self.taskTargetSetViews[idx].type,
                                  minTarget: self.taskTargetSetViews[idx].minTarget,
                                  minOperator: self.taskTargetSetViews[idx].minOperator,
                                  maxTarget: self.taskTargetSetViews[idx].maxTarget,
                                  maxOperator: self.taskTargetSetViews[idx].maxOperator,
                                  selectedDaysOfWeek: self.taskTargetSetViews[idx].selectedDaysOfWeek,
                                  selectedWeeksOfMonth: self.taskTargetSetViews[idx].selectedWeeksOfMonth,
                                  selectedDaysOfMonth: self.taskTargetSetViews[idx].selectedDaysOfMonth,
                                  moveUp: { if idx > 0 {self.taskTargetSetViews.swapAt(idx, idx - 1)} },
                                  moveDown: { if idx < self.taskTargetSetViews.count - 1 {self.taskTargetSetViews.swapAt(idx, idx + 1)} },
                                  edit: { self.isPresentingEditTaskTargetSetPopup = true },
                                  delete: { self.taskTargetSetViews.remove(at: idx) })
                    .sheet(isPresented: self.$isPresentingEditTaskTargetSetPopup, content: {
                            TaskTargetSetPopup.init(title: "Edit Target Set",
                                                    selectedDaysOfWeek: self.taskTargetSetViews[idx].selectedDaysOfWeek ?? Set<String>(),
                                                    selectedWeeks: self.taskTargetSetViews[idx].selectedWeeksOfMonth ?? Set<String>(),
                                                    selectedDaysOfMonth: self.taskTargetSetViews[idx].selectedDaysOfMonth ?? Set<String>(),
                                                    type: self.taskTargetSetViews[idx].type,
                                                    minOperator: self.taskTargetSetViews[idx].minOperator,
                                                    maxOperator: self.taskTargetSetViews[idx].maxOperator,
                                                    minValueString: String(self.taskTargetSetViews[idx].minTarget.clean),
                                                    maxValueString: String(self.taskTargetSetViews[idx].maxTarget.clean),
                                                    isBeingPresented: self.$isPresentingEditTaskTargetSetPopup,
                                                    save: { ttsv in self.taskTargetSetViews[idx] = ttsv})})
                
            }
            
        }
    }
}
