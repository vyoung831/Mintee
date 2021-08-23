//
//  SettingsLinkedAccountsView.swift
//  Mintee
//
//  Created by Vincent Young on 8/23/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsLinkedAccountsView: View {
    
    @State var showingAlert: Bool = false
    
    var body: some View {
        Group {
            Button("Link to Apple Calendar", action: { EventsCalendarManager.shared.requestAccess(completion: { accessGranted, error in
                if !accessGranted {
                    self.showingAlert = true
                }
            })})
            .alert(isPresented: self.$showingAlert) {
                Alert(title: Text("Access to Calendar is Restricted"),
                      message: Text("To re-enable, please go to Settings and turn on Calendar Settings"))
            }
        }
        .navigationTitle(Text("Linked accounts"))
    }
    
}
