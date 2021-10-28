//
//  TaskTargetSetSection.swift
//  Mintee
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
                    UIUtil.resignFirstResponder()
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
             Because each TTSV contains buttons for re-ordering or deleting itself within the array of TTSVs, closures are provided for each TTSV to manipulate the binded-to TTSV array.
             A "second layer" of TTSVs are declared using the binded array's data, plus closures that manipulate the binded array. Changes to the underlying state (including through this View's binding) redraws the second layer of TTSVs.
             */
            ForEach(taskTargetSetViews) { tts in
                TaskTargetSetView(type: tts.type,
                                  minTarget: tts.minTarget,
                                  minOperator: tts.minOperator,
                                  maxTarget: tts.maxTarget,
                                  maxOperator: tts.maxOperator,
                                  selectedDaysOfWeek: tts.selectedDaysOfWeek,
                                  selectedWeeksOfMonth: tts.selectedWeeksOfMonth,
                                  selectedDaysOfMonth: tts.selectedDaysOfMonth,
                                  moveUp: {
                    if let idx = taskTargetSetViews.firstIndex(where: {$0.id == tts.id}), idx > 0 {
                        taskTargetSetViews.swapAt(idx, idx - 1)
                    } else {
                        let _ = ErrorManager.recordNonFatal(.viewObject_didNotContainExpectedObject,
                                                            ["taskTargetSetViews" : taskTargetSetViews,
                                                             "tts.id" : tts.id])
                    }
                }, moveDown: {
                    if let idx = taskTargetSetViews.firstIndex(where: {$0.id == tts.id}), idx < taskTargetSetViews.count - 1 {
                        taskTargetSetViews.swapAt(idx, idx + 1)
                    } else {
                        let _ = ErrorManager.recordNonFatal(.viewObject_didNotContainExpectedObject,
                                                            ["taskTargetSetViews" : taskTargetSetViews,
                                                             "tts.id" : tts.id])
                    }
                }, update: { ttsv in
                    if let idx = taskTargetSetViews.firstIndex(where: {$0.id == tts.id}) {
                        self.taskTargetSetViews[idx] = ttsv
                    } else {
                        let _ = ErrorManager.recordNonFatal(.viewObject_didNotContainExpectedObject,
                                                            ["taskTargetSetViews" : taskTargetSetViews,
                                                             "tts.id" : tts.id])
                    }
                }, delete: {
                    if let idx = taskTargetSetViews.firstIndex(where: {$0.id == tts.id}) {
                        self.taskTargetSetViews.remove(at: idx)
                    } else {
                        let _ = ErrorManager.recordNonFatal(.viewObject_didNotContainExpectedObject,
                                                            ["taskTargetSetViews" : taskTargetSetViews,
                                                             "tts.id" : tts.id])
                    }
                })
            }
            
        }
    }
}
