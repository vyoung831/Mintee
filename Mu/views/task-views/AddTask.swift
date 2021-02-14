//
//  AddTask.swift
//  Mu
//
//  Created by Vincent Young on 4/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import UIKit
import Firebase

struct AddTask: View {
    
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
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    private func saveTask() -> Bool {
        
        var tagObjects: Set<Tag> = Set()
        var taskTargetSets: [TaskTargetSet] = []
        
        do {
            
            for idx in 0 ..< self.tags.count {
                let tag = try Tag.getOrCreateTag(tagName: self.tags[idx])
                tagObjects.insert(tag)
            }
            
            switch self.taskType {
            case .recurring:
                for i in 0 ..< taskTargetSetViews.count {
                    let ttsv = taskTargetSetViews[i]
                    let tts = try TaskTargetSet(entity: TaskTargetSet.entity(), insertInto: CDCoordinator.moc,
                                                min: ttsv.minTarget, max: ttsv.maxTarget,
                                                minOperator: ttsv.minOperator, maxOperator: ttsv.maxOperator,
                                                priority: Int16(i),
                                                pattern: DayPattern(dow: Set((ttsv.selectedDaysOfWeek ?? [])),
                                                                    wom: Set((ttsv.selectedWeeksOfMonth ?? [])),
                                                                    dom: Set((ttsv.selectedDaysOfMonth ?? []))))
                    taskTargetSets.append(tts)
                }
                
                let _ =  try Task(entity: Task.entity(),
                                  insertInto: CDCoordinator.moc,
                                  name: self.taskName,
                                  tags: tagObjects,
                                  startDate: self.startDate,
                                  endDate: self.endDate,
                                  targetSets: Set(taskTargetSets))
                break
            case .specific:
                let _ = try Task(entity: Task.entity(),
                                 insertInto: CDCoordinator.moc,
                                 name: self.taskName,
                                 tags: tagObjects,
                                 dates: self.dates)
                break
            }
            
        } catch {
            self.errorMessage = ErrorManager.unexpectedErrorMessage
            CDCoordinator.moc.rollback()
            return false
        }
        
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            self.errorMessage = "Save failed. Please check if another Task with this name already exists"
            CDCoordinator.moc.rollback()
            return false
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: true, content: {
                VStack(alignment: .leading, spacing: 15, content: {
                    
                    // MARK: - Task name text field
                    
                    LabelAndTextFieldSection(label: "Task name",
                                             labelIdentifier: "task-name-label",
                                             textField: self.$taskName,
                                             textFieldIdentifier: "task-name-text-field")
                    if (errorMessage.count > 0) {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibility(identifier: "add-task-error-message")
                    }
                    
                    // MARK: - Tags
                    
                    TagsSection(label: "Tags",
                                tags: self.$tags)
                    
                    // MARK: - Task type
                    
                    SaveFormatterSelectionSection<SaveFormatter.taskType>(sectionLabel: "Task type",
                                                                          options: SaveFormatter.taskType.allCases,
                                                                          selection: self.$taskType)
                    
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
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                
                leading: Button(action: {
                    
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
                    }
                    
                }, label: {
                    Text("Save")
                })
                .foregroundColor(.accentColor)
                .accessibility(identifier: "add-task-save-button")
                .disabled(self.taskName == ""),
                
                trailing: Button(action: {
                    self.isBeingPresented = false
                }, label: {
                    Text("Cancel")
                })
                .foregroundColor(.accentColor)
                
            )
            .background(themeManager.panel)
            .foregroundColor(themeManager.panelContent)
            
        }
        .accentColor(themeManager.accent)
        
    }
}
