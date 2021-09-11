//
//  SettingsView.swift
//  Mintee
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(PresentationOption.theme.rawValue) var theme: String = ThemeManager.getUserDefaultsTheme().rawValue
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    ForEach(PresentationOption.allCases, id: \.self) { option in
                        NavigationLink(option.rawValue, destination: UserDefaultsListView(option: option.rawValue,
                                                                                          values: SettingsView.getPossibleOptions(option: option),
                                                                                          savedValue: self.getUserDefaultBinding(option)))
                    }
                }
                Section(header: Text("Accounts")) {
                    NavigationLink("Linked calendars",
                                   destination: SettingsLinkedCalendarsView().environment(\.managedObjectContext, CDCoordinator.moc))
                }
            }
            .background(themeManager.panel)
            .navigationTitle(Text("Settings"))
            .navigationBarItems(leading: SyncIndicator())
        }
        .accentColor(themeManager.accent)
        
    }
}

// MARK: - UserDefaults and appearance settings functionality

extension SettingsView {
    
    enum PresentationOption: String, CaseIterable {
        case theme = "Theme"
    }
    
    /**
     Given a value of type PresentationOption, returns all possible raw values for that option's enumeration
     - parameter key: PresentationOption to retrieve possible values for
     - returns: Array of all possible raw values for the PresentationOption
     */
    static func getPossibleOptions(option: PresentationOption) -> [String] {
        switch option {
        case .theme:
            return ThemeManager.Theme.allCases.map{ $0.rawValue }
        }
    }
    
    /**
     Given a PresentationOption option, returns a binding to the appropriate UserDefaults value
     - parameter option: PresentationOption to look up UserDefaults Binding value for
     - returns: Binding to UserDefaults value for the given PresentationOption
     */
    func getUserDefaultBinding(_ option: PresentationOption) -> Binding<String> {
        switch option {
        case .theme:
            return self.$theme
        }
    }
    
}
