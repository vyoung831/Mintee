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
    
    let icon: Image
    let label: String
    let subtextIcon: Image?
    
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
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .layoutPriority(1)
            
            Spacer()
            if let subIcon = subtextIcon {
                HStack {
                    subIcon
                        .foregroundColor(themeManager.collectionItem)
                }
                .frame(maxWidth: .infinity, minHeight: 0)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5 + CollectionSizer.borderThickness, trailing: 0))
                .background(themeManager.collectionItemContent)
            }
            
        }
        .border(themeManager.collectionItemBorder, width: CollectionSizer.borderThickness)
        .foregroundColor(themeManager.collectionItemContent)
        .background(themeManager.collectionItem)
        .cornerRadius(CollectionSizer.cornerRadius)
    }
    
}
