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
    let deleteMessage: String = "Because you changed your target sets, you will lose data from the following dates. Are you sure you want to continue?"
    
    var task: Task
    var dismiss: (() -> Void)
    @State var datesToDelete: [String] = []
    @State var isPresentingSelectStartDatePopup: Bool = false
    @State var isPresentingSelectEndDatePopup: Bool = false
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    @State var isPresentingConfirmDeletePopup: Bool = false
    @State var saveFailed: Bool = false
    @State var deleteFailed: Bool = false
    @State var taskName: String
    @State var tags: [String]
    @State var startDate: Date
    @State var endDate: Date
    @State var taskTargetSetViews: [TaskTargetSetView] = []
    
    private func saveTask() {
        
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
                                    pattern: DayPattern(dow: Set(ttsv.selectedDaysOfWeek.map{ SaveFormatter.getWeekdayNumber(weekday: $0) }),
                                                        wom: Set(ttsv.selectedWeeksOfMonth.map{ SaveFormatter.getWeekOfMonthNumber(wom: $0) }),
                                                        dom: Set(ttsv.selectedDaysOfMonth.map{ Int16($0) ?? 0 })))
            taskTargetSets.append(tts)
        }
        
        task.updateTaskTargetSets(targetSets: taskTargetSets)
        
        do {
            try CDCoordinator.moc.save()
            self.dismiss()
        } catch {
            self.saveFailed = true
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
                        
                        /*
                         Creates a Set of DayPatterns to first call Task.getDeltaInstances with.
                         If count > 0, the new TaskTargetSets would result in existing TaskInstances being deleted, so ConfirmDeletePopup is presented with the closure to call saveTask() if the user selects yes
                         Otherwise, no TaskInstances would be deleted and saveTask is called directly
                         */
                        var dayPatterns: Set<DayPattern> = Set()
                        for tts in self.taskTargetSetViews {
                            
                            // AddTaskTargetSetPopup only sets dows, woms, and doms based on the type, so there's no need to check the TaskTargetSet type again here
                            let dp = DayPattern(dow: Set(tts.selectedDaysOfWeek.map{SaveFormatter.getWeekdayNumber(weekday: $0)}),
                                                wom: Set(tts.selectedWeeksOfMonth.map{SaveFormatter.getWeekOfMonthNumber(wom: $0)}),
                                                dom: Set(tts.selectedDaysOfMonth.map{ Int16($0) ?? 0 }))
                            dayPatterns.insert(dp)
                        }
                        self.datesToDelete = self.task.getDeltaInstances(startDate: self.startDate, endDate: self.endDate, dayPatterns: dayPatterns)
                        if self.datesToDelete.count > 0 { self.isPresentingConfirmDeletePopup = true }
                        else { self.saveTask() }
                        
                    }, label: {
                        Text("Save")
                    })
                        .disabled(self.taskName == "")
                        .sheet(isPresented: self.$isPresentingConfirmDeletePopup, content: {
                            ConfirmDeletePopup(deleteMessage: self.deleteMessage,
                                               deleteList: self.datesToDelete,
                                               delete: self.saveTask,
                                               isBeingPresented: self.$isPresentingConfirmDeletePopup)
                        })
                    
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
                        Text(startDateLabel + Date.toMYD(self.startDate))
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
                        Text(endDateLabel + Date.toMYD(self.endDate))
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
                            TaskTargetSetPopup.init(isBeingPresented: self.$isPresentingAddTaskTargetSetPopup,
                                                       save: { ttsv in self.taskTargetSetViews.append(ttsv) })})
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
