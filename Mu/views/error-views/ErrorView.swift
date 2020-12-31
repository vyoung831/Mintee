//
//  ErrorView.swift
//  Mu
//
//  Created by Vincent Young on 12/28/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack {
            Text("Oops! Something went wrong. The cows are hard at work fixing it!")
        }
        .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
        
    }
}
