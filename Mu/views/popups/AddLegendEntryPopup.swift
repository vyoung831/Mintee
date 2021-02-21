//
//  AddLegendEntryPopup.swift
//  Mu
//
//  Created by Vincent Young on 2/17/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddLegendEntryPopup: View {
    
    @State var color: Color = Color.red
    @State var minOperator: SaveFormatter.equalityOperator = .lt
    @State var maxOperator: SaveFormatter.equalityOperator = .lt
    @State var minValueString: String = ""
    @State var maxValueString: String = ""
    
    @Binding var isBeingPresented: Bool
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var save: (String, Color) -> ()
    
    var body: some View {
        
        NavigationView {
            
            GeometryReader { gr in
                
                VStack {
                    
                    HStack {
                        Spacer()
                        ColorPicker("Legend Color", selection: self.$color)
                        Spacer()
                    }
                    
                    MinAndMaxSection(minOperator: self.$minOperator, maxOperator: self.$maxOperator, minValueString: self.$minValueString, maxValueString: self.$maxValueString)
                    
                }
                
            }
            .padding(15)
            .background(themeManager.panel)
            .foregroundColor(themeManager.panelContent)
            .navigationBarTitle("Add Legend Entry")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        save("Some label", color)
                                        self.isBeingPresented = false
                                    }, label: {
                                        Text("Done")
                                    })
                                    .foregroundColor(.accentColor)
                                    .accessibility(identifier: "add-legend-entry-popup-done-button")
                                    .disabled(self.maxOperator == .na && self.minOperator == .na),
                                trailing:
                                    Button(action: {
                                        self.isBeingPresented = false
                                    }, label: {
                                        Text("Cancel")
                                    })
                                    .foregroundColor(.accentColor)
                                    .accessibility(identifier: "add-legend-entry-popup-cancel-button"))
            
        }
        .accentColor(themeManager.accent)
        
    }
    
}
