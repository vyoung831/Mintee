//
//  ActivityIndicator.swift
//  Mintee
//
//  Created by Vincent Young on 9/10/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: View {
    
    @ObservedObject var themeManager = ThemeManager.shared
    let style = StrokeStyle(lineWidth: 3, lineCap: .round)
    let spinTime: Double = 1
    
    var text: String = ""
    @State var animate = false
    
    var body: some View {
        
        HStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(style: self.style)
                .rotation(Angle(degrees: animate ? 360 : 0))
                .animation(Animation.linear(duration: spinTime).repeatForever(autoreverses: false))
                .foregroundColor(themeManager.panelContent)
            Text(self.text)
        }
        .onAppear(){
            self.animate = true
        }
        
    }
    
}
