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
    var daysOfWeek: [[String]] { return [["M","T","W","R","F","S","U"]] }
    var weeksOfMonth: [[String]] { return [["1st","2nd","3rd","4th","Last"]] }
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
    
    // MARK: - State variables
    
    @State var selectedDaysOfWeek: Set<String>
    @State var selectedWeeks: Set<String>
    @State var selectedDaysOfMonth: Set<String>
    
    @State var type: DayPattern.patternType = .dow
    @State var minOperator: SaveFormatter.equalityOperator = .lt
    @State var maxOperator: SaveFormatter.equalityOperator = .lt
    @State var minValue: String = ""
    @State var maxValue: String = ""
    @State var errorMessage: String = ""
    
    // MARK: - Bindings
    
    @Binding var isBeingPresented: Bool
    
    // MARK: - Functions
    
    var save: (TaskTargetSetView) -> ()
    
    /**
     Checks minOperator, maxOperator, and provided min/max values to see if combination is valid.
     This function expects the caller to have un-wrapped min and max to check if they are valid Floats
     - parameter min: minValue unwrapped to Float
     - parameter max: maxValue unwrapped to Float
     - returns: True if combination of operators and provided values are valid
     */
    func checkOperators(min: Float, max: Float) -> Bool {
        
        switch minOperator {
        case .lt:
            if maxOperator == .lt || maxOperator == .lte {
                if min >= max {
                    errorMessage = "Please set max value greater than min value"; return false
                }
            }
            break
        case .lte:
            if maxOperator == .lt && min >= max {
                errorMessage = "Please set max value greater than min value"; return false
            } else if maxOperator == .lte {
                if min == max {
                    // Both minOperator and maxOperator are set to .lte the same value, so treat it as .eq
                    minOperator = .eq; return true
                } else if min > max { errorMessage = "Please set max value greater than min value"; return false }
            }
            return true
        case .eq:
            if maxOperator == .eq {
                errorMessage = "Only one operator can be set to ="; return false
            }
        case .na: break
        }
        return true
    }
    
    /**
     Creates and configures a TaskTargetSetView, and appends it to the Binding of type [TaskTargetSetView] provided by the parent View.
     */
    private func done() {
        
        if minValue.count < 1 && maxValue.count < 1 { errorMessage = "Fill out at least either lower or upper target bound"; return }
        
        var min: Float, max: Float
        if minValue.count > 0 {
            if let minu = Float(minValue) { min = minu } else { errorMessage = "Remove invalid input from lower target bound"; return }
        } else { minOperator = .na; min = 0 }
        if maxValue.count > 0 {
            if let maxu = Float(maxValue) { max = maxu } else { errorMessage = "Remove invalid input from upper target bound"; return }
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
                            .disabled(self.maxOperator == .na && self.minOperator == .na)
                            .disabled(!validDaysSelected())
                        Spacer()
                        Text(title)
                            .font(.title)
                        Spacer()
                        
                        Button(action: {
                            self.isBeingPresented = false
                        }, label: { Text("Cancel") })
                    }
                    if errorMessage.count > 0 {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: - Bubbles/DayPattern picker
                
                Group {
                    
                    // Days of week/month
                    BubbleRowsToggleable(maxBubbleRadius: 32,
                                         bubbles: self.type == .dom ? dividedDaysOfMonth : daysOfWeek,
                                         selectedBubbles: self.type == .dom ? self.$selectedDaysOfMonth : self.$selectedDaysOfWeek)
                    
                    // Weeks of month
                    if self.type == .wom {
                        BubbleRowsToggleable(bubblesPerRow: 5,
                                             maxBubbleRadius: 32,
                                             bubbles: weeksOfMonth,
                                             selectedBubbles: self.$selectedWeeks)
                    }
                    
                    Picker(selection: self.$type, label: Text("Type")) {
                        ForEach(DayPattern.patternType.allCases, id: \.self) { pt in
                            Text( self.dayPatternTypeLabels[pt] ?? "")
                        }
                    }.frame(height: typePickerHeight)
                    
                }
                
                // MARK: - Target setter
                
                HStack(alignment: .center, spacing: 10) {
                    
                    TextField("", text: self.$minValue)
                        .disabled(self.maxOperator == .eq || self.minOperator == .na)
                        .keyboardType( .decimalPad )
                        .padding(10)
                        .foregroundColor(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-text-colors") : .black )
                        .border(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-border-colors") : Color.init("default-border-colors"), width: 2)
                        .background(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-fill-colors") : .clear)
                        .cornerRadius(3)
                    
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
                    
                    TextField("", text: self.$maxValue)
                        .disabled(self.minOperator == .eq || self.maxOperator == .na)
                        .keyboardType( .decimalPad )
                        .padding(10)
                        .foregroundColor(self.minOperator == .eq || self.maxOperator == .na ? Color.init("default-disabled-text-colors") : .black )
                        .border(self.minOperator == .eq || self.maxOperator == .na ? Color.init("default-disabled-border-colors") : Color.init("default-border-colors"), width: 2)
                        .background(self.minOperator == .eq || self.maxOperator == .na ? Color.init("default-disabled-fill-colors") : .clear)
                        .cornerRadius(3)
                    
                }.labelsHidden()
            }
        }).padding(15)
    }
}
