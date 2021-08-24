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
                                   destination: SettingsLinkedAccountsView())
                }
            }
            .background(themeManager.panel)
            .navigationTitle(Text("Settings"))
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

struct SettingsViewCard<Content: View>: View {
    
    let maxIconWidth: CGFloat = 50
    let cardPadding: CGFloat = 5
    let textPadding: CGFloat = 5
    
    let targetView: Content
    let icon: Image
    let label: String
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationLink(destination: self.targetView ) {
            
            VStack(alignment: .center) {
                
                /*
                 Given a frame by the parent,
                 SettingsViewCard applies modifiers in the following order to the label Text View:
                 - Limited to 1 line
                 - Scaled down to no lower than 10% of the original size
                 - Scaled to fit the new frame
                 - Layout priority is set to 1 so that the Text can use as much height as it needs
                 Additionally, SettingsViewCard applies the following modifiers to the icon:
                 - Set frame height to remainder of VStack after label's height has been claculated
                 - Set maxWidth to 50 and aspect ratio to fit in frame
                 */
                GeometryReader { gr in
                    HStack {
                        Spacer()
                        self.icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: self.maxIconWidth, minHeight: gr.size.height, maxHeight: gr.size.height)
                        Spacer()
                    }
                }
                
                Text(label)
                    .bold()
                    .padding(EdgeInsets(top: 0, leading: textPadding, bottom: textPadding, trailing: textPadding))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .scaledToFit()
                    .layoutPriority(1)
                
            }
            .padding(cardPadding)
            .border(themeManager.collectionItemBorder, width: CollectionSizer.borderThickness)
            .foregroundColor(themeManager.collectionItemContent)
            .background(themeManager.collectionItem)
            .cornerRadius(CollectionSizer.cornerRadius)
        }
    }
    
}
