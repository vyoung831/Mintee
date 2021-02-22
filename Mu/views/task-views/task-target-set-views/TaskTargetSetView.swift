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
    @State var type: DayPattern.patternType
    @State var minTarget: Float
    @State var minOperator: SaveFormatter.equalityOperator
    @State var maxTarget: Float
    @State var maxOperator: SaveFormatter.equalityOperator
    @State var selectedDaysOfWeek: Set<SaveFormatter.dayOfWeek>?
    @State var selectedWeeksOfMonth: Set<SaveFormatter.weekOfMonth>?
    @State var selectedDaysOfMonth: Set<SaveFormatter.dayOfMonth>?
    
    @State var isPresentingEditTaskTargetSetPopup: Bool = false
    
    // MARK: - Closures
    
    var moveUp: () -> () = {}
    var moveDown: () -> () = {}
    var update: (TaskTargetSetView) -> () = { _ in }
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
                        isPresentingEditTaskTargetSetPopup = true
                    }, label: {
                        Text("Edit")
                    })
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-edit-button")
                    
                    Button(action: {
                        self.moveUp()
                    }, label: {
                        Image(systemName: "arrowtriangle.up.circle.fill")
                    })
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-up-button")
                    
                    Button(action: {
                        self.moveDown()
                    }, label: {
                        Image(systemName: "arrowtriangle.down.circle.fill")
                    })
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-down-button")
                    
                    Spacer()
                    
                    Button(action: {
                        self.delete()
                    }, label: {
                        Image(systemName: "trash")
                    })
                    .foregroundColor(themeManager.collectionItemContent)
                    .accessibility(identifier: "task-target-set-view-delete-button")
                    
                }
            }
            
            // MARK: - Bubbles
            
            Group {
                
                if self.type == .dom {
                    BubbleRows<SaveFormatter.dayOfMonth>(bubbles: DayBubbleLabels.getDividedBubbles_daysOfMonth(bubblesPerRow: 7),
                                                         presentation: .none,
                                                         toggleable: false,
                                                         selectedBubbles: .constant(self.selectedDaysOfMonth ?? Set<SaveFormatter.dayOfMonth>()))
                } else {
                    BubbleRows<SaveFormatter.dayOfWeek>(bubbles: DayBubbleLabels.getDividedBubbles_daysOfWeek(bubblesPerRow: 7),
                                                        presentation: .none,
                                                        toggleable: false,
                                                        selectedBubbles: .constant(self.selectedDaysOfWeek!))
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
        .accessibility(identifier: "task-target-set-view")
        .sheet(isPresented: self.$isPresentingEditTaskTargetSetPopup, content: {
                TaskTargetSetPopup.init(title: "Edit Target Set",
                                        selectedDaysOfWeek: self.selectedDaysOfWeek ?? Set(),
                                        selectedWeeks: self.selectedWeeksOfMonth ?? Set(),
                                        selectedDaysOfMonth: self.selectedDaysOfMonth ?? Set(),
                                        type: self.type,
                                        minOperator: self.minOperator,
                                        maxOperator: self.maxOperator,
                                        minValueString: String(self.minTarget.clean),
                                        maxValueString: String(self.maxTarget.clean),
                                        isBeingPresented: self.$isPresentingEditTaskTargetSetPopup,
                                        save: { ttsv in
                                            self.type = ttsv.type
                                            self.minTarget = ttsv.minTarget
                                            self.minOperator = ttsv.minOperator
                                            self.maxTarget = ttsv.maxTarget
                                            self.maxOperator = ttsv.maxOperator
                                            self.selectedDaysOfWeek = ttsv.selectedDaysOfWeek
                                            self.selectedWeeksOfMonth = ttsv.selectedWeeksOfMonth
                                            self.selectedDaysOfMonth = ttsv.selectedDaysOfMonth
                                            update(self)
                                        })})
    }
}
