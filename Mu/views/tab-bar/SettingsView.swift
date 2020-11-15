//
//  SettingsView.swift
//  Mu
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    var cards = [SettingsViewCard<SettingsPresentationView>(targetView: SettingsPresentationView(),
                                                            icon: Image(systemName: "paintbrush"),
                                                            label: "Presentation")]
    
    // UI Constants
    let rowSpacing: CGFloat = 20
    let gridVerticalPadding: CGFloat = 25
    let idealItemWidth: CGFloat = 100
    let cardHeightMultiplier: CGFloat = 1.5
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    /**
     Calls CollectionSizer.getVGridLayout with this View's idealItemWidth constant.
     - parameter totalWidth: Total width of View that can be used for sizing items, spacing, and left/right insets.
     - returns: Tuple containing array of GridItem with fixed item widths and spacing, itemWidth, and horizontal insets for the mock collection view.
     */
    private func getMockCollectionLayout(widthAvailable: CGFloat) -> ( grid: [GridItem], itemWidth: CGFloat, leftRightInset: CGFloat) {
        return CollectionSizer.getVGridLayout(widthAvailable: widthAvailable, idealItemWidth: self.idealItemWidth)
    }
    
    var body: some View {
        
        NavigationView {
            GeometryReader { gr in
                
                if gr.size.width > 0 {
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(columns: getMockCollectionLayout(widthAvailable: gr.size.width).grid,
                                  alignment: .center,
                                  spacing: self.rowSpacing) {
                            ForEach(0 ..< self.cards.count, id: \.self) { card in
                                self.cards[card]
                                    .frame(width: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth,
                                           height: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth * self.cardHeightMultiplier,
                                           alignment: .center)
                            }
                        }
                        .padding(EdgeInsets(top: self.gridVerticalPadding,
                                            leading: getMockCollectionLayout(widthAvailable: gr.size.width).leftRightInset,
                                            bottom: self.gridVerticalPadding,
                                            trailing: getMockCollectionLayout(widthAvailable: gr.size.width).leftRightInset))
                    }
                }
            }
            .background(themeManager.panel)
            .navigationTitle(Text("Settings"))
        }
        .accentColor(themeManager.accent)
        
    }
}

struct SettingsViewCard<Content: View>: View {
    
    let maxIconWidth: CGFloat = 50
    let cornerRadius: CGFloat = 5
    let borderThickness: CGFloat = 3
    let cardPadding: CGFloat = 5
    let textPadding: CGFloat = 5
    
    let targetView: Content
    let icon: Image
    let label: String
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationLink(destination: self.targetView ) {
            
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
                        self.icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: self.maxIconWidth, minHeight: gr.size.height, maxHeight: gr.size.height)
                        Spacer()
                    }
                }
                
                Text(label)
                    .bold()
                    .padding(EdgeInsets(top: 0, leading: textPadding, bottom: textPadding, trailing: textPadding))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .scaledToFit()
                    .layoutPriority(1)
                
            }
            .padding(cardPadding)
            .border(themeManager.collectionItemBorder, width: borderThickness)
            .cornerRadius(cornerRadius)
            .foregroundColor(themeManager.collectionItemContent)
            .background(themeManager.collectionItem)
        }
    }
    
}
