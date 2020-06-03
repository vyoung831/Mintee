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
    
    enum equalityOperators: String, CaseIterable {
        case lt = "<"
        case lte = "<="
        case eq = "="
    }
    
    // MARK: - UI constants and calculated variables
    
    let typePickerHeight: CGFloat = 125
    let textFieldWidth: CGFloat = 55
    let operationWidth: CGFloat = 55
    let operationHeight: CGFloat = 100
    
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
    
    // MARK: - State variables
    
    @State var type: AddTaskTargetSetPopup.ttsType = .dow
    @State var operatorLow: equalityOperators = .lt
    @State var operatorHigh: equalityOperators = .lt
    @State var valueLow: String = "0"
    @State var valueHigh: String = "0"
    
    // MARK: - Bindings
    
    @Binding var isBeingPresented: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true, content: {
            VStack(alignment: .center, spacing: 20) {
                
                // MARK: - Title bar
                
                Group {
                    HStack {
                        Button(action: {
                            self.isBeingPresented = false
                        }, label: { Text("Save") })
                        
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
                    BubbleRows(bubbles: self.type == ttsType.dom ? dividedDaysOfMonth : daysOfWeek , selectedBubbles: [])
                }
                
                // MARK: - TaskTargetSet type picker
                
                Group {
                    Picker(selection: self.$type, label: Text("Type")) {
                        ForEach(ttsType.allCases, id: \.self) { typeLabel in
                            Text(typeLabel.rawValue)
                        }
                    }.frame(height: typePickerHeight)
                }
                
                // MARK: - Target setter
                
                HStack(alignment: .center, spacing: 10) {
                    
                    TextField("Low value", text: self.$valueLow)
                        .keyboardType( .decimalPad )
                        .padding(10)
                        .border(Color.init("default-border-colors"), width: 3)
                        .cornerRadius(3)
                    
                    Picker("Low op", selection: self.$operatorLow) {
                        ForEach(equalityOperators.allCases, id: \.self) { op in
                            Text(op.rawValue)
                        }}
                        .frame(width: operationWidth, height: operationHeight)
                        .clipped()
                    
                    Text("Target")
                    
                    Picker("High op", selection: self.$operatorHigh) {
                        ForEach(equalityOperators.allCases, id: \.self) { op in
                            Text(op.rawValue)
                        }}
                        .frame(width: operationWidth, height: operationHeight)
                        .clipped()
                    
                    TextField("High value", text: self.$valueHigh)
                        .keyboardType( .decimalPad )
                        .padding(10)
                        .border(Color.init("default-border-colors"), width: 3)
                        .cornerRadius(3)
                    
                }.labelsHidden()
            }
        }).padding(15)
    }
}

//struct AddTaskTargetSetPopup_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTaskTargetSetPopup()
//    }
//}
