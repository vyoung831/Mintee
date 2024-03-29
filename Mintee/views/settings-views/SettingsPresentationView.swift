//
//  SettingsPresentationView.swift
//  Mintee
//
//  Created by Vincent Young on 9/20/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsPresentationView: View {
    
    // MARK: - Color Theme
    
    @AppStorage(PresentationOption.theme.rawValue) var theme: String = ThemeManager.getUserDefaultsTheme().rawValue
    
    // MARK: - Presentation Settings
    
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
    
    var body: some View {
        
        List(SettingsPresentationView.PresentationOption.allCases, id: \.self) { option in
            NavigationLink(option.rawValue,
                           destination: UserDefaultsListView(option: option.rawValue,
                                                             values: SettingsPresentationView.getPossibleOptions(option: option),
                                                             savedValue: self.getUserDefaultBinding(option)))
        }
        .navigationTitle(Text("Presentation Settings"))
        
    }
    
}
