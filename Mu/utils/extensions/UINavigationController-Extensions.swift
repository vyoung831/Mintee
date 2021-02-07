//
//  UINavigationController+Extensions.swift
//  Mu
//
//  Extension to UINavigationController to set navbar background and text when
//  - View is loaded
//  - themeChanged Notification is posted
//  TO-DO: More doc
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
