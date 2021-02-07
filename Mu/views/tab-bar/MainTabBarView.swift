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
            SettingsView().tabItem {
                Text("Settings")
            }
        }
    }
}
