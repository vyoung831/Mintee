//
//  AddAnalysis.swift
//  Mintee
//
//  Created by Vincent Young on 2/13/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct AddAnalysis: View {
    
    @Binding var isBeingPresented: Bool
    
    @State var errorMessage: String = ""
    
    @State var analysisName: String = ""
    @State var analysisType: SaveFormatter.analysisType = .box
    @State var tags: [String] = []
    
    // Date range selection vars
    @State var rangeType: AnalysisUtils.dateRangeType = .startEnd
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var dateRangeString: String = ""
    
    @State var legendSection: LegendSection = LegendSection()
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    private func saveAnalysis() -> Bool {
        
        if tags.count < 1 {
            self.errorMessage = "Add at least one Tag for the Analysis to use"
            return false
        }
        
        do {
            switch rangeType {
            case .startEnd:
                let _ = try Analysis(entity: Analysis.entity(),
                                            insertInto: CDCoordinator.moc,
                                            name: analysisName,
                                            type: self.analysisType,
                                            startDate: self.startDate,
                                            endDate: self.endDate,
                                            legend: legendSection.createAnalysisLegend(),
                                            tags: Set(self.tags))
            case .dateRange:
                guard let range = Int16(dateRangeString) else {
                    self.errorMessage = "Remove invalid input from date range"
                    return false
                }
                let _ = try Analysis(entity: Analysis.entity(),
                                            insertInto: CDCoordinator.moc,
                                            name: analysisName,
                                            type: self.analysisType,
                                            dateRange: range,
                                            legend: legendSection.createAnalysisLegend(),
                                            tags: Set(self.tags))
            }
        } catch {
            self.errorMessage = ErrorManager.unexpectedErrorMessage
            return false
        }
        
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            self.errorMessage = "Save failed. Please check if another Analysis with this name already exists"
            return false
        }
        
    }
    
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
                            .accessibility(identifier: "add-analysis-error-message")
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
            .navigationTitle("Add Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                
                leading: Button(action: {
                    if self.saveAnalysis() {
                        self.isBeingPresented = false
                    }
                }, label: {
                    Text("Save")
                })
                .foregroundColor(.accentColor)
                .accessibility(identifier: "add-analysis-save-button")
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
