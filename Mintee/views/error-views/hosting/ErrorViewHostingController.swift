//
//  ErrorViewHostingController.swift
//  Mu
//
//  Created by Vincent Young on 12/31/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

class ErrorViewHostingController: UIHostingController<ErrorView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init() {
        super.init(rootView: ErrorView())
    }
    
    override init?(coder aDecoder: NSCoder, rootView: ErrorView) {
        super.init(coder: aDecoder, rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
