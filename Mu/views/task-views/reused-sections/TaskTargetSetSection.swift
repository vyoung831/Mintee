//
//  TaskTargetSetSection.swift
//  Mu
//
//  Section for presenting TaskTargetSetViews, re-used by Task forms such as AddTask and EditTask.
//
//  Created by Vincent Young on 7/11/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TaskTargetSetSection: View {
    
    @Binding var taskTargetSetViews: [TaskTargetSetView]
    
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
                        .accessibility(identifier: "add-task-target-set-button")
                })
                .foregroundColor(themeManager.panelContent)
                .sheet(isPresented: self.$isPresentingAddTaskTargetSetPopup, content: {
                    TaskTargetSetPopup.init(title: "Add Target Set",
                                            isBeingPresented: self.$isPresentingAddTaskTargetSetPopup,
                                            save: {
                                                ttsv in self.taskTargetSetViews.append(ttsv)
                                            })
                })
            }
            
            /*
             Because each TTSV contains buttons for re-ordering priority or deleting itself within the array of TTSVs, closures must be provided to each TTSV that manipulate the array of TTSVs.
             A "second layer" of TTSVs are declared using the binded array's data, plus closures that manipulate the binded array. Any changes to the binding redraws the second layer of TTSVs.
             */
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
                                  update: { ttsv in taskTargetSetViews[idx] = ttsv},
                                  delete: { self.taskTargetSetViews.remove(at: idx) })
            }
            
        }
    }
}
