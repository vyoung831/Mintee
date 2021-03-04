//
//  BubbleRows.swift
//  Mu
//
//  Presents a row of bubbles used for a DayPattern's array's presentation/selection.
//  Parent view can set whether or not bubbles are toggleable.
//
//  Created by Vincent Young on 6/3/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct BubbleRows<BubbleType : Day>: View {
    
    // MARK: - Presentation options
    
    enum PresentationOption {
        case none
        case centerLastRow
    }
    
    let rowSpacing: CGFloat = 12
    let minimumInterBubbleSpacing: CGFloat = 5
    
    var maxBubbleRadius: CGFloat = 28
    
    // Var that represents what UIElement this struct is being presented on.
    // Depending on if BubbleRows is presented on a panel or a collectionItem, its colors differ.
    var presentationBase: ThemeManager.ThemedUIElement
    
    var bubbles: [[BubbleType]]
    var presentation: BubbleRows.PresentationOption
    var toggleable: Bool
    @Binding var selectedBubbles: Set<BubbleType>
    
    @State var grHeight: CGFloat = 0
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    // MARK: - UI functions
    
    /**
     Determines whether a row of bubbles in an HStack needs Spacers on each side in order to center the bubbles.
     Returns true if spaceLastRow is set to true AND the row in question is the last row AND the row has less bubbles than previous row.
     This function was implemented because placing Spacers on the sides of bubble rows that already took up the GeometryReader's full width pushed the rows off-screen. It is unclear from documentation if this is intended in SwiftUI or a bug.
     - parameter rowNumber: Row to be evaluated for spacers
     - returns: True if the row in question needs spacers in its HStack
     */
    func rowNeedsSpacers(_ rowNumber: Int) -> Bool {
        if self.presentation != .centerLastRow { return false }
        if (rowNumber == self.bubbles.count - 1) &&
            (rowNumber > 0) &&
            (self.bubbles[rowNumber].count < self.bubbles[rowNumber - 1].count) {
            return true
        }
        return false
    }
    
    /**
     Calculates the radius of a bubble, given the width of the View containing the bubbles.
     Taking into account the minimum bubble spacing, this function first finds the cumulative width available to the bubbles, then calculates the width of each bubble and returns the minimum of that value or the maximum bubble radius
     - parameter totalWidth: The total width of the View containing the bubbles
     - returns: Bubble radius
     */
    func getBubbleRadius(totalWidth: CGFloat) -> CGFloat {
        let bubblesCumulativeWidth = totalWidth - (CGFloat(bubbles[0].count)-1) * minimumInterBubbleSpacing
        let fullBubbleRadius = (bubblesCumulativeWidth/CGFloat(bubbles[0].count))/2
        return min(fullBubbleRadius, maxBubbleRadius)
    }
    
    /**
     Calculates the height of the GeometryReader used to size BubbleRow.
     Uses BubbleRow.getBubbleRadius to get the size of each of the bubbles, then uses rowSpacing
     - parameter totalWidth: width of the GeometryReader. The width is used to calculate the bubble radius, and in the returned size
     - returns: Height of the GeometryReader
     */
    func getGeometryReaderHeight(totalWidth: CGFloat) -> CGFloat {
        let bubbleHeight = 2*getBubbleRadius(totalWidth: totalWidth)
        let spacing = CGFloat(self.bubbles.count-1) * rowSpacing
        let totalHeight = bubbleHeight*(CGFloat(self.bubbles.count)) + spacing
        return totalHeight
    }
    
    /**
     Given the number of elements (bubbles) in the HStack and the HStack's available width, calculates the spacing between each of the elements.
     Uses BubbleRow.getBubbleRadius to get the size of each of the bubbles
     - parameter totalWidth: The total width of the GeometryReader that contains the HStack
     - returns: HStack spacing
     */
    func getHStackSpacing(totalWidth: CGFloat) -> CGFloat {
        let bubbleWidth = 2*getBubbleRadius(totalWidth: totalWidth)
        let bubblesCumulativeWidth = bubbleWidth * CGFloat(bubbles[0].count)
        let totalSpacing = totalWidth - bubblesCumulativeWidth
        let spacing = totalSpacing/(CGFloat(bubbles[0].count) - 1)
        return max(spacing, minimumInterBubbleSpacing)
    }
    
    // MARK: - View
    
    var body: some View {
        /*
         Because BubbleRows can be placed in a vertical ScrollView, SwiftUI assigns its GR (GeometryReader) a very small height.
         Bubbles must be declared in GR in order to use its width to calculate their radii, but GR's height won't expand (SwiftUI views do not expand to fit their children).
         Thus, BubbleRowsHeightKey is defined - when the GR's width is updated, the PreferenceKey is updated and the grHeight state var (used to set GR's height) is updated.
         Circular references are avoided because updating the GeometryReader's height doesn't have any effect on its width.
         */
        GeometryReader { gr in
            VStack(alignment: .leading, spacing: rowSpacing) {
                ForEach(0 ..< self.bubbles.count, id: \.self) { row in
                    
                    // Calculate the HStack spacing now that GeometryReader has the available width
                    HStack(alignment: .center, spacing: self.getHStackSpacing(totalWidth: gr.size.width)) {
                        
                        if rowNeedsSpacers(row) { Spacer() }
                        
                        ForEach(self.bubbles[row], id: \.self) { bubbleText in
                            ZStack {
                                if presentationBase == .panel {
                                    Circle()
                                        .foregroundColor(self.selectedBubbles.contains(bubbleText)
                                                            ? themeManager.button : .clear)
                                        .cornerRadius(self.getBubbleRadius(totalWidth: gr.size.width))
                                        .frame(width: 2*self.getBubbleRadius(totalWidth: gr.size.width),
                                               height: 2*self.getBubbleRadius(totalWidth: gr.size.width),
                                               alignment: .center)
                                    Text(bubbleText.shortValue).foregroundColor(self.selectedBubbles.contains(bubbleText)
                                                                                    ? themeManager.collectionItemContent : themeManager.collectionItem)
                                } else {
                                    Circle()
                                        .foregroundColor(self.selectedBubbles.contains(bubbleText)
                                                            ? themeManager.collectionItemContent : .clear)
                                        .cornerRadius(self.getBubbleRadius(totalWidth: gr.size.width))
                                        .frame(width: 2*self.getBubbleRadius(totalWidth: gr.size.width),
                                               height: 2*self.getBubbleRadius(totalWidth: gr.size.width),
                                               alignment: .center)
                                    Text(bubbleText.shortValue).foregroundColor(self.selectedBubbles.contains(bubbleText)
                                                                                    ? themeManager.collectionItem : themeManager.collectionItemContent)
                                }
                            }
                            .accessibility(identifier: "day-bubble-\(bubbleText)")
                            .onTapGesture {
                                // Add or remove the bubbleText from selectedBubbles
                                if self.toggleable {
                                    if !self.selectedBubbles.contains(bubbleText) {
                                        self.selectedBubbles.insert(bubbleText)
                                    } else {
                                        self.selectedBubbles = self.selectedBubbles.filter { $0 != bubbleText }
                                    }
                                }
                            }
                            
                        }
                        
                        if rowNeedsSpacers(row) { Spacer() }
                        
                    }
                    
                }
            }.preference(key: BubbleRowsHeightKey.self, value: self.getGeometryReaderHeight(totalWidth: gr.size.width))
        }
        .frame(height: CGFloat(self.grHeight))
        .onPreferenceChange(BubbleRowsHeightKey.self) { height in
            self.grHeight = height
        }
    }
    
}

struct BubbleRowsHeightKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = CGFloat(0)
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { }
}
