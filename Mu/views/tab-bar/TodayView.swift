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
    
    var body: some View {
        NavigationView {
            TodayCollectionViewControllerRepresentable()
                .navigationBarTitle("Today")
                .navigationBarItems(trailing: HStack(alignment: .center, spacing: 0, content: {
                    Button(action: {
                        self.isPresentingAddTask = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(Color("default-panel-icon-colors"))
                            .accessibility(identifier: "add-task-button")
                            .accessibility(label: Text("Add button"))
                            .accessibility(hint: Text("Tap to add a new task"))
                    })
                    
                    Button(action: {}) {
                        Image(systemName: "calendar").frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(Color("default-panel-icon-colors"))
                    }
                })
                    .foregroundColor(.black)
                    .scaleEffect(1.5)
            )
        }
        .sheet(isPresented: $isPresentingAddTask, content:  {
            AddTask(isBeingPresented: self.$isPresentingAddTask)
        })
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
