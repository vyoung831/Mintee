//
//  SyncIndicator.swift
//  Mintee
//
//  Created by Vincent Young on 9/11/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct SyncIndicator: View {
    
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var eventManager = EventsCalendarManager.shared
    
    var body: some View {
        
        HStack {
            if eventManager.storeAuthStatus(.event) == .authorized {
                Image(systemName: "calendar")
            }
            
            if EventsCalendarManager.shared.storeAuthStatus(.reminder) == .authorized {
                if eventManager.isSyncing {
                    ActivityIndicator()
                } else {
                    Image(systemName: "list.bullet")
                }
            }
        }
        
    }
}
