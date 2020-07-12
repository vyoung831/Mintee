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
    var type: DayPattern.patternType
    var minTarget: Float
    var minOperator: SaveFormatter.equalityOperator
    var maxTarget: Float
    var maxOperator: SaveFormatter.equalityOperator
    var selectedDaysOfWeek: Set<String>?
    var selectedWeeksOfMonth: Set<String>?
    var selectedDaysOfMonth: Set<String>?
    
    // MARK: - Closures
    
    var moveUp: () -> () = {}
    var moveDown: () -> () = {}
    var edit: () -> () = {}
    var delete: () -> () = {}
    
    // MARK: - UI functions
    
    /**
     Returns the label to be presented with the TaskTargetSetView
     - returns: String containing the TaskTargetSetView's calculated label
     */
    func getLabel() -> String {
        
        switch self.type {
        case .dow:
            return "Every week"
        case .wom:
            guard let selectedWom = self.selectedWeeksOfMonth else {
                print("TaskTargetSetView was set to type .wom but selectedWeeksOfMonth was false"); exit(-1)
            }
            
            let orderedWeeks = selectedWom.sorted(by: { SaveFormatter.getWeekOfMonthNumber(wom: $0) < SaveFormatter.getWeekOfMonthNumber(wom: $1) })
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
        case .dom:
            return "Every month"
        }
        
    }
    
    /**
     Builds the target String to be displayed
     - returns: String to display as target
     */
    func getTarget() -> String {
        
        if minOperator != .na && maxOperator != .na { return "\(minTarget.clean) \(minOperator.rawValue) Target \(maxOperator.rawValue) \(maxTarget.clean)" }
        if minOperator != .na { return "Target \(minOperator.rawValue.replacingOccurrences(of: "<", with: ">")) \(minTarget.clean)" }
        if maxOperator != .na { return "Target \(maxOperator.rawValue.replacingOccurrences(of: ">", with: "<")) \(maxTarget.clean)" }
        
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
                        self.edit()
                    }, label: {
                        Text("Edit")
                        
                    })
                        .accessibility(label: Text("Edit"))
                        .accessibility(hint: Text("Tap to edit target set"))
                    
                    Button(action: {
                        self.moveUp()
                    }, label: {
                        Image(systemName: "arrowtriangle.up.circle.fill")
                            .foregroundColor(Color("default-panel-icon-colors"))
                        
                    })
                        .accessibility(label: Text("Up"))
                        .accessibility(hint: Text("Tap to increase target set's priority"))
                    
                    Button(action: {
                        self.moveDown()
                    }, label: {
                        Image(systemName: "arrowtriangle.down.circle.fill")
                            .foregroundColor(Color("default-panel-icon-colors"))
                        
                    })
                        .accessibility(label: Text("Down"))
                        .accessibility(hint: Text("Tap to decrease target set's priority"))
                    
                    Spacer()
                    
                    Button(action: {
                        self.delete()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(Color("default-panel-icon-colors"))
                    })
                        .accessibility(label: Text("Delete"))
                        .accessibility(hint: Text("Tap to delete target set"))
                }
            }
            
            // MARK: - Bubbles
            
            Group {
                BubbleRows(bubbles: self.type == .dow || self.type == .wom ? self.daysOfWeek : self.dividedDaysOfMonth,
                           selectedBubbles: (self.type == .dow || self.type == .wom ? self.selectedDaysOfWeek : self.selectedDaysOfMonth) ?? Set<String>() )
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
        .accessibilityElement(children: .combine)
        .accessibility(identifier: "task-target-set")
        .accessibility(label: Text("Target set"))
        .accessibility(value: Text("\(selectedDaysOfWeek!.joined(separator: ", ")). \(getLabel()). \(getTarget())"))
    }
}
