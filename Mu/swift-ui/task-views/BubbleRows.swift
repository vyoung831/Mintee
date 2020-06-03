//
//  BubbleRows.swift
//  Mu
//
//  Created by Vincent Young on 6/3/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct BubbleRows: View {
    
    // MARK: - Properties
    
    let rowSpacing: CGFloat = 12
    let minimumInterBubbleSpacing: CGFloat = 5
    
    var bubblesPerRow: Int = 7
    var maxBubbleRadius: CGFloat = 28
    var bubbles: [[String]]
    var selectedBubbles: [String]
    
    @State var grHeight: CGFloat = 0
    
    // MARK: - UI functions
    
    /**
     Calculates the radius of a bubble, given the width of the View containing the bubbles.
     Taking into account the minimum bubble spacing, this function first finds the cumulative width available to the bubbles, then calculates the width of each bubble and returns the minimum of that value or the maximum bubble radius
     - parameter totalWidth: The total width of the View containing the bubbles
     - returns: Bubble radius
     */
    private func getBubbleRadius(totalWidth: CGFloat) -> CGFloat {
        let bubblesCumulativeWidth = totalWidth - (CGFloat(bubblesPerRow)-1)*minimumInterBubbleSpacing
        let fullBubbleRadius = (bubblesCumulativeWidth/CGFloat(bubblesPerRow))/2
        return min(fullBubbleRadius, maxBubbleRadius)
    }
    
    /**
     Calculates the height of the GeometryReader used to size BubbleRow.
     Uses BubbleRow.getBubbleRadius to get the size of each of the bubbles, then uses rowSpacing
     - parameter totalWidth: width of the GeometryReader. The width is used to calculate the bubble radius, and in the returned size
     - returns: Height of the GeometryReader
     */
    private func getGeometryReaderHeight(totalWidth: CGFloat) -> CGFloat {
        let bubbleHeight = 2*getBubbleRadius(totalWidth: totalWidth)
        let spacing = CGFloat(self.bubbles.count-1)*self.rowSpacing
        let totalHeight = bubbleHeight*(CGFloat(self.bubbles.count)) + spacing
        return totalHeight
    }
    
    /**
     Given the number of elements (bubbles) in the HStack and the HStack's available width, calculates the spacing between each of the elements.
     Uses BubbleRow.getBubbleRadius to get the size of each of the bubbles
     - parameter totalWidth: The total width of the GeometryReader that contains the HStack
     - returns: HStack spacing
     */
    private func getHStackSpacing(totalWidth: CGFloat) -> CGFloat {
        let bubbleWidth = 2*getBubbleRadius(totalWidth: totalWidth)
        let bubblesCumulativeWidth = bubbleWidth * CGFloat(bubblesPerRow)
        let totalSpacing = totalWidth - bubblesCumulativeWidth
        let spacing = totalSpacing/(CGFloat(bubblesPerRow) - 1)
        return max(spacing, minimumInterBubbleSpacing)
    }
    
    // MARK: - View
    
    var body: some View {
        /*
         The GeometryReader updates its height based on changes to SizePreferenceKey detected from the VStack of rows.
         The VStack updates the SizePreferenceKey by using GeometryReader's width to call getGeometryReaderSize.
         Because GeometryReader only updates the height of its frame and never the width, circular layout references between the GeometryReader and VStack are avoided
         */
        GeometryReader { gr in
            VStack(alignment: .leading, spacing: self.rowSpacing) {
                ForEach(0 ..< self.bubbles.count, id: \.self) { row in
                    
                    // Calculate the HStack spacing now that GeometryReader has the available width
                    HStack(alignment: .center, spacing: self.getHStackSpacing(totalWidth: gr.size.width)) {
                        ForEach(self.bubbles[row], id: \.self) { bubbleText in
                            ZStack {
                                Circle()
                                    .foregroundColor(self.selectedBubbles.contains(bubbleText)
                                        ? .blue : .clear)
                                    .cornerRadius(self.getBubbleRadius(totalWidth: gr.size.width))
                                    .frame(width: 2*self.getBubbleRadius(totalWidth: gr.size.width),
                                           height: 2*self.getBubbleRadius(totalWidth: gr.size.width),
                                           alignment: .center)
                                Text(String(bubbleText)).foregroundColor(self.selectedBubbles.contains(bubbleText)
                                    ? .white : Color("default-panel-text-colors") )
                            }
                        }
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

//struct BubbleRows_Previews: PreviewProvider {
//    static var previews: some View {
//        BubbleRows()
//    }
//}
