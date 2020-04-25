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
                    })
                    
                    Button(action: {}) {
                        Image(systemName: "calendar").frame(width: 30, height: 30, alignment: .center)
                    }
                })
                    .foregroundColor(.black)
                    .scaleEffect(1.5)
            )
        }
        .sheet(isPresented: $isPresentingAddTask, content:  {
            // TO-DO: Don't pass moc environment property after Apple has fixed this bug with modally presented views
            AddTask(isBeingPresented: self.$isPresentingAddTask).environment(\.managedObjectContext, self.moc)
        })
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
