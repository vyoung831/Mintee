//
//  MainTabBarController.swift
//  Mu
//
//  This UITabBarController handles the embedding of the application's main UIViewControllers. This expects to be the first controller presented at startup in AppDelegate.swift.
//
//  Created by Vincent Young on 4/4/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let viewControllers = [AnalysisNavigationController(),ManageNavigationController(),TodayNavigationController(),SettingsNavigationController()]
        setViewControllers(viewControllers, animated: true)
        
        tabBar.items?[0].title = "Analysis"
        tabBar.items?[1].title = "Manage"
        tabBar.items?[2].title = "Today"
        tabBar.items?[3].title = "Settings"
        
        tabBar.isTranslucent = false
    }

}
