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
    
    /*
     TaskTargetSetView expects minOperator and maxOperator to be nil if a min/max target bound is not be used. Other views/classes such as EditTaskHostingController and AddTaskTargetSetPopup set this View's operators to nil to convey that.
     */
    var minTarget: Float
    var minOperator: String?
    var maxTarget: Float
    var maxOperator: String?
    var selectedDaysOfWeek: [String]
    var selectedWeeksOfMonth: [String]
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
                let orderedWeeks = selectedWeeksOfMonth.sorted(by: { SaveFormatter.getWeekOfMonthNumber(wom: $0) < SaveFormatter.getWeekOfMonthNumber(wom: $1) })
                var label: String = ""
                for idx in 0 ..< orderedWeeks.count {
                    label.append(contentsOf: orderedWeeks[idx])
                    if idx < orderedWeeks.count - 1 {
                        label.append(",")
                    }
                    label.append(" ")
                }
                label.append(contentsOf: "of each month")
                return label
            } else {
                return "Every week"
            }
        } else {
            return "Every month"
        }
    }
    
    /**
     Builds the target String to be displayed
     - returns: String to display as target
     */
    func getTarget() -> String {
        if let minOp = minOperator, let maxOp = maxOperator {
            return "\(minTarget.clean) \(minOp) Target \(maxOp) \(maxTarget.clean)"
        } else if let minOp = minOperator {
            return "Target \(minOp.replacingOccurrences(of: "<", with: ">")) \(minTarget.clean)"
        } else if let maxOp = maxOperator {
            return "Target \(maxOp.replacingOccurrences(of: ">", with: "<")) \(maxTarget.clean)"
        }
        // TO-DO: Send error report
        return ""
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
                Text(getTarget())
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
