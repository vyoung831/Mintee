//
//  AddTask.swift
//  Mu
//
//  Created by Vincent Young on 4/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import UIKit

struct AddTask: View {
    
    let startDateLabel: String = "Start Date: "
    let endDateLabel: String = "End Date: "
    let taskTypes: [SaveFormatter.taskType] = SaveFormatter.taskType.allCases
    
    @Binding var isBeingPresented: Bool
    @State var isPresentingAddTaskTargetSetPopup: Bool = false
    @State var isPresentingEditTaskTargetSetPopup: Bool = false
    @State var taskName: String = ""
    @State var taskType: SaveFormatter.taskType = .recurring
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
        
        switch self.taskType {
        case .recurring:
            let _ = Task(entity: Task.entity(),
                         insertInto: CDCoordinator.moc,
                         name: self.taskName,
                         tags: self.tags,
                         startDate: self.startDate,
                         endDate: self.endDate,
                         targetSets: taskTargetSets)
            break
        case .specific:
            let _ = Task(entity: Task.entity(),
                         insertInto: CDCoordinator.moc,
                         name: self.taskName,
                         tags: self.tags,
                         dates: [])
            break
        }
        
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
                        if self.taskType == .recurring && self.taskTargetSetViews.count < 1 {
                            self.errorMessage = "Please add one or more target sets"; return
                        }
                        
                        if self.saveTask() {
                            self.isBeingPresented = false
                        } else {
                            // Display failure message in UI if saveTask() failed
                            self.errorMessage = "Save failed. Please check if another Task with this name already exists"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                UIAccessibility.post(notification: .announcement, argument: self.errorMessage)
                            }
                        }
                    }, label: {
                        Text("Save")
                            .accessibilityElement(children: .ignore)
                    })
                    .accessibility(label: Text("Save button"))
                    .accessibility(hint: Text("Tap to save new task"))
                    .accessibility(identifier: "add-task-save-button")
                    .disabled(self.taskName == "")
                    
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
                
                TaskNameTextField(taskName: self.$taskName)
                if (errorMessage.count > 0) {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .accessibility(identifier: "add-task-error-message")
                        .accessibility(hidden: true)
                }
                
                // MARK: - Tags
                
                Group {
                    HStack {
                        Text("Tags")
                            .bold()
                            .accessibility(identifier: "tags-section-label")
                            .accessibility(label: Text("Tags"))
                            .accessibility(addTraits: .isHeader)
                        Image(systemName: "plus")
                            .accessibility(identifier: "add-tag-button")
                            .accessibility(label: Text("Add"))
                            .accessibility(hint: Text("Tap to add a tag"))
                        
                    }
                    ForEach(self.tags,id: \.description) { tag in
                        Text(tag)
                            .padding(.all, 8)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .accessibility(identifier: "tag")
                            .accessibility(value: Text("\(tag)"))
                    }
                }
                
                // MARK: - Task type
                
                TaskTypeSection(taskTypes: self.taskTypes, taskType: self.$taskType)
                
                // MARK: - Dates
                
                SelectDateSection(startDate: self.$startDate,
                                  endDate: self.$endDate)
                
                // MARK: - Target sets
                
                if self.taskType == .recurring {
                    TaskTargetSetSection(taskTargetSetViews: self.$taskTargetSetViews)
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
