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
    @State var isPresentingSelectDate: Bool = false
    
    @State var date: Date = Date()
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    func getLabel() -> String {
        let daysToToday = date.daysToDate(Date())
        switch daysToToday {
        case 0:
            return "Today"
        case -1:
            return "Tomorrow"
        case 1:
            return "Yesterday"
        default:
            return Date.toMDYPresent(date)
        }
    }
    
    var body: some View {
        NavigationView {
            TodayCollectionViewControllerRepresentable(date: self.$date)
                .navigationBarTitle(self.getLabel())
                .navigationBarItems(trailing: HStack(alignment: .center, spacing: 0, content: {
                    Button(action: {
                        self.isPresentingAddTask = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(themeManager.panelContent)
                            .accessibility(identifier: "add-task-button")
                            .accessibility(label: Text("Add button"))
                            .accessibility(hint: Text("Tap to add a new task"))
                    })
                    .sheet(isPresented: $isPresentingAddTask, content:  {
                        AddTask(isBeingPresented: self.$isPresentingAddTask)
                    })
                    
                    Button(action: {
                        self.isPresentingSelectDate = true
                    }) {
                        Image(systemName: "calendar").frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(themeManager.panelContent)
                    }
                    .sheet(isPresented: $isPresentingSelectDate, content:  {
                        SelectDatePopup(isBeingPresented: self.$isPresentingSelectDate, date: self.$date, label: "Select Date")
                    })
                })
                .foregroundColor(themeManager.panelContent)
                .scaleEffect(1.5)
                )
        }
        
    }
}
