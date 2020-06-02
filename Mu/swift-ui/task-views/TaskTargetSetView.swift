//
//  TaskTargetSetView.swift
//  Mu
//
//  Created by Vincent Young on 5/17/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TaskTargetSetView: View {
    
    // MARK: - Constants and calculated properties
    
    let vStackPadding: CGFloat = 15
    let vStackMargin: CGFloat = 5
    let cornerRadius: CGFloat = 20
    let borderWidth: CGFloat = 3
    let buttonsSpacing: CGFloat = 20
    let bubblesPerRow: Int = 7
    
    var daysOfWeek: [[String]] { return [["M","T","W","R","F","S","U"]] }
    
    var dividedDaysOfMonth: [[String]] {
        var dividedDOM: [[String]] = []
        let daysOfMonth: [String] = ["1","2","3","4","5","6","7","8","9",
                                     "10","11","12","13","14","15","16","17","18","19",
                                     "20","21","22","23","24","25","26","27","28","29",
                                     "30","31"]
        for x in stride(from: 0, to: daysOfMonth.count, by: bubblesPerRow) {
            let domSlice = daysOfMonth[x ... min(x + Int(bubblesPerRow) - 1, daysOfMonth.count - 1)]
            dividedDOM.append( Array(domSlice) )
        }
        return dividedDOM
    }
    
    // MARK: - Variables
    
    var target: String
    var selectedDaysOfWeek: [String]
    var selectedWeeksOfMonth: [Int]
    var selectedDaysOfMonth: [String]
    
    // MARK: - Closures
    
    var moveUp: () -> () = {}
    var moveDown: () -> () = {}
    var delete: () -> () = {}
    
    // MARK: - View
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: - Buttons
            
            Group {
                HStack(alignment: .center, spacing: buttonsSpacing) {
                    Button(action: {
                        print("Edit button pressed")
                    }, label: {
                        Text("Edit")
                    })
                    
                    Button(action: {
                        self.moveUp()
                    }, label: {
                        Image(systemName: "arrow.up")
                        .foregroundColor(Color("default-panel-icon-colors"))
                    })
                    
                    Button(action: {
                        self.moveDown()
                    }, label: {
                        Image(systemName: "arrow.down")
                        .foregroundColor(Color("default-panel-icon-colors"))
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        self.delete()
                    }, label: {
                        Image(systemName: "trash")
                        .foregroundColor(Color("default-panel-icon-colors"))
                    })
                }
            }
            
            // MARK: - Bubbles
            
            Group {
                BubbleRows(bubblesPerRow: self.bubblesPerRow,
                           bubbles: self.selectedDaysOfWeek.count > 0 ? self.daysOfWeek : self.dividedDaysOfMonth,
                           selectedBubbles: self.selectedDaysOfWeek.count > 0 ? self.selectedDaysOfWeek : self.selectedDaysOfMonth)
            }
            
            // MARK: - Frequency
            
            Group {
                if self.selectedDaysOfWeek.count > 0 {
                    if self.selectedWeeksOfMonth.count > 0 {
                        Text("Some weeks of the month")
                    } else {
                        Text("Some days of the week")
                    }
                } else {
                    Text("Some days of the month")
                }
            }
            
            // MARK: - Target
            
            Group {
                Text(self.target)
            }
            
        }
        .foregroundColor(Color("default-panel-text-colors"))
        .padding(vStackPadding)
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.black, lineWidth: borderWidth))
        .background( Color("default-panel-colors") )
        .cornerRadius(cornerRadius)
        .padding(vStackMargin)
    }
}

// MARK: - BubbleRow

struct BubbleRows: View {
    
    // MARK: - Properties
    
    let rowSpacing: CGFloat = 12
    let maxBubbleRadius: CGFloat = 28
    let minimumInterBubbleSpacing: CGFloat = 5
    
    var bubblesPerRow: Int
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

struct BubbleRowsHeightKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = CGFloat(0)
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { }
}

struct TaskTargetSetView_Previews: PreviewProvider {
    static var previews: some View {
        TaskTargetSetView(target: "Preview target",
                          selectedDaysOfWeek: ["M","W","U"],
                          selectedWeeksOfMonth: [],
                          selectedDaysOfMonth: [])
    }
}
