//
//  TodayView.swift
//  Mintee
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
        
        guard let daysToToday = date.daysToDate(Date()) else {
            let userInfo: [String : Any] = ["Message" : "TodayView.getLabel() received nil return from call to Date.daysToDate()",
                                            "date" : date.debugDescription,
                                            "Date()" : Date().debugDescription,
                                            "Calendar.current" : Calendar.current.debugDescription]
            ErrorManager.recordNonFatal(.dateOperationFailed, userInfo)
            return Date.toMDYPresent(date)
        }
        
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
                .accentColor(themeManager.accent)
                .navigationBarTitle(self.getLabel())
                .navigationBarItems(trailing: HStack(alignment: .center, spacing: 0, content: {
                    Button(action: {
                        self.isPresentingAddTask = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(themeManager.panelContent)
                            .accessibility(identifier: "add-task-button")
                    })
                    .sheet(isPresented: $isPresentingAddTask, content:  {
                        AddTask(isBeingPresented: self.$isPresentingAddTask)
                    })
                    
                    Button(action: {
                        self.isPresentingSelectDate = true
                    }) {
                        Image(systemName: "calendar")
                            .frame(width: 30, height: 30, alignment: .center)
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
        .accentColor(themeManager.accent)
        
    }
}
