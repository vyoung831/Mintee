//
//  TaskTargetSetPopup.swift
//  Mu
//
//  Created by Vincent Young on 6/2/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TaskTargetSetPopup: View {
    
    // MARK: - Enums for Picker values
    
    var dayPatternTypeLabels: [DayPattern.patternType: String] = [.dow: "Days of week",
                                                                  .wom: "Weekdays of month",
                                                                  .dom: "Days of month"]
    
    // MARK: - UI and calculated variables
    
    let typePickerHeight: CGFloat = 125
    let textFieldWidth: CGFloat = 55
    let operationWidth: CGFloat = 55
    let operationHeight: CGFloat = 100
    
    var title: String
    let bubblesPerRow: Int = 7
    
    // MARK: - State variables
    
    @State var selectedDaysOfWeek: Set<String> = Set<String>()
    @State var selectedWeeks: Set<String> = Set<String>()
    @State var selectedDaysOfMonth: Set<String> = Set<String>()
    
    @State var type: DayPattern.patternType = .dow
    @State var minOperator: SaveFormatter.equalityOperator = .lt
    @State var maxOperator: SaveFormatter.equalityOperator = .lt
    @State var minValueString: String = ""
    @State var maxValueString: String = ""
    @State var errorMessage: String = ""
    
    // MARK: - Bindings
    
    @Binding var isBeingPresented: Bool
    
    // MARK: - Functions
    
    var save: (TaskTargetSetView) -> ()
    
    /**
     Announce to user via accessibility notification the error message is displayed
     */
    func announceError() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: self.errorMessage)
        }
    }
    
    /**
     - returns: True if both minValue and maxValue TextFields are empty
     */
    func checkEmptyValues() -> Bool {
        return minValueString.count < 1 && maxValueString.count < 1
    }
    
    func validateMinValue() -> Float? {
        return Float(minValueString)
    }
    
    func validateMaxValue() -> Float? {
        return Float(maxValueString)
    }
    
    /**
     Checks minOperator, maxOperator, and provided min/max values to see if combination is valid.
     This function expects the caller to have un-wrapped min and max to check if they are valid Floats
     - parameter min: minValueString unwrapped to Float
     - parameter max: maxValueString unwrapped to Float
     - returns: True if combination of operators and provided values are valid
     */
    func checkOperators(min: Float, max: Float) -> Bool {
        
        switch minOperator {
        case .lt:
            if maxOperator == .lt || maxOperator == .lte {
                if min >= max {
                    errorMessage = "Please set max value greater than min value"
                    announceError()
                    return false
                }
            }
            break
        case .lte:
            if maxOperator == .lt && min >= max {
                errorMessage = "Please set max value greater than min value"
                announceError()
                return false
            } else if maxOperator == .lte {
                if min == max {
                    // Both minOperator and maxOperator are set to .lte the same value, so treat it as .eq
                    minOperator = .eq; return true
                } else if min > max {
                    errorMessage = "Please set max value greater than min value"
                    announceError()
                    return false
                }
            }
            return true
        case .eq:
            if maxOperator == .eq {
                errorMessage = "Only one operator can be set to ="
                announceError()
                return false
            }
        case .na: break
        }
        return true
    }
    
    /**
     Creates and configures a TaskTargetSetView, and appends it to the Binding of type [TaskTargetSetView] provided by the parent View.
     - returns: True if TaskTargetSetView save was successful
     */
    func done() {
        
        if checkEmptyValues() { errorMessage = "Fill out at least either lower or upper target bound"; return }
        
        // Min/Max value input validation
        var min: Float, max: Float
        if minValueString.count > 0 {
            if let minu = validateMinValue() { min = minu } else { errorMessage = "Remove invalid input from lower target bound"; return }
        } else { minOperator = .na; min = 0 }
        if maxValueString.count > 0 {
            if let maxu = validateMaxValue() { max = maxu } else { errorMessage = "Remove invalid input from upper target bound"; return }
        } else { maxOperator = .na; max = 0 }
        
        if !checkOperators(min: min, max: max) { return }
        let ttsv = TaskTargetSetView(type: self.type,
                                     minTarget: maxOperator == .eq || minOperator == .na ? 0 : min,
                                     minOperator: maxOperator == .eq || minOperator == .na ? .na : minOperator,
                                     maxTarget: minOperator == .eq || maxOperator == .na ? 0 : max,
                                     maxOperator: minOperator == .eq || maxOperator == .na ? .na : maxOperator,
                                     selectedDaysOfWeek: self.type == .dow || self.type == .wom ? self.selectedDaysOfWeek : Set(),
                                     selectedWeeksOfMonth: self.type == .wom ? self.selectedWeeks : Set(),
                                     selectedDaysOfMonth: self.type == .dom ? self.selectedDaysOfMonth : Set())
        self.save(ttsv)
        self.isBeingPresented = false
    }
    
    /**
     - returns: true if the user has selected a non-zero number of dates, depending on the selected ttsType
     */
    func validDaysSelected() -> Bool {
        switch self.type {
        case .dow:
            if self.selectedDaysOfWeek.count > 0 { return true }
            return false
        case .wom:
            if self.selectedDaysOfWeek.count > 0 && self.selectedWeeks.count > 0 { return true }
            return false
        case .dom:
            if self.selectedDaysOfMonth.count > 0 { return true }
            return false
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .center, spacing: 30) {
                
                // MARK: - Title bar
                
                Group {
                    HStack {
                        Button(action: {
                            self.done()
                        }, label: { Text("Done") })
                        .accessibility(identifier: "task-target-set-popup-done-button")
                        .accessibility(label: Text("Done"))
                        .accessibility(hint: Text("Tap to finish setting target set"))
                        .disabled(self.maxOperator == .na && self.minOperator == .na)
                        .disabled(!validDaysSelected())
                        Spacer()
                        Text(title)
                            .font(.title)
                        Spacer()
                        
                        Button(action: {
                            self.isBeingPresented = false
                        }, label: { Text("Cancel") })
                        .accessibility(identifier: "task-target-set-popup-cancel-button")
                        .accessibility(label: Text("Cancel"))
                        .accessibility(hint: Text("Tap to cancel setting target set"))
                    }
                    if errorMessage.count > 0 {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibility(identifier: "task-target-set-popup-error-message")
                            .accessibility(hidden: true)
                    }
                }
                
                // MARK: - Bubbles/DayPattern picker
                
                Group {
                    
                    // Days of week/month
                    BubbleRowsToggleable(maxBubbleRadius: 32,
                                         bubbles: self.type == .dom ? DayBubbleLabels.getDividedBubbleLabels(bubblesPerRow: self.bubblesPerRow, patternType: .dom) : DayBubbleLabels.getDividedBubbleLabels(bubblesPerRow: self.bubblesPerRow, patternType: .dow),
                                         selectedBubbles: self.type == .dom ? self.$selectedDaysOfMonth : self.$selectedDaysOfWeek)
                    
                    // Weeks of month
                    if self.type == .wom {
                        BubbleRowsToggleable(maxBubbleRadius: 32,
                                             bubbles: DayBubbleLabels.getDividedBubbleLabels(bubblesPerRow: self.bubblesPerRow, patternType: .wom),
                                             selectedBubbles: self.$selectedWeeks)
                    }
                    
                    Picker(selection: self.$type,
                           label: Text("Type")
                            .accessibility(hint: Text("Use to set target set pattern type"))) {
                        ForEach(DayPattern.patternType.allCases, id: \.self) { pt in
                            Text( self.dayPatternTypeLabels[pt] ?? "")
                        }
                    }
                    .accessibility(identifier: "task-target-set-popup-pattern-type-picker")
                    .frame(height: typePickerHeight)
                    
                }
                
                // MARK: - Target setter
                
                HStack(alignment: .center, spacing: 10) {
                    
                    TextField("", text: self.$minValueString)
                        .disabled(self.maxOperator == .eq || self.minOperator == .na)
                        .keyboardType( .decimalPad )
                        .padding(10)
                        .foregroundColor(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-text-colors") : .black )
                        .border(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-border-colors") : Color.init("default-border-colors"), width: 2)
                        .background(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-fill-colors") : .clear)
                        .cornerRadius(3)
                        .accessibility(identifier: "minimum-value")
                        .accessibility(label: Text("Minimum"))
                        .accessibility(hint: Text("Enter your target set's minimum value or leave blank"))
                    
                    Picker("Low op", selection: self.$minOperator) {
                        ForEach(SaveFormatter.equalityOperator.allCases, id: \.self) { op in
                            Text(op.rawValue)
                        }}
                        .frame(width: operationWidth, height: operationHeight)
                        .clipped()
                    
                    Text("Target")
                    
                    Picker("High op", selection: self.$maxOperator) {
                        ForEach(SaveFormatter.equalityOperator.allCases, id: \.self) { op in
                            Text(op.rawValue)
                        }}
                        .frame(width: operationWidth, height: operationHeight)
                        .clipped()
                    
                    TextField("", text: self.$maxValueString)
                        .disabled(self.minOperator == .eq || self.maxOperator == .na)
                        .keyboardType( .decimalPad )
                        .padding(10)
                        .foregroundColor(self.minOperator == .eq || self.maxOperator == .na ? Color.init("default-disabled-text-colors") : .black )
                        .border(self.minOperator == .eq || self.maxOperator == .na ? Color.init("default-disabled-border-colors") : Color.init("default-border-colors"), width: 2)
                        .background(self.minOperator == .eq || self.maxOperator == .na ? Color.init("default-disabled-fill-colors") : .clear)
                        .cornerRadius(3)
                        .accessibility(identifier: "maximum-value")
                        .accessibility(label: Text("Maximum"))
                        .accessibility(hint: Text("Enter your target set's maximum value or leave blank"))
                    
                }.labelsHidden()
            }
        }).padding(15)
    }
}
