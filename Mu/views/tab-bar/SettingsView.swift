//
//  SettingsView.swift
//  Mu
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        
        NavigationView {
            ScrollView(.vertical, showsIndicators: true, content: {
                HStack(alignment: .center, spacing: 25) {
                    SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation")
                        .frame(width: 100, height: 150, alignment: .center)
                    
                    SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation")
                        .frame(width: 100, height: 150, alignment: .center)
                    
                    SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation")
                        .frame(width: 100, height: 150, alignment: .center)
                }
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 35)
            })
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsViewCard: View {
    
    let maxIconWidth: CGFloat = 50
    let cornerRadius: CGFloat = 3
    let borderThickness: CGFloat = 2
    let cardPadding: CGFloat = 5
    let textPadding: CGFloat = 5
    
    let icon: Image
    let label: String
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            /*
             Given a frame by the parent,
             SettingsViewCard applies modifiers in the following order to the label Text View:
             - Limited to 1 line
             - Scaled down to no lower than 10% of the original size
             - Scaled to fit the new frame
             - Layout priority is set to 1 so that the Text can use as much height as it needs
             Additionally, SettingsViewCard applies the following modifiers to the icon:
             - Set frame height to remainder of VStack after label's height has been claculated
             - Set maxWidth to 50 and aspect ratio to fit in frame
             */
            GeometryReader { gr in
                HStack {
                    Spacer()
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: maxIconWidth, minHeight: gr.size.height, maxHeight: gr.size.height)
                    Spacer()
                }
            }
            
            Text(label)
                .padding(EdgeInsets(top: 0, leading: textPadding, bottom: textPadding, trailing: textPadding))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .layoutPriority(1)
            
        }
        .foregroundColor(.white)
        .padding(cardPadding)
        .border(Color.white, width: borderThickness)
        .cornerRadius(cornerRadius)
        
    }
    
}
