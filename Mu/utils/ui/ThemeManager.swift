//
//  ThemeManager.swift
//  Mu
//
//  A shared instance of ThemeManager is used to hold themed colors, and informs other objects when the theme saved to NSUserDefaults changes.
//  When "Theme" is updated in UserDefaults, the shared ThemeManager does the following:
//  - Updates Published properties. SwiftUI Views that declare ThemeManager.shared with the @ObservedObject property wrapper will update their Views. Due to SwiftUI bugs, SwiftUI Views should define ThemeManager.shared as an @ObservedObject instead of using @EnvironmentObject
//  - Posts a .themeChanged Notification. Non-SwiftUI components can read from the Published properties upon observing the notification.
//
//  Created by Vincent Young on 10/10/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit
import SwiftUI

class ThemeManager: NSObject, ObservableObject {
    
    // MARK: - UI Element and Theme enums
    
    enum Theme: String, CaseIterable {
        case system = "System Default"
        case jungle = "Jungle"
        case ocean = "Ocean"
    }
    
    enum ThemedUIElement: String, CaseIterable {
        case accent = "accent"
        case panel = "panel"
        case panelContent = "panelContent"
        case button = "button"
        case buttonText = "buttonText"
        case textFieldBorder = "textFieldBorder"
        case disabledTextField = "disabledTextField"
        case disabledTextFieldText = "disabledTextFieldText"
        case collectionItem = "collectionItem"
        case collectionItemBorder = "collectionItemBorder"
        case collectionItemContent = "collectionItemContent"
    }
    
    // MARK: - Shared instance and observable properties
    
    static var shared: ThemeManager = {
        let tms = ThemeManager()
        tms.observeUserDefaults()
        return tms
    }()
    
    @Published var accent: Color
    
    @Published var panel: Color
    @Published var panelContent: Color
    
    @Published var button: Color
    @Published var buttonText: Color
    
    @Published var textFieldBorder: Color
    @Published var disabledTextField: Color
    @Published var disabledTextFieldText: Color
    
    @Published var collectionItem: Color
    @Published var collectionItemBorder: Color
    @Published var collectionItemContent: Color
    
    // MARK: - Initializers
    
    /**
     Initializes ThemeManager with
     - @Published theme set to the String value of the Theme enum that's saved in UserDefaults
     - @Published Colors set by theme
     */
    override init() {
        let savedTheme = ThemeManager.getUserDefaultsTheme()
        self.accent = ThemeManager.getElementColor(.accent, savedTheme)
        self.panel = ThemeManager.getElementColor(.panel, savedTheme)
        self.panelContent = ThemeManager.getElementColor(.panelContent, savedTheme)
        self.button = ThemeManager.getElementColor(.button, savedTheme)
        self.buttonText = ThemeManager.getElementColor(.buttonText, savedTheme)
        self.textFieldBorder = ThemeManager.getElementColor(.textFieldBorder, savedTheme)
        self.disabledTextField = ThemeManager.getElementColor(.disabledTextField, savedTheme)
        self.disabledTextFieldText = ThemeManager.getElementColor(.disabledTextFieldText, savedTheme)
        self.collectionItem = ThemeManager.getElementColor(.collectionItem, savedTheme)
        self.collectionItemBorder = ThemeManager.getElementColor(.collectionItemBorder, savedTheme)
        self.collectionItemContent = ThemeManager.getElementColor(.collectionItemContent, savedTheme)
        super.init()
    }
    
    // MARK: - UserDefaults observation
    
    private func observeUserDefaults() {
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: SettingsPresentationView.PresentationOption.theme.rawValue,
                                          options: [NSKeyValueObservingOptions.new,
                                                    NSKeyValueObservingOptions.old],
                                          context: nil)
    }
    
    /**
     Given a new value for "Theme" in UserDefaults, updates this class' @Published Color vars.
     */
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if keyPath == SettingsPresentationView.PresentationOption.theme.rawValue {
            
            guard let unwrappedChanges = change,
                  let newKey = unwrappedChanges[.newKey] as? String,
                  let newTheme = ThemeManager.Theme.init(rawValue: newKey) else {
                ErrorManager.recordNonFatal(.userDefaults_observedInvalidUpdate,
                                            ["Message" : "ThemeManager.observeValue() could not convert observed change to value of type ThemeManager.Theme",
                                             "keyPath" : keyPath?.debugDescription,
                                             "change" : change?.debugDescription])
                return
            }
            
            self.accent = ThemeManager.getElementColor(.accent, newTheme)
            self.panel = ThemeManager.getElementColor(.panel, newTheme)
            self.panelContent = ThemeManager.getElementColor(.panelContent, newTheme)
            self.button = ThemeManager.getElementColor(.button, newTheme)
            self.buttonText = ThemeManager.getElementColor(.buttonText, newTheme)
            self.textFieldBorder = ThemeManager.getElementColor(.textFieldBorder, newTheme)
            self.disabledTextField = ThemeManager.getElementColor(.disabledTextField, newTheme)
            self.disabledTextFieldText = ThemeManager.getElementColor(.disabledTextFieldText, newTheme)
            self.collectionItem = ThemeManager.getElementColor(.collectionItem, newTheme)
            self.collectionItemBorder = ThemeManager.getElementColor(.collectionItemBorder, newTheme)
            self.collectionItemContent = ThemeManager.getElementColor(.collectionItemContent, newTheme)
            NotificationCenter.default.post(name: .themeChanged, object: nil)
            
        }
        
    }
    
    // MARK: - Utility functions
    
    /**
     Returns the Color to be set for a UI element, depending on the current Theme value in UserDefaults
     - parameter element: Value of type ThemedUIElement
     - returns: Color to set the ThemedUIElement to
     */
    static func getElementColor(_ element: ThemedUIElement, _ theme: Theme) -> Color {
        switch theme {
        case .jungle:
            return Color("theme-jungle-\(element.rawValue)")
        case .ocean:
            return Color("theme-ocean-\(element.rawValue)")
        case .system:
            switch element {
            case .panel:
                return .clear
            case .accent:
                return .accentColor
            case .buttonText, .collectionItem:
                return Color(UIColor.systemBackground)
            case .collectionItemBorder:
                return .secondary
            default:
                return .primary
            }
        }
    }
    
    /**
     Returns the Theme based on the current value saved to key "Theme" in UserDefaults. If the current value can't be cast to a Theme, this function sets the value in UserDefaults to Theme.system's rawValue
     - returns: Value currently assigned to key "Theme" in UserDefaults
     */
    static func getUserDefaultsTheme() -> Theme {
        if let savedTheme = UserDefaults.standard.string(forKey: SettingsPresentationView.PresentationOption.theme.rawValue) {
            if let theme = ThemeManager.Theme.init(rawValue: savedTheme) {
                return theme
            } else {
                ErrorManager.recordNonFatal(.userDefaults_containedInvalidValue,
                                            ["Message": "ThemeManager.getUserDefaultsTheme() could not convert the saved theme to a value of type ThemeManager.Theme",
                                             "savedTheme" : savedTheme])
                UserDefaults.standard.setValue(Theme.system.rawValue, forKey: SettingsPresentationView.PresentationOption.theme.rawValue)
                return .system
            }
        }
        return .system
    }
    
}
