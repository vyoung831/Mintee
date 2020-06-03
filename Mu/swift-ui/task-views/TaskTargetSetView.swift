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
    
    static let weeksOfMonthLabels: [Int:String] = [1: "1st",
                                                   2: "2nd",
                                                   3: "3rd",
                                                   4: "4th",
                                                   5: "5th"]
    
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
    
    // MARK: - UI functions
    
    /**
     Returns the label to be presented with the TaskTargetSetView
     - returns: String containing the TaskTargetSetView's calculated label
     */
    func getLabel() -> String {
        if self.selectedDaysOfWeek.count > 0 {
            if self.selectedWeeksOfMonth.count > 0 {
                var label: String = ""
                for idx in 0 ..< selectedWeeksOfMonth.count {
                    label.append(contentsOf: TaskTargetSetView.weeksOfMonthLabels[selectedWeeksOfMonth[idx]] ?? "")
                    if idx < selectedWeeksOfMonth.count - 1 {
                        label.append(",")
                    }
                    label.append(" ")
                }
                label.append(contentsOf: " of each month")
                return label
            } else {
                return "Every week"
            }
        } else {
            return "Every month"
        }
    }
    
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
                BubbleRows(bubbles: self.selectedDaysOfWeek.count > 0 ? self.daysOfWeek : self.dividedDaysOfMonth,
                           selectedBubbles: self.selectedDaysOfWeek.count > 0 ? self.selectedDaysOfWeek : self.selectedDaysOfMonth)
            }
            
            // MARK: - Frequency
            
            Group {
                Text(getLabel())
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
