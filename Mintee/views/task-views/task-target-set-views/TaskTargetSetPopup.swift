//
//  TaskTargetSetPopup.swift
//  Mintee
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
    
    // MARK: - UI variables
    
    var title: String
    let typePickerHeight: CGFloat = 125
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
     Creates and configures a TaskTargetSetView, and appends it to the Binding of type [TaskTargetSetView] provided by the parent View.
     - returns: True if TaskTargetSetView save was successful
     */
    private func done(_ min: Float,_ max: Float) throws {
        let validatedValues = try TaskTargetSet.validateOperators(minOp: minOperator, maxOp: maxOperator, min: min, max: max)
        let ttsv = TaskTargetSetView(type: self.type,
                                     minTarget: validatedValues.min,
                                     minOperator: validatedValues.minOp,
                                     maxTarget: validatedValues.max,
                                     maxOperator: validatedValues.maxOp,
                                     selectedDaysOfWeek: self.type == .dow || self.type == .wom ? self.selectedDaysOfWeek : Set(),
                                     selectedWeeksOfMonth: self.type == .wom ? self.selectedWeeks : Set(),
                                     selectedDaysOfMonth: self.type == .dom ? self.selectedDaysOfMonth : Set())
        self.save(ttsv)
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
                        
                        Picker(selection: self.$type, label: Text("Type")) {
                            ForEach(DayPattern.patternType.allCases, id: \.self) { pt in
                                Text( self.dayPatternTypeLabels[pt] ?? "")
                            }
                        }
                        .foregroundColor(.accentColor)
                        .accessibility(identifier: "task-target-set-popup-pattern-type-picker")
                        .frame(height: typePickerHeight)
                        
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
                        
                    }
                    
                    // MARK: - Target setter
                    MinAndMaxSection(minOperator: self.$minOperator, maxOperator: self.$maxOperator, minValueString: self.$minValueString, maxValueString: self.$maxValueString)
                    
                }
            })
            .onTapGesture {
                UIUtil.resignFirstResponder()
            }
            .padding(15)
            .background(themeManager.panel)
            .foregroundColor(themeManager.panelContent)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    
                    if minValueString.count < 1 && maxValueString.count < 1 {
                        errorMessage = "Fill out at least either lower or upper target bound"; return
                    }
                    
                    // Min/Max value input validation
                    var min: Float, max: Float
                    if minValueString.count > 0 {
                        guard let minu = Float(minValueString) else {
                            errorMessage = "Remove invalid input from lower target bound"; return
                        }
                        min = minu
                    } else {
                        minOperator = .na; min = 0
                    }
                    
                    if maxValueString.count > 0 {
                        guard let maxu = Float(maxValueString) else {
                            errorMessage = "Remove invalid input from upper target bound"; return
                        }
                        max = maxu
                    } else {
                        maxOperator = .na; max = 0
                    }
                    
                    do {
                        try self.done(min, max)
                    } catch TaskTargetSet.validateErrorCode.min_greaterThanOrEqualTo_max {
                        self.errorMessage = "Min/max were set to (lt, lt/lte) but min was greater than or equal to max"; return
                    } catch TaskTargetSet.validateErrorCode.bothOperators_setToEqual_differentTargetValues {
                        self.errorMessage = "Both operators were set to equal but target values were different"; return
                    } catch TaskTargetSet.validateErrorCode.bothOperators_notApplicable {
                        self.errorMessage = "Min and max operators were both N/A"; return
                    } catch TaskTargetSet.validateErrorCode.min_greaterThan_max {
                        self.errorMessage = "Min/max were set to (lte, lte) but min was greater than max"; return
                    } catch {
                        let _ = ErrorManager.recordUnexpectedError(error)
                    }
                    self.isBeingPresented = false
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
