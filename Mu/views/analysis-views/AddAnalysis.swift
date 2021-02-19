//
//  AddAnalysis.swift
//  Mu
//
//  Created by Vincent Young on 2/13/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddAnalysis: View {
    
    @Binding var isBeingPresented: Bool
    @State var isPresentingLegendEntryPopup: Bool = false
    
    @State var errorMessage: String = ""
    
    @State var analysisName: String = ""
    @State var analysisType: SaveFormatter.analysisType = .box
    @State var tags: [String] = []
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var legendEntries: [LegendEntryView] = []
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: true, content: {
                VStack(alignment: .leading, spacing: 15, content: {
                    
                    // MARK: - Analysis name text field
                    
                    LabelAndTextFieldSection(label: "Analysis name",
                                             labelIdentifier: "analysis-name-label",
                                             textField: self.$analysisName,
                                             textFieldIdentifier: "analysis-name-text-field")
                    if (errorMessage.count > 0) {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibility(identifier: "add-analysis-error-message")
                    }
                    
                    // MARK: - Tags
                    TagsSection(label: "Include Tasks with Tags:",
                                tags: self.$tags)
                    
                    // MARK: - Analysis type
                    SaveFormatterSelectionSection<SaveFormatter.analysisType>(sectionLabel: "Analysis type",
                                                                              options: SaveFormatter.analysisType.allCases,
                                                                              selection: self.$analysisType)
                    
                    // MARK: - Start and end date
                    StartAndEndDateSection(startDate: self.$startDate,
                                           endDate: self.$endDate)
                    
                    // MARK: - Legend entries
                    LegendSection(isPresentingLegendEntryPopup: self.$isPresentingLegendEntryPopup,
                                  legendEntries: self.$legendEntries)
                    .popover(isPresented: self.$isPresentingLegendEntryPopup, content: {
                        AddLegendEntryPopup(isBeingPresented: self.$isPresentingLegendEntryPopup,
                                            save: { label, color in
                                                
                                                // LegendEntryViews are deleted by their indices that were calculated here. It's assumed that the LegendEntryViews will not be reordered
                                                let idx = self.legendEntries.count
                                                self.legendEntries.append(
                                                    LegendEntryView(delete: { self.legendEntries.remove(at: idx) },
                                                                    label: label,
                                                                    color: color))
                                            })
                    })
                    
                }).padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)) // VStack insets
            })
            .navigationTitle("Add Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                
                leading: Button(action: {
                    self.isBeingPresented = false
                }, label: {
                    Text("Save")
                })
                .foregroundColor(.accentColor)
                .accessibility(identifier: "add-analysis-save-button")
                .disabled(self.analysisName == ""),
                
                trailing: Button(action: {
                    self.isBeingPresented = false
                }, label: {
                    Text("Cancel")
                })
                .foregroundColor(.accentColor)
                
            )
            .background(themeManager.panel)
            .foregroundColor(themeManager.panelContent)
            
        }
        .accentColor(themeManager.accent)
        
    }
    
}
