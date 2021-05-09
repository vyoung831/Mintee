//
//  EditAnalysis.swift
//  Mintee
//
//  Created by Vincent Young on 4/22/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct EditAnalysis: View {
    
    let deleteMessage: String = "Are you sure you want to delete this Analysis?"
    
    @State var errorMessage: String = ""
    @Binding var isBeingPresented: Bool
    
    // Vars that must be supplied by the parent View
    var analysis: Analysis
    @State var analysisName: String
    @State var tags: [String] // TO-DO: Define and enforce a standard for Mintee forms to follow when presenting associated entities for user interaction.
    @State var analysisType: SaveFormatter.analysisType
    @State var rangeType: AnalysisUtils.dateRangeType
    @State var legendType: AnalysisLegend.EntryType
    @State var legendPreviews: [CategorizedLegendEntryPreview]
    
    // Vars that may not exist depending on rangeType's value. Initial values are assigned in case user toggles rangeType.
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var dateRangeString: String = ""
    
    @State var deleteErrorMessage: String = ""
    @State var isPresentingConfirmDeletePopup: Bool = false
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    private func saveAnalysis() -> Bool {
        
        if tags.count < 1 {
            self.errorMessage = "Add at least one Tag for the Analysis to use"
            return false
        }
        
        switch self.rangeType {
        case .dateRange:
            guard let range = Int16(dateRangeString) else {
                self.errorMessage = "Remove invalid input from date range"
                CDCoordinator.moc.rollback()
                return false
            }
            self.analysis.updateDateRange(range)
            break
        case .startEnd:
            self.analysis.updateStartAndEndDates(start: self.startDate, end: self.endDate)
            break
        }
        
        var categorizedLegendEntries = Set<CategorizedLegendEntry>()
        do {
            
            for preview in legendPreviews {
                categorizedLegendEntries.insert(
                    try CategorizedLegendEntry(category: preview.category, color: UIColor(preview.color))
                )
            }
            
            var tagsToAssociate: Set<Tag> = Set()
            for tagName in self.tags {
                if let tag = try Tag.getTag(tagName: tagName) {
                    tagsToAssociate.insert(tag)
                }
            }
            try self.analysis.associateTags(tagsToAssociate)
            
        } catch {
            self.errorMessage = ErrorManager.unexpectedErrorMessage
            CDCoordinator.moc.rollback()
            return false
        }
        
        /*
         Update analysis' values in MOC
         */
        analysis.updateLegend(categorizedEntries: categorizedLegendEntries)
        self.analysis._name = analysisName
        self.analysis.updateAnalysisType(self.analysisType)
        do {
            try CDCoordinator.moc.save()
            return true
        } catch {
            self.errorMessage = "Save failed. Please check if another Analysis with this name already exists"
            CDCoordinator.moc.rollback()
            return false
        }
        
    }
    
    private func deleteAnalysis() {
        
        do {
            self.analysis.deleteSelf()
            try CDCoordinator.moc.save()
            self.isBeingPresented = false
        } catch {
            CDCoordinator.moc.rollback()
            self.deleteErrorMessage = ErrorManager.unexpectedErrorMessage
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
                    ForEach(0 ..< legendPreviews.count, id: \.self) { idx in
                        ColorPicker("\(legendPreviews[idx].getLabel())", selection: $legendPreviews[idx].color)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(legendPreviews[idx].color)
                            .border(themeManager.collectionItemBorder, width: 3)
                            .cornerRadius(5)
                    }
                    
                    // MARK: - Analysis deletion
                    
                    Group {
                        Button(action: {
                            self.isPresentingConfirmDeletePopup = true
                        }, label: {
                            Text("Delete Analysis")
                                .padding(.all, 10)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(3)
                        })
                        
                        if (deleteErrorMessage.count > 0) {
                            Text(deleteErrorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    .sheet(isPresented: self.$isPresentingConfirmDeletePopup, content: {
                        ConfirmDeletePopup(deleteMessage: self.deleteMessage,
                                           deleteList: [],
                                           delete: { self.deleteAnalysis() },
                                           isBeingPresented: self.$isPresentingConfirmDeletePopup)
                    })
                    
                }).padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)) // VStack insets
            })
            .navigationTitle("Edit Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                
                leading: Button(action: {
                    if saveAnalysis() {
                        self.isBeingPresented = false
                    }
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
