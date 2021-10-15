//
//  ErrorView.swift
//  Mintee
//
//  Created by Vincent Young on 12/28/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack {
            Text("We're very sorry. Something went wrong. We'll fix this as soon as possible. Please try again later.")
        }
        .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
        
    }
}
