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
    let bubblesPerRow: Int = 5
    
    // MARK: - State variables
    
    @State var selectedDaysOfWeek: Set<SaveFormatter.dayOfWeek> = Set()
    @State var selectedWeeks: Set<SaveFormatter.weekOfMonth> = Set()
    @State var selectedDaysOfMonth: Set<SaveFormatter.dayOfMonth> = Set()
    
    @State var type: DayPattern.patternType = .dow
    @State var minOperator: SaveFormatter.equalityOperator = .lt
    @State var maxOperator: SaveFormatter.equalityOperator = .lt
    @State var minValueString: String = ""
    @State var maxValueString: String = ""
    @State var errorMessage: String = ""
    
    // MARK: - Bindings
    
    @Binding var isBeingPresented: Bool
    
    // MARK: - Environment objects
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    // MARK: - Functions
    
    var save: (TaskTargetSetView) -> ()
    
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
     Creates and configures a TaskTargetSetView, and appends it to the Binding of type [TaskTargetSetView] provided by the parent View.
     - returns: True if TaskTargetSetView save was successful
     */
    private func done() {
        
        if checkEmptyValues() { errorMessage = "Fill out at least either lower or upper target bound"; return }
        
        // Min/Max value input validation
        var min: Float, max: Float
        if minValueString.count > 0 {
            if let minu = validateMinValue() { min = minu } else { errorMessage = "Remove invalid input from lower target bound"; return }
        } else { minOperator = .na; min = 0 }
        if maxValueString.count > 0 {
            if let maxu = validateMaxValue() { max = maxu } else { errorMessage = "Remove invalid input from upper target bound"; return }
        } else { maxOperator = .na; max = 0 }
        
        let ttsValidation = TaskTargetSet.validateOperators(minOp: minOperator, maxOp: maxOperator, min: min, max: max)
        guard let validatedValues = ttsValidation.operators else {
            if let message = ttsValidation.errorMessage {
                self.errorMessage = message
            }
            return
        }
        
        let ttsv = TaskTargetSetView(type: self.type,
                                     minTarget: validatedValues.min,
                                     minOperator: minOperator,
                                     maxTarget: validatedValues.max,
                                     maxOperator: maxOperator,
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
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: true, content: {
                VStack(alignment: .center, spacing: 30) {
                    
                    // MARK: - Error message
                    
                    Group {
                        if errorMessage.count > 0 {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .accessibility(identifier: "task-target-set-popup-error-message")
                        }
                    }
                    
                    // MARK: - Bubbles/DayPattern picker
                    
                    Group {
                        
                        // Days of week/month
                        if self.type == .dom {
                            BubbleRows<SaveFormatter.dayOfMonth>(presentationBase: .panel,
                                                                 bubbles: DayBubbleLabels.getDividedBubbles_daysOfMonth(bubblesPerRow: self.bubblesPerRow),
                                                                 presentation: .none,
                                                                 toggleable: true,
                                                                 selectedBubbles: self.$selectedDaysOfMonth)
                        } else {
                            BubbleRows<SaveFormatter.dayOfWeek>(presentationBase: .panel,
                                                                bubbles: DayBubbleLabels.getDividedBubbles_daysOfWeek(bubblesPerRow: self.bubblesPerRow),
                                                                presentation: .centerLastRow,
                                                                toggleable: true,
                                                                selectedBubbles: self.$selectedDaysOfWeek )
                        }
                        
                        // Weeks of month
                        if self.type == .wom {
                            BubbleRows<SaveFormatter.weekOfMonth>(presentationBase: .panel,
                                                                  bubbles: DayBubbleLabels.getDividedBubbles_weeksOfMonth(bubblesPerRow: self.bubblesPerRow),
                                                                  presentation: .centerLastRow,
                                                                  toggleable: true,
                                                                  selectedBubbles: self.$selectedWeeks)
                        }
                        
                        Picker(selection: self.$type, label: Text("Type")) {
                            ForEach(DayPattern.patternType.allCases, id: \.self) { pt in
                                Text( self.dayPatternTypeLabels[pt] ?? "")
                            }
                        }
                        .foregroundColor(.accentColor)
                        .accessibility(identifier: "task-target-set-popup-pattern-type-picker")
                        .frame(height: typePickerHeight)
                        
                    }
                    
                    // MARK: - Target setter
                    
                    HStack(alignment: .center, spacing: 10) {
                        
                        TextField("", text: self.$minValueString)
                            .disabled(self.maxOperator == .eq || self.minOperator == .na)
                            .keyboardType( .decimalPad )
                            .padding(10)
                            .border(themeManager.textFieldBorder, width: 2)
                            .background(self.maxOperator == .eq || self.minOperator == .na ? themeManager.disabledTextField : Color(UIColor.systemBackground))
                            .foregroundColor(self.maxOperator == .eq || self.minOperator == .na ? themeManager.disabledTextFieldText : .primary)
                            .cornerRadius(3)
                            .accessibility(identifier: "minimum-value")
                        
                        Picker("Low op", selection: self.$minOperator) {
                            ForEach(SaveFormatter.equalityOperator.allCases, id: \.self) { op in
                                Text(op.stringValue)
                            }}
                            .foregroundColor(.accentColor)
                            .frame(width: operationWidth, height: operationHeight)
                            .clipped()
                        
                        Text("Target")
                        
                        Picker("High op", selection: self.$maxOperator) {
                            ForEach(SaveFormatter.equalityOperator.allCases, id: \.self) { op in
                                Text(op.stringValue)
                            }}
                            .foregroundColor(.accentColor)
                            .frame(width: operationWidth, height: operationHeight)
                            .clipped()
                        
                        TextField("", text: self.$maxValueString)
                            .disabled(self.minOperator == .eq || self.maxOperator == .na)
                            .keyboardType( .decimalPad )
                            .padding(10)
                            .border(themeManager.textFieldBorder, width: 2)
                            .background(self.minOperator == .eq || self.maxOperator == .na ? themeManager.disabledTextField : Color(UIColor.systemBackground))
                            .foregroundColor(self.minOperator == .eq || self.maxOperator == .na ? themeManager.disabledTextFieldText : .primary)
                            .cornerRadius(3)
                            .accessibility(identifier: "maximum-value")
                        
                    }.labelsHidden()
                }
            })
            .padding(15)
            .background(themeManager.panel)
            .foregroundColor(themeManager.panelContent)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.done()
                }, label: {
                    Text("Done")
                })
                .foregroundColor(.accentColor)
                .accessibility(identifier: "task-target-set-popup-done-button")
                .disabled(self.maxOperator == .na && self.minOperator == .na)
                .disabled(!validDaysSelected()),
                
                trailing: Button(action: {
                    self.isBeingPresented = false
                }, label: {
                    Text("Cancel")
                })
                .foregroundColor(.accentColor)
                .accessibility(identifier: "task-target-set-popup-cancel-button")
            )
            
        }.accentColor(themeManager.accent)
    }
}
