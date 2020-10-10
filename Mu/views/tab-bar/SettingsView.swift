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
    
    let rowSpacing: CGFloat = 20
    let itemSpacing: CGFloat = 15
    let gridHorizontalPadding: CGFloat = 25
    let gridVerticalPadding: CGFloat = 25
    
    let cardHeightMultiplier: CGFloat = 1.5
    let minItemWidth: CGFloat = 85
    @State var itemWidth: CGFloat = 100
    
    /**
     Returns the exact item width (of equal width) needed to fill a row.
     This function uses SettingsView's itemSpacing constant for intra-item spacing
     - parameter widthAvailable: Total width available to draw the row in
     - parameter count: Number of items to be fitted into the row
     - returns: Exact width that each item (of equal width) would need to fill the row
     */
    func getExactItemWidth(widthAvailable: CGFloat, count: Int) -> CGFloat {
        let itemsSpacing = CGFloat(count - 1) * itemSpacing
        let totalItemsWidthAvailable = widthAvailable - itemsSpacing
        return totalItemsWidthAvailable / CGFloat(count)
    }
    
    /**
     Calculates the number and width of columns to be used for the LazyVGrid that SettingsView uses as a mock collection.
     This function also updates the itemWidth state variable of SettingsView. Because itemWidth is updated based on the parameter totalWidth's value, totalWidth must NOT have any dependencies on itemWidth in order to avoid circular updates that would crash the View layout
     - parameter totalWidth: Total width of View to place items, spacing, and row padding in. Must NOT have any dependencies on SettingsView.itemWidth
     - returns: Array of GridItem with fixed item widths and spacing
     */
    private func getVGridLayout(totalWidth: CGFloat) -> [GridItem] {
        
        var itemsPerRow: Int = 0
        var gridItems: [GridItem] = []
        
        let availableWidth = (totalWidth - 2 * gridHorizontalPadding)
        if self.itemWidth >= availableWidth {
            
            // If the default itemWidth is greater than the width available (minus the padding on either side of each row), shrink the itemWidth
            itemsPerRow = 1
            self.itemWidth = availableWidth
            
        } else {
            
            // Find the max number of cards that can fit in the width available
            let remainingWidthAvailable = availableWidth - self.itemWidth
            let remainingItemsFitted = Int( floor(remainingWidthAvailable / (self.itemWidth + self.itemSpacing)) )
            
            itemsPerRow = remainingItemsFitted + 1
            if itemsPerRow == 1 {
                
                // If only one card can be fitted per row, try shrinking the itemWidth to fit 2 cards per row (if minItemWidth allows). If not possible, leave the itemWidth
                let itemWidthRequired = getExactItemWidth(widthAvailable: availableWidth, count: 2)
                if itemWidthRequired >= minItemWidth {
                    itemWidth = itemWidthRequired
                    itemsPerRow = 2
                }
                
            }
            
        }
        
        for _ in 0 ..< itemsPerRow {
            gridItems.append(GridItem(.fixed(itemWidth), spacing: itemSpacing))
        }
        return gridItems
        
    }
    
    var body: some View {
        
        NavigationView {
            GeometryReader { gr in
                if gr.size.width > 0 {
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(columns: getVGridLayout(totalWidth: gr.size.width),
                                  alignment: .center,
                                  spacing: self.rowSpacing) {
                            ForEach(0 ..< self.cards.count, id: \.self) { card in
                                self.cards[card]
                                    .frame(width: self.itemWidth,
                                           height: self.itemWidth * self.cardHeightMultiplier,
                                           alignment: .center)
                            }
                        }
                        .padding(EdgeInsets(top: self.gridVerticalPadding, leading: self.gridHorizontalPadding, bottom: self.gridVerticalPadding, trailing: self.gridHorizontalPadding) )
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }
        
    }
}

struct SettingsViewCard<Content: View>: View {
    
    let maxIconWidth: CGFloat = 50
    let cornerRadius: CGFloat = 3
    let borderThickness: CGFloat = 2
    let cardPadding: CGFloat = 5
    let textPadding: CGFloat = 5
    
    let targetView: Content
    let icon: Image
    let label: String
    
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
                    .padding(EdgeInsets(top: 0, leading: textPadding, bottom: textPadding, trailing: textPadding))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .scaledToFit()
                    .layoutPriority(1)
                
            }
            .foregroundColor(Color.init("default-panel-text-colors"))
            .padding(cardPadding)
            .border(Color.init("default-panel-text-colors"), width: borderThickness)
            .cornerRadius(cornerRadius)
            
        }
    }
    
}
