//
//  ManageView.swift
//  Mintee
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct ManageView: View {
    
    @FetchRequest(
        // TO-DO: Update NSSortDescriptor to use more robust way to sort Task name
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var tasksFetch: FetchedResults<Task>
    
    @State var isPresentingAddTaskPopup: Bool = false
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            
            GeometryReader { gr in
                
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: [GridItem(.fixed(gr.size.width))]) {
                        ForEach(0 ..< self.tasksFetch.count, id: \.self) { idx in
                            ManageViewCard(task: tasksFetch[idx])
                        }
                    }
                }
                
            }
            .padding(CollectionSizer.gridVerticalPadding)
            .background(themeManager.panel)
            .navigationTitle("Manage")
            .navigationBarItems(trailing:
                                    Button(action: {
                                        self.isPresentingAddTaskPopup = true
                                    }, label: {
                                        Image(systemName: "plus.circle")
                                            .frame(width: 30, height: 30, alignment: .center)
                                            .accessibility(identifier: "add-task-button")
                                    })
                                    .scaleEffect(1.5)
                                    .foregroundColor(themeManager.panelContent)
                                    .sheet(isPresented: self.$isPresentingAddTaskPopup, content:  {
                                        AddTask(isBeingPresented: self.$isPresentingAddTaskPopup)
                                    })
            )
            
        }.accentColor(themeManager.accent)
        
    }
    
}

// MARK: - Struct for representing cards in ManageView

struct ManageViewCard: View {
    
    let cardPadding: CGFloat = 15
    @State var isPresentingEditTask: Bool = false
    
    @ObservedObject var task: Task
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    /**
     Unwraps and returns the observed Task's startDate, endDate, and targetSets (represented as an array of TaskTargetSetView).
     If any of those properties are nil or can't be converted to valid in-memory form, nil is returned.
     - returns: (Optional) Named tuple containing representations of the observed Task's startDate, endDate, and targetSets.
     */
    private func getRecurringProperties() -> (startDate: Date,
                                              endDate: Date,
                                              ttsvArray: [TaskTargetSetView])? {
        
        var ttsvArray: [TaskTargetSetView]
        do {
            ttsvArray = try EditTaskHostingController.extractTTSVArray(task: self.task)
        } catch {
            // No non-fatal is reported because call to extractTTSVArray() would have already reported an error.
            return nil
        }
        
        guard let startDateString = task._startDate,
              let endDateString = task._endDate,
              let startDate = SaveFormatter.storedStringToDate(startDateString),
              let endDate = SaveFormatter.storedStringToDate(endDateString) else {
            let userInfo: [String : Any] = ["Message" : "ManageViewCard.getRecurringProperties() found nil startDate and/or endDate for a recurring-type task, or could not convert them to Dates."]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            return nil
        }
        
        return (startDate, endDate, ttsvArray)
        
    }
    
    /**
     Unwraps and returns the dates of TaskInstances associated with observed Task (assumes task is specific-type).
     If instances are nil, an instance's date is nil, or an instance's date cannot be converted to a Date object, nil is returned.
     - returns: (Optional) Array of Dates representing the dates of TaskInstances associated with the observed Task.
     */
    private func getSpecificDates() -> [Date]? {
        
        // TO-DO: Implement something more robust to replace TaskTargetSet sorting using hard-coded key
        guard let instances = task._instances?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as? [TaskInstance] else {
            let userInfo: [String : Any] = ["Message" : "ManageViewCard.getSpecificDates() could not convert a specific-type Task's _instances to an array of TaskInstance",
                                            "Task._instances" : task._instances ]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, task.mergeDebugDictionary(userInfo: userInfo))
            return nil
        }
        
        var dates: [Date] = []
        for instance in instances {
            guard let date = SaveFormatter.storedStringToDate(instance._date) else {
                ErrorManager.recordNonFatal(.persistentStore_containedInvalidData,
                                            ["Message" : "ManageViewCard.getSpecificDates() found nil in a TaskInstance's _date or could not convert it to a valid Date",
                                             "TaskInstance._date" : instance._date ])
                return nil
            }
            dates.append(date)
        }
        
        return dates
        
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 10) {
            
            if let taskName = task._name,
               let taskType = SaveFormatter.storedToTaskType(task._taskType) {
                
                Group {
                    HStack {
                        Text(taskName)
                        Spacer()
                        Button("Edit", action: {
                            self.isPresentingEditTask = true
                        }).foregroundColor(.primary)
                    }
                    
                    HStack {
                        if taskType == .recurring {
                            if let recurringProperties = self.getRecurringProperties() {
                                Text("\(Date.toMDYPresent(recurringProperties.startDate)) to \(Date.toMDYPresent(recurringProperties.endDate))")
                            } else {
                                Text("Recurring")
                            }
                        } else {
                            Text("Specific")
                        }
                        Spacer()
                    }
                    
                    if task.getTagNames().count > 0 {
                        ScrollView(.horizontal, showsIndicators: false, content: {
                            
                            HStack {
                                ForEach(task.getTagNames().sorted(), id: \.self) { tagName in
                                    TagView(name: tagName, removable: false, remove: {})
                                }
                            }
                            
                        })
                    }
                    
                }.sheet(isPresented: self.$isPresentingEditTask, content: {
                    
                    if taskType == .recurring {
                        
                        if let recurringProperties = self.getRecurringProperties() {
                            EditTask(isBeingPresented: self.$isPresentingEditTask,
                                     dismiss: {},
                                     task: self.task,
                                     taskName: taskName,
                                     taskType: taskType,
                                     tags: task.getTagNames().sorted(),
                                     startDate: recurringProperties.startDate,
                                     endDate: recurringProperties.endDate,
                                     taskTargetSetViews: recurringProperties.ttsvArray)
                        } else {
                            ErrorView()
                        }
                        
                    } else {
                        
                        if let dates = self.getSpecificDates() {
                            EditTask(isBeingPresented: self.$isPresentingEditTask,
                                     dismiss: {},
                                     task: self.task,
                                     taskName: taskName,
                                     taskType: taskType,
                                     tags: task.getTagNames().sorted(),
                                     dates: dates)
                        } else {
                            ErrorView()
                        }
                        
                    }
                    
                })
                
            } else {
                ErrorView()
            }
            
        }
        .padding(cardPadding)
        .background(ThemeManager.getElementColor(.collectionItem, .system))
        .border(themeManager.collectionItemBorder, width: CollectionSizer.borderThickness)
        .cornerRadius(CollectionSizer.cornerRadius)
        .accentColor(themeManager.accent)
        
    }
    
}
