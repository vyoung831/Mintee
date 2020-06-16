//
//  MainTabBarView.swift
//  Mu
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct MainTabBarView: View {
    var body: some View {
        TabView {
            AnalysisView().tabItem {
                Text("Analysis")
            }
            ManageView().tabItem {
                Text("Manage")
            }
            TodayView().tabItem {
                Text("Today")
            }
            SettingsView().tabItem {
                Text("Settings")
            }
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
