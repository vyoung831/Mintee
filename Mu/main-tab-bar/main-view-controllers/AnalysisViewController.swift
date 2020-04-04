//
//  AnalysisViewController.swift
//  Mu
//
//  This UIViewController handles the presentation of the initial page of the Analysis tab of TabBarController. It is the first UIViewController pushed onto the navigation stack of AnalysisNavigationController
//
//  Created by Vincent Young on 4/4/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController {

    // Constants
    let navbarTitle: String = "Analysis"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupView()
        setupSubviews()
    }

    func setupNavbar() {
        self.navigationItem.title = navbarTitle
    }
    
    func setupView() {
        
    }
    
    func setupSubviews() {
        
    }

}
