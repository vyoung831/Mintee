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
    @State var tags: [String] = [] // TO-DO: Define and enforce a standard for Mintee forms to follow when presenting associated entities for user interaction.
    
    // Date range selection vars
    @State var rangeType: AnalysisUtils.dateRangeType = .startEnd
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var dateRangeString: String = ""
    
    // Legend vars
    @State var legendType: AnalysisLegend.EntryType = .categorized
    @State var legendPreviews: [CategorizedLegendEntryPreview] = CategorizedLegendEntryPreview.getDefaults()
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    private func saveAnalysis() -> Bool {
        
        if tags.count < 1 {
            self.errorMessage = "Add at least one Tag for the Analysis to use"
            return false
        }
        
        var categorizedLegendEntries = Set<CategorizedLegendEntry>()
        var tagsToAssociate = Set<Tag>()
        do {
            
            for preview in legendPreviews {
                categorizedLegendEntries.insert(
                    try CategorizedLegendEntry(category: preview.category, color: UIColor(preview.color))
                )
            }
            
            for tagName in self.tags {
                if let tag = try Tag.getTag(tagName: tagName) {
                    tagsToAssociate.insert(tag)
                }
            }
            
        } catch {
            self.errorMessage = ErrorManager.unexpectedErrorMessage
            CDCoordinator.moc.rollback()
            return false
        }
        let legend = AnalysisLegend(categorizedEntries: categorizedLegendEntries, completionEntries: Set())
        
        do {
            switch rangeType {
            case .startEnd:
                let _ = try Analysis(entity: Analysis.entity(),
                                            insertInto: CDCoordinator.moc,
                                            name: analysisName,
                                            type: self.analysisType,
                                            startDate: self.startDate,
                                            endDate: self.endDate,
                                            legend: legend,
                                            order: -1,
                                            tags: tagsToAssociate)
            case .dateRange:
                
                if self.dateRangeString.count < 1 {
                    self.errorMessage = "Specify a date range"
                    CDCoordinator.moc.rollback()
                    return false
                }
                
                guard let range = Int16(dateRangeString) else {
                    self.errorMessage = "Remove invalid input from date range"
                    CDCoordinator.moc.rollback()
                    return false
                }
                
                let _ = try Analysis(entity: Analysis.entity(),
                                            insertInto: CDCoordinator.moc,
                                            name: analysisName,
                                            type: self.analysisType,
                                            dateRange: range,
                                            legend: legend,
                                            order: -1,
                                            tags: tagsToAssociate)
            }
        } catch {
            self.errorMessage = ErrorManager.unexpectedErrorMessage
            CDCoordinator.moc.rollback()
            return false
        }
        
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            self.errorMessage = "Save failed. Please check if another Analysis with this name already exists"
            CDCoordinator.moc.rollback()
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
                    ForEach(0 ..< legendPreviews.count, id: \.self) { idx in
                        ColorPicker("\(legendPreviews[idx].getLabel())", selection: $legendPreviews[idx].color)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(legendPreviews[idx].color)
                            .border(themeManager.collectionItemBorder, width: 3)
                            .cornerRadius(5)
                    }
                    
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
