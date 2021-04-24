//
//  EditAnalysis.swift
//  Mintee
//
//  Created by Vincent Young on 4/22/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct EditAnalysis: View {
    
    @State var errorMessage: String = ""
    @Binding var isBeingPresented: Bool
    
    // Vars that must be supplied by the parent View
    @State var analysisName: String
    @State var tags: [String]
    @State var analysisType: SaveFormatter.analysisType
    @State var rangeType: AnalysisUtils.dateRangeType
    @State var legendSection: LegendSection
    @ObservedObject var analysis: Analysis
    
    // Vars that may not exist depending on rangeType's value. Initial values are assigned in case user toggles rangeType.
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var dateRangeString: String = ""
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            ScrollView(.vertical, showsIndicators: true, content: {
                VStack(alignment: .leading, spacing: 15, content: {
                    
                    // MARK: - Analysis name text field
                    LabelAndTextFieldSection(label: "Analysis name",
                                             labelIdentifier: "analysis-name-label",
                                             placeHolder: "Analysis name",
                                             textField: self.$analysisName,
                                             textFieldIdentifier: "analysis-name-text-field")
                    if (errorMessage.count > 0) {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibility(identifier: "edit-analysis-error-message")
                    }
                    
                    // MARK: - Tags
                    TagsSection(allowedToAddNewTags: false,
                                label: "Include Tasks with Tags:",
                                formType: "analysis",
                                tags: self.$tags)
                    
                    // MARK: - Analysis type
                    SelectableTypeSection<SaveFormatter.analysisType>(sectionLabel: "Analysis type",
                                                                      options: SaveFormatter.analysisType.allCases,
                                                                      selection: self.$analysisType)
                    
                    // MARK: - Date range selection
                    SelectableTypeSection<AnalysisUtils.dateRangeType>(sectionLabel: "Date range",
                                                                       options: AnalysisUtils.dateRangeType.allCases,
                                                                       selection: self.$rangeType)
                    
                    if self.rangeType == .startEnd {
                        StartAndEndDateSection(startDate: self.$startDate,
                                               endDate: self.$endDate)
                    } else {
                        DateRangeTextFieldSection(dateRange: self.$dateRangeString)
                    }
                    
                    // MARK: - Legend entries
                    legendSection
                    
                }).padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)) // VStack insets
            })
            .navigationTitle("Edit Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                
                leading: Button(action: {
                    self.isBeingPresented = false
                }, label: {
                    Text("Save")
                })
                .foregroundColor(.accentColor)
                .accessibility(identifier: "edit-analysis-save-button")
                .disabled(self.analysisName.count < 1),
                
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
