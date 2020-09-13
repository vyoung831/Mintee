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
    @State var tags: [String] = []
    
    // For recurring Tasks
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var taskTargetSetViews: [TaskTargetSetView] = []
    
    // For specific Tasks
    @State var dates: [Date] = []
    
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
                                                        dom: Set((ttsv.selectedDaysOfMonth ?? []).map{ SaveFormatter.getDayOfMonthInt($0) })))
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
                         targetSets: Set(taskTargetSets))
            break
        case .specific:
            let _ = Task(entity: Task.entity(),
                         insertInto: CDCoordinator.moc,
                         name: self.taskName,
                         tags: self.tags,
                         dates: self.dates)
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
                        
                        switch self.taskType {
                        case .recurring:
                            if self.taskTargetSetViews.count < 1 {
                                self.errorMessage = "Please add one or more target sets"; return
                            }
                        case .specific:
                            if self.dates.count < 1 {
                                self.errorMessage = "Please add one or more dates"; return
                            }
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
                
                TagsSection(tags: self.$tags)
                
                // MARK: - Task type
                
                TaskTypeSection(taskTypes: self.taskTypes, taskType: self.$taskType)
                
                // MARK: - Dates
                
                if self.taskType == .recurring {
                    StartAndEndDateSection(startDate: self.$startDate,
                                           endDate: self.$endDate)
                } else {
                    SelectDatesSection(dates: self.$dates)
                }
                
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
