//
//  ThemeManager.swift
//  Mu
//
//  ThemeManager is used to hold the latest theme values from UserDefaults
//  At app startup, SceneDelegate injects a shared instance of ThemeManager that SwiftUI Views can retrieve theme variables from
//  The shared ThemeManager is registered with UserDefaults to observe the keyPath "Theme". Changes to "Theme" in UserDefaults result in update to @Published variables of type Color.
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
        case panel = "panel"
        case panelContent = "panelContent"
        case collectionItem = "collectionItem"
        case collectionItemBorder = "collectionItemBorder"
        case collectionItemContent = "collectionItemContent"
    }
    
    // MARK: - Observed/shared objects and properties
    
    static var shared: ThemeManager = {
        let tms = ThemeManager()
        tms.observeUserDefaults()
        return tms
    }()
    
    // Published variables to be used by Views. Views that interact with ThemeManager should read from the Published Colors, and save to UserDefaults by setting theme.
    @Published var panelColor: Color
    @Published var panelContentColor: Color
    @Published var collectionItemColor: Color
    @Published var collectionItemBorderColor: Color
    @Published var collectionItemContentColor: Color
    @Published var theme: String {
        didSet {
            UserDefaults.standard.setValue(theme,
                                           forKey: SettingsPresentationView.PresentationOption.theme.rawValue)
        }
    }
    
    // MARK: - Initializers
    
    /**
     Initializes ThemeManager with
     - @Published theme set to the String value of the Theme enum that's saved in UserDefaults
     - @Published Colors set by theme
     */
    override init() {
        var savedTheme: Theme = .system
        if let savedThemeKey = UserDefaults.standard.string(forKey: SettingsPresentationView.PresentationOption.theme.rawValue) {
            savedTheme = ThemeManager.Theme.init(rawValue: savedThemeKey) ?? .system
        }
        self.theme = savedTheme.rawValue
        
        panelColor = ThemeManager.getElementColor(.panel, savedTheme)
        panelContentColor = ThemeManager.getElementColor(.panelContent, savedTheme)
        collectionItemColor = ThemeManager.getElementColor(.collectionItem, savedTheme)
        collectionItemBorderColor = ThemeManager.getElementColor(.collectionItemBorder, savedTheme)
        collectionItemContentColor = ThemeManager.getElementColor(.collectionItemContent, savedTheme)
        super.init()
    }
    
    // MARK: - UserDefaults observation
    
    private func observeUserDefaults() {
        UserDefaults.standard.addObserver(self, forKeyPath: SettingsPresentationView.PresentationOption.theme.rawValue, options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
    }
    
    /**
     Given a new value for "Theme" in UserDefaults, updates this class' Published Colors
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let unwrappedChanges = change else { return }
        if let newKey = unwrappedChanges[.newKey] as? String {
            if let newTheme = ThemeManager.Theme.init(rawValue: newKey) {
                panelColor = ThemeManager.getElementColor(.panel, newTheme)
                panelContentColor = ThemeManager.getElementColor(.panelContent, newTheme)
                collectionItemColor = ThemeManager.getElementColor(.collectionItem, newTheme)
                collectionItemBorderColor = ThemeManager.getElementColor(.collectionItemBorder, newTheme)
                collectionItemContentColor = ThemeManager.getElementColor(.collectionItemContent, newTheme)
            } else {
                print("ThemeManager observed a change to \"Theme\" in UserDefaults that could not be converted to a value of type Theme")
            }
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
            return .clear
        }
    }
    
}
