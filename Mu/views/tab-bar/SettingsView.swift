//
//  SettingsView.swift
//  Mu
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    var cards: [SettingsViewCard] = [SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation1"),
                                     SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation2"),
                                     SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation3"),
                                     SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation4"),
                                     SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation5"),
                                     SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation6"),
                                     SettingsViewCard(icon: Image(systemName: "paintbrush"),label: "Presentation7")]
    
    let collectionVerticalPadding: CGFloat = 25
    let minHStackSpacing: CGFloat = 25
    
    @State var hStackSpacing: CGFloat = 1
    @State var cardWidth: CGFloat = 100
    @State var cardsPerRow: Int = 1
    
    var body: some View {
        
        NavigationView {
            ScrollView(.vertical, showsIndicators: true, content: {
                
                GeometryReader { gr in
                    
                    VStack {
                        ForEach(0 ..< Int( ceil(Double(self.cards.count)/Double(self.cardsPerRow)) ), id: \.self) { row in
                            
                            HStack(spacing: self.hStackSpacing) {
                                ForEach(0 ..< self.cardsPerRow, id: \.self) { card in
                                    if self.cards.count - 1 >= (row * self.cardsPerRow + card) {
                                        self.cards[row * self.cardsPerRow + card]
                                            .frame(width: self.cardWidth,
                                                   height: self.cardWidth * 1.5,
                                                   alignment: .center)
                                    }
                                }
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: self.hStackSpacing, bottom: 0, trailing: self.hStackSpacing))
                            .frame(height: 150)
                        }
                    }
                    .padding(EdgeInsets(top: self.collectionVerticalPadding, leading: 0, bottom: self.collectionVerticalPadding, trailing: 0))
                    .preference(key: SettingsMockCollectionWidth.self, value: gr.size.width)
                    .onPreferenceChange(SettingsMockCollectionWidth.self) { width in
                        
                        let widthAvailable = (width - 2 * minHStackSpacing)
                        if self.cardWidth >= widthAvailable {
                            
                            /*
                             If the default cardWidth is greater than the width available (minus the minimum hstackSpacing on either side of each row), do the following:
                             - Shrink the cardWidth
                             - Set the hstackSpacing (used as padding) to the minimum
                             */
                            self.cardsPerRow = 1
                            self.cardWidth = widthAvailable
                            self.hStackSpacing = minHStackSpacing
                            
                        } else {
                            
                            /*
                             Find the max number of cards that can fit in each row with the minimum hstackSpacing
                             Then using the cards per row, find the average of the remaining space to assign to hstackSpacing
                             As a result, the mock collectionView's horizontal spacing and padding are equal
                             */
                            self.cardsPerRow = Int(floor((widthAvailable - self.cardWidth) / (self.cardWidth + self.minHStackSpacing)) + 1)
                            if self.cardsPerRow == 1 {
                                // If only one card can fit, adjust the hstackSpacing
                                self.hStackSpacing = (width - self.cardWidth) / 2
                            } else {
                                let totalSpacingAvailable = width - CGFloat(self.cardsPerRow) * self.cardWidth
                                self.hStackSpacing = totalSpacingAvailable / (CGFloat(self.cardsPerRow) + 1)
                            }
                            
                        }
                    }
                }
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
        .foregroundColor(.black)
        .padding(cardPadding)
        .border(Color.black, width: borderThickness)
        .cornerRadius(cornerRadius)
        
    }
    
}

struct SettingsMockCollectionWidth: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = CGFloat(0)
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { }
}
