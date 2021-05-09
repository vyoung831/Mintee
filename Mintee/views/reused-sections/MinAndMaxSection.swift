//
//  MinAndMaxSection.swift
//  Mu
//
//  Created by Vincent Young on 2/18/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct MinAndMaxSection: View {
    
    // UI Constants
    let pickerWidth: CGFloat = 55
    let pickerHeight: CGFloat = 100
    
    @Binding var minOperator: SaveFormatter.equalityOperator
    @Binding var maxOperator: SaveFormatter.equalityOperator
    @Binding var minValueString: String
    @Binding var maxValueString: String
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 10) {
            
            TextField("", text: self.$minValueString)
                .disabled(self.maxOperator == .eq || self.minOperator == .na)
                .keyboardType( .decimalPad )
                .padding(10)
                .border(Color.primary, width: 2)
                .background(self.maxOperator == .eq || self.minOperator == .na ? themeManager.disabledTextField : Color(UIColor.systemBackground))
                .foregroundColor(self.maxOperator == .eq || self.minOperator == .na ? themeManager.disabledTextFieldText : .primary)
                .cornerRadius(3)
                .accessibility(identifier: "minimum-value")
            
            Picker("Low op", selection: self.$minOperator) {
                ForEach(SaveFormatter.equalityOperator.allCases, id: \.self) { op in
                    Text(op.stringValue)
                }
            }
            .foregroundColor(.accentColor)
            .frame(width: pickerWidth, height: pickerHeight)
            .clipped()
            
            Text("Target")
            
            Picker("High op", selection: self.$maxOperator) {
                ForEach(SaveFormatter.equalityOperator.allCases, id: \.self) { op in
                    Text(op.stringValue)
                }
            }
            .foregroundColor(.accentColor)
            .frame(width: pickerWidth, height: pickerHeight)
            .clipped()
            
            TextField("", text: self.$maxValueString)
                .disabled(self.minOperator == .eq || self.maxOperator == .na)
                .keyboardType( .decimalPad )
                .padding(10)
                .border(Color.primary, width: 2)
                .background(self.minOperator == .eq || self.maxOperator == .na ? themeManager.disabledTextField : Color(UIColor.systemBackground))
                .foregroundColor(self.minOperator == .eq || self.maxOperator == .na ? themeManager.disabledTextFieldText : .primary)
                .cornerRadius(3)
                .accessibility(identifier: "maximum-value")
            
        }.labelsHidden()
        
    }
    
}
