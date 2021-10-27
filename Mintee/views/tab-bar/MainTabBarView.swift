//
//  MainTabBarView.swift
//  Mintee
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct MainTabBarView: View {
    
    var body: some View {
        
        TabView {
            
            AnalysisView().tabItem {
                VStack {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Analysis")
                }
            }.environment(\.managedObjectContext, CDCoordinator.moc)
            
            ManageView().tabItem {
                VStack {
                    Image(systemName: "book")
                    Text("Manage")
                }
            }.environment(\.managedObjectContext, CDCoordinator.moc)
            
            TodayView().tabItem {
                VStack {
                    Image(systemName: "clock")
                    Text("Today")
                }
            }
            
            SettingsView().tabItem {
                VStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
            }
            
        }
        
    }
    
}
