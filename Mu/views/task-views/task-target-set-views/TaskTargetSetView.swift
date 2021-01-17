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
    var selectedDaysOfWeek: Set<SaveFormatter.dayOfWeek>?
    var selectedWeeksOfMonth: Set<SaveFormatter.weekOfMonth>?
    var selectedDaysOfMonth: Set<SaveFormatter.dayOfMonth>?
    
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
                ErrorManager.recordNonFatal(.viewObject_unexpectedNilProperty,
                                            ["Message" : "TaskTargetSetView.getLabel() found nil selectedWeeksOfMonth when expected non-nil",
                                             "selectedDaysOfWeek" : selectedDaysOfWeek?.debugDescription,
                                             "selectedDaysOfMonth" : selectedDaysOfMonth?.debugDescription,
                                             "minOperator" : self.minOperator,
                                             "maxOperator" : self.maxOperator])
                return "Weekdays of month"
            }
            
            let orderedWeeks = selectedWom.sorted(by: { SaveFormatter.weekOfMonthToStored($0) < SaveFormatter.weekOfMonthToStored($1) }).map{ $0.shortValue }
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
     Builds a String representing a TaskTargetSet or minimum and maximum operators and target values
     - parameter minOperator: The minimum value equality operator
     - parameter maxOperator: The maximum value equality operator
     - parameter minValue: The minimum target value
     - parameter maxValue: The maximum target value
     - returns: String representing the target value(s)
     */
    static func getTargetString(minOperator: SaveFormatter.equalityOperator, maxOperator: SaveFormatter.equalityOperator, minTarget: Float, maxTarget: Float) -> String {
        
        if minOperator == .eq { return "Target \(SaveFormatter.equalityOperator.eq.stringValue) \(minTarget.clean)"}
        if maxOperator == .eq { return "Target \(SaveFormatter.equalityOperator.eq.stringValue) \(maxTarget.clean)"}
        
        if minOperator != .na && maxOperator != .na { return "\(minTarget.clean) \(minOperator.stringValue) Target \(maxOperator.stringValue) \(maxTarget.clean)" }
        if minOperator != .na { return "Target \(minOperator.stringValue.replacingOccurrences(of: "<", with: ">")) \(minTarget.clean)" }
        if maxOperator != .na { return "Target \(maxOperator.stringValue.replacingOccurrences(of: ">", with: "<")) \(maxTarget.clean)" }
        
        ErrorManager.recordNonFatal(.viewFunction_receivedInvalidParms, ["minOperator": minOperator.rawValue,
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
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-edit-button")
                    .accessibility(label: Text("Edit target set"))
                    .accessibility(hint: Text("Tap to edit target set"))
                    
                    Button(action: {
                        self.moveUp()
                    }, label: {
                        Image(systemName: "arrowtriangle.up.circle.fill")
                    })
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-up-button")
                    .accessibility(label: Text("Increase target set priority"))
                    .accessibility(hint: Text("Tap to increase target set's priority"))
                    
                    Button(action: {
                        self.moveDown()
                    }, label: {
                        Image(systemName: "arrowtriangle.down.circle.fill")
                    })
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-down-button")
                    .accessibility(label: Text("Decrease target set priority"))
                    .accessibility(hint: Text("Tap to decrease target set's priority"))
                    
                    Spacer()
                    
                    Button(action: {
                        self.delete()
                    }, label: {
                        Image(systemName: "trash")
                    })
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-delete-button")
                    .accessibility(label: Text("Delete target set"))
                    .accessibility(hint: Text("Tap to delete target set"))
                    
                }
            }
            
            // MARK: - Bubbles
            
            Group {
                
                if self.type == .dom {
                    BubbleRows<SaveFormatter.dayOfMonth>(bubbles: DayBubbleLabels.getDividedBubbles_daysOfMonth(bubblesPerRow: 7),
                                                         presentation: .none,
                                                         toggleable: false,
                                                         selectedBubbles: .constant(self.selectedDaysOfMonth ?? Set<SaveFormatter.dayOfMonth>()))
                        .accessibilityElement(children: .ignore)
                } else {
                    BubbleRows<SaveFormatter.dayOfWeek>(bubbles: DayBubbleLabels.getDividedBubbles_daysOfWeek(bubblesPerRow: 7),
                                                        presentation: .none,
                                                        toggleable: false,
                                                        selectedBubbles: .constant(self.selectedDaysOfWeek!))
                        .accessibilityElement(children: .ignore)
                }
                
            }
            
            // MARK: - Frequency
            
            Group {
                Text(getLabel())
            }
            
            // MARK: - Target
            
            Group {
                Text( TaskTargetSetView.getTargetString(minOperator: self.minOperator,
                                                        maxOperator: self.maxOperator,
                                                        minTarget: self.minTarget,
                                                        maxTarget: self.maxTarget) )
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
    }
}
