//
//  AddTask.swift
//  Mu
//
//  Created by Vincent Young on 4/13/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

struct AddTask: View {
    
    var dates: [String] = ["Start Date: ","End Date: "]
    var taskTypes: [String] = ["Recurring","Specific"]
    
    @Binding var isBeingPresented: Bool
    @State var taskName: String = "Task name"
    @State var tags: [String] = ["Tag1","Tag2"]
    @State var taskType: String = ""
    @State var startDate: Date = Date(timeIntervalSinceNow: 0)
    @State var endDate: Date = Date(timeIntervalSinceNow: 86400)
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .leading, spacing: 15, content: {
                
                HStack {
                    Button(action: {
                        self.isBeingPresented = false
                    }, label: {
                        Text("Save")
                    })
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
                
                Text("Task name")
                    .bold()
                TextField("Task name", text: self.$taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
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
                
                Text("Task Type")
                    .bold()
                ForEach(taskTypes,id: \.description) { taskType in
                    Button(action: {
                        self.taskType = taskType
                    }, label: {
                        Text(taskType)
                            .padding(.all, 5)
                            .foregroundColor(self.taskType == taskType ? .white : .black)
                            .background(self.taskType == taskType ? Color.black : Color.white)
                    })
                }
                
                Text("Dates")
                    .bold()
                ForEach(dates,id: \.description) {date in
                    Text(date +
                        (date == "Start Date: " ? self.startDate.getMYD() : self.endDate.getMYD())
                    )
                }
                
                Text("Target Sets")
                    .bold()
                
            })
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        })
    }
}

struct AddTask_Previews: PreviewProvider {
    static var previews: some View {
        AddTask(isBeingPresented: .constant(true))
    }
}
