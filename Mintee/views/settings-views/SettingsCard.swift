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
                .bold()
                .padding(EdgeInsets(top: 0, leading: textPadding, bottom: textPadding, trailing: textPadding))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .layoutPriority(1)
            
        }
        .padding(cardPadding)
        .border(themeManager.collectionItemBorder, width: CollectionSizer.borderThickness)
        .foregroundColor(themeManager.collectionItemContent)
        .background(themeManager.collectionItem)
        .cornerRadius(CollectionSizer.cornerRadius)
    }
    
}
