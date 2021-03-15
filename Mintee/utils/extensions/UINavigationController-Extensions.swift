//
//  UINavigationController+Extensions.swift
//  Mintee
//
//  This extension handles color theme updates to navbars throughout the project, in both SwiftUI and UIKit components. The navbar background and text is updated when
//  1. viewDidLoad() is called
//  2. The .themeChanged Notification is posted
//
//  Due to lack of official Apple documentation, the following resources were used to implement this solution:
//  - Using UINavigationBarAppearance to update SwiftUI navbars: https://medium.com/@francisco.gindre/customizing-swiftui-navigation-bar-8369d42b8805
//  - Refreshing navbar appearances: https://stackoverflow.com/questions/39066126/how-to-properly-refresh-a-uinavigationbar
//
//  Created by Vincent Young on 10/18/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        observeNotificationCenter()
        updateTheme()
    }
    
    private func observeNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
    }
    
    @objc func updateTheme(){
        let updatedAppearance = UINavigationBarAppearance()
        updatedAppearance.backgroundColor = UIColor(ThemeManager.shared.panel)
        updatedAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(ThemeManager.shared.panelContent)]
        updatedAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(ThemeManager.shared.panelContent)]
        
        self.navigationBar.standardAppearance = updatedAppearance
        self.navigationBar.scrollEdgeAppearance = updatedAppearance
        
        self.navigationBar.setNeedsLayout()
        self.navigationBar.layoutIfNeeded()
    }
    
}
