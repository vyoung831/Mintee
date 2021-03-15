//
//  SetCountPopupHostingController.swift
//  Mintee
//
//  Created by Vincent Young on 10/26/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

class SetCountPopupHostingController: UIHostingController<SetCountPopup> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(count: Float,
         done: @escaping ((Float) -> Void),
         cancel: @escaping (() -> Void)) {
        super.init(rootView: SetCountPopup(count: String(count.clean), done: done, cancel: cancel))
    }
    
    override init?(coder aDecoder: NSCoder, rootView: SetCountPopup) {
        super.init(coder: aDecoder, rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
