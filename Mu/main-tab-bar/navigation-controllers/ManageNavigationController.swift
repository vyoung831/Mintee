//
//  ManageNavigationController.swift
//  Mu
//
//  Created by Vincent Young on 4/4/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit

class ManageNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers.removeAll()
        self.pushViewController(ManageViewController(), animated: false)
        self.navigationBar.backgroundColor = UIColor.white
        self.navigationBar.isTranslucent = false
    }

}
