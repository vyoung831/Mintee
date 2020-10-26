//
//  TaskTargetSetView.swift
//  Mu
//
//  Created by Vincent Young on 5/17/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import Firebase

struct TaskTargetSetView: View {
    
    // MARK: - Constants and calculated properties
    
    let vStackPadding: CGFloat = 15
    let vStackMargin: CGFloat = 5
    let cornerRadius: CGFloat = 20
    let borderWidth: CGFloat = 3
    let buttonsSpacing: CGFloat = 20
    let bubblesPerRow: Int = 7
    
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
    
    // MARK: - Environment Objects
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
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
                ErrorManager.recordNonFatal(.ttsvWomNil, [:])
                return "Weekdays of month"
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
        
        ErrorManager.recordNonFatal(.ttsvGetTargetInvalidValues, ["minOperator": minOperator.rawValue,
                                                                  "maxOperator": maxOperator.rawValue,
                                                                  "minTarget": minTarget,
                                                                  "maxTarget": maxTarget])
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
                    .accessibility(identifier: "task-target-set-view-edit-button")
                    .accessibility(label: Text("Edit target set"))
                    .accessibility(hint: Text("Tap to edit target set"))
                    
                    Button(action: {
                        self.moveUp()
                    }, label: {
                        Image(systemName: "arrowtriangle.up.circle.fill")
                            .foregroundColor(themeManager.collectionItemContent)
                        
                    })
                    .accessibility(identifier: "task-target-set-view-up-button")
                    .accessibility(label: Text("Increase target set priority"))
                    .accessibility(hint: Text("Tap to increase target set's priority"))
                    
                    Button(action: {
                        self.moveDown()
                    }, label: {
                        Image(systemName: "arrowtriangle.down.circle.fill")
                            .foregroundColor(themeManager.collectionItemContent)
                        
                    })
                    .accessibility(identifier: "task-target-set-view-down-button")
                    .accessibility(label: Text("Decrease target set priority"))
                    .accessibility(hint: Text("Tap to decrease target set's priority"))
                    
                    Spacer()
                    
                    Button(action: {
                        self.delete()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(themeManager.collectionItemContent)
                    })
                    .accessibility(identifier: "task-target-set-view-delete-button")
                    .accessibility(label: Text("Delete target set"))
                    .accessibility(hint: Text("Tap to delete target set"))
                    
                }
            }
            
            // MARK: - Bubbles
            
            Group {
                BubbleRows(type: self.type,
                           selected: (self.type == .dow || self.type == .wom ? self.selectedDaysOfWeek : self.selectedDaysOfMonth) ?? Set<String>())
                    .accessibilityElement(children: .ignore)
                
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
        .foregroundColor(themeManager.collectionItemContent)
        .padding(vStackPadding)
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(themeManager.collectionItemBorder, lineWidth: borderWidth))
        .background( themeManager.collectionItem )
        .cornerRadius(cornerRadius)
        .padding(vStackMargin)
        .accessibilityElement(children: .combine)
        .accessibility(identifier: "task-target-set-view")
        .accessibility(label: Text("Target set"))
        .accessibility(value: Text("\(selectedDaysOfWeek!.map{DayBubbleLabels.getLongLabel($0)}.joined(separator: ", ")). \(getLabel()). \(getTarget())"))
    }
}
