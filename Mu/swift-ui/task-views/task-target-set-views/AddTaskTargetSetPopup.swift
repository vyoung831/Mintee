//
//  AddTaskTargetSetPopup.swift
//  Mu
//
//  Created by Vincent Young on 6/2/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddTaskTargetSetPopup: View {
    
    // MARK: - Enums for Picker values
    
    enum ttsType: String, CaseIterable {
        case dow = "Days of week"
        case wom = "Weekdays of month"
        case dom = "Days of month"
    }
    
    // MARK: - UI constants and calculated variables
    
    let typePickerHeight: CGFloat = 125
    let textFieldWidth: CGFloat = 55
    let operationWidth: CGFloat = 55
    let operationHeight: CGFloat = 100
    
    var toggleable: Bool = true
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
    
    @State var selectedDaysOfWeek: [String] = []
    @State var selectedWeeks: [String] = []
    @State var selectedDaysOfMonth: [String] = []
    
    @State var type: AddTaskTargetSetPopup.ttsType = .dow
    @State var minOperator: SaveFormatter.equalityOperators = .lt
    @State var maxOperator: SaveFormatter.equalityOperators = .lt
    @State var minValue: String = "0"
    @State var maxValue: String = "0"
    
    // MARK: - Bindings
    
    @Binding var ttsViews: [TaskTargetSetView]
    @Binding var isBeingPresented: Bool
    
    // MARK: - Functions
    
    /**
     Creates and configures a TaskTargetSetView, and appends it to the Binding of type [TaskTargetSetView] provided by the parent View.
     */
    private func save() {
        
        guard let min = Float(minValue), let max = Float(maxValue) else {
            // TO-DO: Crash report
            exit(-1)
        }
        
        let ttsv = TaskTargetSetView(minTarget: min,
                                     minOperator: maxOperator == .eq || minOperator == .na ? nil : minOperator.rawValue,
                                     maxTarget: max,
                                     maxOperator: minOperator == .eq || maxOperator == .na ? nil : maxOperator.rawValue,
                                     selectedDaysOfWeek: self.type == .dow || self.type == .wom ? self.selectedDaysOfWeek : [],
                                     selectedWeeksOfMonth: self.type == .wom ? self.selectedWeeks : [],
                                     selectedDaysOfMonth: self.type == .dom ? self.selectedDaysOfMonth : [])
        ttsViews.append(ttsv)
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
                            self.save()
                            self.isBeingPresented = false
                        }, label: { Text("Save") })
                            .disabled(self.maxOperator == .na && self.minOperator == .na)
                            .disabled(self.maxOperator == .eq && self.minOperator == .eq)
                            .disabled(!validDaysSelected())
                        Spacer()
                        Text("Add Target Set")
                            .font(.title)
                        Spacer()
                        
                        Button(action: {
                            self.isBeingPresented = false
                        }, label: { Text("Cancel") })
                    }
                }
                
                // MARK: - Bubbles/DayPattern picker
                
                Group {
                    
                    // Days of week/month
                    BubbleRowsToggleable(maxBubbleRadius: 32,
                                         bubbles: self.type == ttsType.dom ? dividedDaysOfMonth : daysOfWeek,
                                         selectedBubbles: self.type == ttsType.dom ? self.$selectedDaysOfMonth : self.$selectedDaysOfWeek)
                    
                    // Weeks of month
                    if self.type == .wom {
                        BubbleRowsToggleable(bubblesPerRow: 5,
                                             maxBubbleRadius: 32,
                                             bubbles: weeksOfMonth,
                                             selectedBubbles: self.$selectedWeeks)
                    }
                    
                    Picker(selection: self.$type, label: Text("Type")) {
                        ForEach(ttsType.allCases, id: \.self) { typeLabel in
                            Text(typeLabel.rawValue)
                        }
                    }.frame(height: typePickerHeight)
                    
                }
                
                // MARK: - Target setter
                
                HStack(alignment: .center, spacing: 10) {
                    
                    TextField("Low value", text: self.$minValue)
                        .disabled(self.maxOperator == .eq || self.minOperator == .na)
                        .keyboardType( .decimalPad )
                        .padding(10)
                        .foregroundColor(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-text-colors") : .black )
                        .border(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-border-colors") : Color.init("default-border-colors"), width: 2)
                        .background(self.maxOperator == .eq || self.minOperator == .na ? Color.init("default-disabled-fill-colors") : .clear)
                        .cornerRadius(3)
                    
                    Picker("Low op", selection: self.$minOperator) {
                        ForEach(SaveFormatter.equalityOperators.allCases, id: \.self) { op in
                            Text(op.rawValue)
                        }}
                        .frame(width: operationWidth, height: operationHeight)
                        .clipped()
                    
                    Text("Target")
                    
                    Picker("High op", selection: self.$maxOperator) {
                        ForEach(SaveFormatter.equalityOperators.allCases, id: \.self) { op in
                            Text(op.rawValue)
                        }}
                        .frame(width: operationWidth, height: operationHeight)
                        .clipped()
                    
                    TextField("High value", text: self.$maxValue)
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
