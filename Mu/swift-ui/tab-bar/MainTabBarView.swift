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
            TodayView().tabItem {
                Text("Today")
            }
            AnalysisView().tabItem {
                Text("Analysis")
            }
            ManageView().tabItem {
                Text("Manage")
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
