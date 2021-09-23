//
//  SettingsCard.swift
//  Mintee
//
//  Created by Vincent Young on 8/24/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsCard: View {
    
    let maxIconWidth: CGFloat = 50
    let cardPadding: CGFloat = 5
    let textPadding: CGFloat = 5
    
    let icon: Image
    let label: String
    let subtextIcon: Image?
    let subtext: String?
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            GeometryReader { gr in
                HStack {
                    Spacer()
                    self.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: self.maxIconWidth, minHeight: gr.size.height, maxHeight: gr.size.height)
                    Spacer()
                }
            }
            
            /*
             Given a frame by the parent, SettingsCard applies modifiers to `label` in the following order (after bolding and padding):
             - Limited to 1 line
             - Scaled down to no lower than 10% of the original size
             - Scaled to fit the new frame
             - Layout priority is set to 1 so that the Text can use as much height as it needs
             */
            Text(label)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .layoutPriority(1)
            
            Spacer()
            if let st = subtext {
                HStack {
                    if let subIcon = subtextIcon {
                        subIcon
                            .foregroundColor(.white)
                    }
                    Text(st)
                        .bold()
                        .lineLimit(1)
                        .scaledToFill()
                        .layoutPriority(2)
                }
            }
            Spacer()
            
        }
        .padding(cardPadding)
        .border(themeManager.collectionItemBorder, width: CollectionSizer.borderThickness)
        .foregroundColor(themeManager.collectionItemContent)
        .background(themeManager.collectionItem)
        .cornerRadius(CollectionSizer.cornerRadius)
    }
    
}
