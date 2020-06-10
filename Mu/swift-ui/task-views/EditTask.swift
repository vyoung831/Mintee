//
//  EditTask.swift
//  Mu
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct EditTask: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    let taskTypes: [String] = ["Recurring","Specific"]
    
    var task: Task
    var dismiss: (() -> Void)
    @State var isPresentingSelectStartDatePopup: Bool = false
    @State var isPresentingSelectEndDatePopup: Bool = false
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    @State var saveFailed: Bool = false
    @State var deleteFailed: Bool = false
    @State var taskName: String
    @State var tags: [String]
    @State var startDate: Date
    @State var endDate: Date
    @State var taskTargetSetViews: [TaskTargetSetView] = []
    
    private func saveTask() -> Bool {
        task.name = self.taskName
        task.updateTags(newTagNames: self.tags)
        task.updateDates(startDate: self.startDate, endDate: self.endDate)
        
        var taskTargetSets: [TaskTargetSet] = []
        for i in 0 ..< taskTargetSetViews.count {
            let ttsv = taskTargetSetViews[i]
            let tts = TaskTargetSet(entity: TaskTargetSet.entity(),
                                    insertInto: CDCoordinator.moc,
                                    min: ttsv.minTarget,
                                    max: ttsv.maxTarget,
                                    minOperator: SaveFormatter.getOperatorNumber(ttsv.minOperator),
                                    maxOperator: SaveFormatter.getOperatorNumber(ttsv.maxOperator),
                                    priority: Int16(i),
                                    pattern: DayPattern(dow: ttsv.selectedDaysOfWeek.map{ SaveFormatter.getWeekdayNumber(weekday: $0) },
                                                        wom: ttsv.selectedWeeksOfMonth.map{ SaveFormatter.getWeekOfMonthNumber(wom: $0) },
                                                        dom: ttsv.selectedDaysOfMonth.map{ Int16($0) ?? 0 }))
            taskTargetSets.append(tts)
        }
        
        task.updateTaskTargetSets(targetSets: taskTargetSets)
        
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            return false
        }
    }
    
    private func deleteTask() -> Bool {
        task.deleteSelf()
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            return false
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 15, content: {
                
                // MARK: - Title and buttons
                
                HStack {
                    Button(action: {
                        if self.saveTask() {
                            self.dismiss()
                        } else {
                            // Display failure message in UI if saveTask() failed
                            self.saveFailed = true
                        }
                    }, label: {
                        Text("Save")
                    }).disabled(self.taskName == "")
                    Spacer()
                    
                    Text("Edit Task")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    Button(action: {
                        CDCoordinator.moc.rollback()
                        self.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                // MARK: - Task name text field
                
                VStack (alignment: .leading, spacing: 5, content: {
                    Text("Task name")
                        .bold()
                    TextField(task.name ?? "", text: self.$taskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if (self.saveFailed) {
                        Text("Save failed")
                            .foregroundColor(.red)
                    }
                })
                
                // MARK: - Tags
                Group {
                    HStack {
                        Text("Tags")
                            .bold()
                        Image(systemName: "plus")
                    }
                    ForEach(self.tags,id: \.description) { tag in
                        Text(tag)
                            .padding(.all, 8)
                            .foregroundColor(.white)
                            .background(Color.black)
                    }
                }
                
                // MARK: - Task type
                
                Group {
                    Text("Task Type")
                        .bold()
                    ForEach(taskTypes,id: \.description) { taskType in
                        Text(taskType)
                    }
                }
                
                // MARK: - Dates
                
                Group {
                    Text("Dates")
                        .bold()
                    
                    Button(action: {
                        self.isPresentingSelectStartDatePopup = true
                    }, label: {
                        Text(startDateLabel + self.startDate.toMYD())
                    }).popover(isPresented: self.$isPresentingSelectStartDatePopup, content: {
                        SelectDatePopup.init(
                            isBeingPresented: self.$isPresentingSelectStartDatePopup,
                            startDate: self.$startDate,
                            endDate: self.$endDate,
                            isStartDate: true,
                            label: "Select Start Date")
                    })
                    
                    Button(action: {
                        self.isPresentingSelectEndDatePopup = true
                    }, label: {
                        Text(endDateLabel + self.endDate.toMYD())
                    }).popover(isPresented: self.$isPresentingSelectEndDatePopup, content: {
                        SelectDatePopup.init(
                            isBeingPresented: self.$isPresentingSelectEndDatePopup,
                            startDate: self.$startDate,
                            endDate: self.$endDate,
                            isStartDate: false,
                            label: "Select End Date")
                    })
                }
                
                // MARK: - Target sets
                
                Group {
                    
                    HStack {
                        Text("Target Sets")
                            .bold()
                        Button(action: {
                            self.isPresentingAddTaskTargetSetPopup = true
                        }, label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                                .foregroundColor(Color("default-panel-icon-colors"))
                        }).sheet(isPresented: self.$isPresentingAddTaskTargetSetPopup, content: {
                            AddTaskTargetSetPopup.init(ttsViews: self.$taskTargetSetViews,
                                                       isBeingPresented: self.$isPresentingAddTaskTargetSetPopup)
                        })
                    }
                    
                    VStack {
                        ForEach(0 ..< taskTargetSetViews.count, id: \.self) { idx in
                            TaskTargetSetView(minTarget: self.taskTargetSetViews[idx].minTarget,
                                              minOperator: self.taskTargetSetViews[idx].minOperator,
                                              maxTarget: self.taskTargetSetViews[idx].maxTarget,
                                              maxOperator: self.taskTargetSetViews[idx].maxOperator,
                                              selectedDaysOfWeek: self.taskTargetSetViews[idx].selectedDaysOfWeek,
                                              selectedWeeksOfMonth: self.taskTargetSetViews[idx].selectedWeeksOfMonth,
                                              selectedDaysOfMonth: self.taskTargetSetViews[idx].selectedDaysOfMonth,
                                              moveUp: { if idx > 0 {self.taskTargetSetViews.swapAt(idx, idx - 1)} },
                                              moveDown: { if idx < self.taskTargetSetViews.count - 1 {self.taskTargetSetViews.swapAt(idx, idx + 1)} },
                                              delete: { self.taskTargetSetViews.remove(at: idx) })
                        }
                    }
                }
                
                // MARK: - Task deletion
                
                Group {
                    Button(action: {
                        if self.deleteTask() {
                            self.dismiss()
                        } else {
                            self.deleteFailed = true
                        }
                    }, label: {
                        Text("Delete Task")
                            .padding(.all, 10)
                            .background(Color.red)
                            .foregroundColor(.white)
                    })
                    
                    if (self.deleteFailed) {
                        Text("Delete failed")
                            .foregroundColor(.red)
                    }
                }
                
            })
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)) // VStack insets
        })
    }
}
