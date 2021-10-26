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
    
    func taskType() -> SaveFormatter.taskType? {
        do {
            return try self.task._taskType
        } catch {
            return nil
        }
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 10) {
            
            if let taskType = taskType() {
                
                Group {
                    HStack {
                        Text(task._name)
                        Spacer()
                        Button("Edit", action: {
                            self.isPresentingEditTask = true
                        }).foregroundColor(.primary)
                    }
                    
                    HStack {
                        if taskType == .recurring {
                            if let recurringProperties = EditTask.getRecurringProperties(self.task) {
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
                    EditTask(task: task, presented: self.$isPresentingEditTask)
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
