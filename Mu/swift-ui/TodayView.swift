//
//  TodayView.swift
//  Mu
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TodayView: View {
    
    @State var isPresentingAddTask: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Task.entity(), sortDescriptors: []) var tasks: FetchedResults<Task>
    
    private func getTagString(task:Task) -> String? {
        if let tags = task.tags as? Set<Tag> {
            let tagNames = tags.map({$0.tagName ?? ""})
            let returnString = tagNames.joined(separator: ",")
            return returnString
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(tasks,id: \.self) {task in
                    VStack {
                        Text("Task name = " + (task.taskName ?? "Unknown task name"))
                        Text("Task tags = " + (self.getTagString(task: task) ?? "No tags"))
                        Text("Task type = " + (task.taskType ?? "No task type"))
                    }
                }
                Text("Number of tasks = " + String(tasks.count))
            }
            .navigationBarTitle("Today")
            .navigationBarItems(trailing: HStack(alignment: .center, spacing: 0, content: {
                
                Button(action: {
                    self.isPresentingAddTask = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .frame(width: 30, height: 30, alignment: .center)
                }).sheet(isPresented: $isPresentingAddTask) {
                    // TO-DO: Don't pass moc environment property after Apple has fixed this bug with modally presented views
                    AddTask(isBeingPresented: self.$isPresentingAddTask).environment(\.managedObjectContext, self.moc)
                }
                
                Button(action: {}) {
                    Image(systemName: "calendar").frame(width: 30, height: 30, alignment: .center)
                }
                
            })
                .foregroundColor(.black)
                .scaleEffect(1.5)
            )
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
