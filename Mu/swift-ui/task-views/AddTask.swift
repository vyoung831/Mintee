//
//  AddTask.swift
//  Mu
//
//  Created by Vincent Young on 4/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddTask: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    let taskTypes: [String] = ["Recurring","Specific"]
    
    @Binding var isBeingPresented: Bool
    @State var isPresentingSelectStartDatePopup: Bool = false
    @State var isPresentingSelectEndDatePopup: Bool = false
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    @State var isPresentingEditTaskTargetSetPopup: Bool = false
    @State var taskName: String = ""
    @State var errorMessage: String = ""
    @State var tags: [String] = ["Tag1","Tag4","Tag3"]
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var taskTargetSetViews: [TaskTargetSetView] = []
    
    private func saveTask() -> Bool {
        
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
                                    pattern: DayPattern(dow: Set((ttsv.selectedDaysOfWeek ?? []).map{ SaveFormatter.getWeekdayNumber(weekday: $0) }),
                                                        wom: Set((ttsv.selectedWeeksOfMonth ?? []).map{ SaveFormatter.getWeekOfMonthNumber(wom: $0) }),
                                                        dom: Set((ttsv.selectedDaysOfMonth ?? []).map{ Int16($0) ?? 0 })))
            taskTargetSets.append(tts)
        }
        
        let newTask = Task(entity: Task.entity(),
                           insertInto: CDCoordinator.moc,
                           name: self.taskName,
                           tags: self.tags,
                           startDate: self.startDate,
                           endDate: self.endDate,
                           targetSets: taskTargetSets)
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            CDCoordinator.moc.rollback()
            return false
        }
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 15, content: {
                
                // MARK: - Title and buttons
                
                HStack {
                    Button(action: {
                        
                        if self.taskTargetSetViews.count < 1 { self.errorMessage = "Please add one or more target sets"; return }
                        
                        if self.saveTask() {
                            self.isBeingPresented = false
                        } else {
                            // Display failure message in UI if saveTask() failed
                            self.errorMessage = "Save failed. Please check if another Task with this name already exists"
                        }
                    }, label: {
                        Text("Save")
                    }).disabled(self.taskName == "")
                    Spacer()
                    
                    Text("Add Task")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    Button(action: {
                        self.isBeingPresented = false
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                // MARK: - Task name text field
                
                VStack (alignment: .leading, spacing: 5, content: {
                    Text("Task name")
                        .bold()
                    TextField("Task name", text: self.$taskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if (errorMessage.count > 0) {
                        Text(errorMessage)
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
                
                Group{
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
                            TaskTargetSetPopup.init(title: "Add Target Set",
                                                    selectedDaysOfWeek: Set<String>(),
                                                    selectedWeeks: Set<String>(),
                                                    selectedDaysOfMonth: Set<String>(),
                                                    isBeingPresented: self.$isPresentingAddTaskTargetSetPopup,
                                                    save: { ttsv in self.taskTargetSetViews.append(ttsv) })
                        })
                    }
                    
                    VStack {
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
                                                            minValue: String(self.taskTargetSetViews[idx].minTarget.clean),
                                                            maxValue: String(self.taskTargetSetViews[idx].maxTarget.clean),
                                                            isBeingPresented: self.$isPresentingEditTaskTargetSetPopup,
                                                            save: { ttsv in self.taskTargetSetViews[idx] = ttsv})})
                            
                        }
                    }
                }
                
            }).padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)) // VStack insets
        })
    }
}

struct AddTask_Previews: PreviewProvider {
    static var previews: some View {
        AddTask(isBeingPresented: .constant(true))
    }
}
