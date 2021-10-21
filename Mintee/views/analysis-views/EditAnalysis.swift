//
//  EditAnalysis.swift
//  Mintee
//
//  Created by Vincent Young on 4/22/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

struct EditAnalysis: View {
    
    let deleteMessage: String = "Are you sure you want to delete this Analysis?"
    
    @State var errorMessage: String = ""
    var isBeingPresented: Binding<Bool>
    
    var analysis: Analysis?
    
    // Assign default values in case View initialization fails.
    @State var analysisName: String = ""
    @State var tags: [String] = [] // TO-DO: Define and enforce a standard for Mintee forms to follow when presenting associated entities for user interaction.
    @State var analysisType: SaveFormatter.analysisType = .box
    @State var rangeType: AnalysisUtils.dateRangeType = .startEnd
    @State var legendType: AnalysisLegend.EntryType = .categorized
    @State var legendPreviews: [CategorizedLegendEntryPreview] = CategorizedLegendEntryPreview.getDefaults()
    
    // Vars that may not exist depending on rangeType's value. Initial values are assigned in case user toggles rangeType.
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var dateRangeString: String = ""
    
    @State var deleteErrorMessage: String = ""
    @State var isPresentingConfirmDeletePopup: Bool = false
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    init(analysis: Analysis, presented: Binding<Bool>) {
        
        self.isBeingPresented = presented
        
        guard let type = analysis._analysisType else {
            NotificationCenter.default.post(name: .editAnalysis_initFailed, object: nil)
            return
        }
        
        guard let previews = EditAnalysis.extractCategorizedPreviews(analysis) else {
            NotificationCenter.default.post(name: .editAnalysis_initFailed, object: nil)
            return
        }
        
        if let start = analysis._startDate,
           let end = analysis._endDate {
            self._startDate = State(initialValue: start)
            self._endDate = State(initialValue: end)
            self._rangeType = State(initialValue: .startEnd)
        } else {
            self._dateRangeString = State(initialValue: String(analysis._dateRange))
            self._rangeType = State(initialValue: .dateRange)
        }
        
        self._analysisName = State(initialValue: analysis._name)
        self._analysisType = State(initialValue: type)
        self._legendPreviews = State(initialValue: previews)
        self._tags = State(initialValue: Array(analysis.getTagNames()))
        self.analysis = analysis
        
    }
    
    private func saveAnalysis(range: Int16 = 0) {
        guard let existingAnalysis = self.analysis else { return }
        
        let childContext = CDCoordinator.getChildContext()
        guard let childAnalysis = childContext.childAnalysis(existingAnalysis.objectID) else {
            NotificationCenter.default.post(name: .analysisUpdateFailed, object: nil); return
        }
        
        childContext.perform {
            switch self.rangeType {
            case .startEnd:
                childAnalysis.updateStartAndEndDates(start: self.startDate, end: self.endDate)
                break
            case .dateRange:
                childAnalysis.updateDateRange(range)
                break
            }
            
            var categorizedLegendEntries = Set<CategorizedLegendEntry>()
            do {
                let entries = try legendPreviews.map({ try CategorizedLegendEntry(category: $0.category, color: UIColor($0.color)) })
                categorizedLegendEntries = categorizedLegendEntries.union(Set(entries))
            } catch {
                let _ = ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                    ["Message" : "EditAnalysis.saveAnalysis() encountered an error when attempting to instantiate an array of CategorizedLegendEntry to save",
                                                     "error.localizedDescription" : error.localizedDescription])
                NotificationCenter.default.post(name: .analysisUpdateFailed, object: nil)
                return
            }
            
            do {
                try childAnalysis.updateTags(Set(self.tags), childContext)
            } catch {
                let _ = ErrorManager.recordNonFatal(.persistentStore_saveFailed,
                                                    ["Message" : "EditAnalysis.saveAnalysis() encountered an error when attempting to update an Analysis' tags",
                                                     "error.localizedDescription": error.localizedDescription])
                NotificationCenter.default.post(name: .analysisUpdateFailed, object: nil)
                return
            }
            
            // Update Analysis' values in MOC
            childAnalysis.updateLegend(categorizedEntries: categorizedLegendEntries)
            childAnalysis._name = analysisName
            childAnalysis.updateAnalysisType(self.analysisType)
            do {
                try CDCoordinator.saveAndMergeChanges(childContext)
            } catch {
                NotificationCenter.default.post(name: .analysisUpdateFailed, object: nil)
            }
        }
        
    }
    
    /**
     Deletes the Analysis associated from this View.
     Because this View presents this function as a closure for a confirmation popup to call, dismissal is also done in this function.
     */
    private func deleteAnalysis() {
        guard let existingAnalysis = self.analysis else { return }
        
        let childContext = CDCoordinator.getChildContext()
        guard let childAnalysis = childContext.childAnalysis(existingAnalysis.objectID) else {
            NotificationCenter.default.post(name: .analysisDeleteFailed, object: nil); return
        }
        
        childContext.perform {
            childAnalysis.deleteSelf(childContext)
            do {
                try CDCoordinator.saveAndMergeChanges(childContext)
                self.isBeingPresented.wrappedValue = false
            } catch {
                NotificationCenter.default.post(name: .analysisDeleteFailed, object: nil)
            }
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
                        }).disabled(self.analysis == nil)
                        
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
                        
                        if tags.count < 1 {
                            self.errorMessage = "Add at least one Tag for the Analysis to use"
                            return
                        }
                        
                        switch self.rangeType {
                        case .startEnd:
                            self.saveAnalysis(); break
                        case .dateRange:
                            guard let rangeCast = Int16(dateRangeString) else { self.errorMessage = "Enter a valid date range"; return }
                            self.saveAnalysis(range: rangeCast); break
                        }
                        self.isBeingPresented.wrappedValue = false
                        
                    }, label: {
                        Text("Save")
                    })
                        .foregroundColor(.accentColor)
                        .accessibility(identifier: "edit-analysis-save-button")
                        .disabled(self.analysisName.count < 1 || self.analysis == nil),
                    
                    trailing: Button(action: {
                        self.isBeingPresented.wrappedValue = false
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

// MARK: - Helper functions

extension EditAnalysis {
    
    /**
     Extracts an Analysis' AnalysisLegend to an array of CategorizedLegendEntryPreview.
     - returns: (Optional) Array of CategorizedLegendEntryPreview representing the Analysis' legend.
     */
    private static func extractCategorizedPreviews(_ analysis: Analysis) -> [CategorizedLegendEntryPreview]? {
        var previews: [CategorizedLegendEntryPreview] = []
        for categorizedEntry in analysis._legend.categorizedEntries {
            guard let color = UIColor(hex: categorizedEntry.color) else {
                var userInfo: [String : Any] = ["Message" : "EditAnalysis.extractCategorizedPreviews() found a CategorizedLegendEntry with `color` that could not be converted to a UIColor"]
                analysis.mergeDebugDictionary(userInfo: &userInfo)
                let _ = ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
                return nil
            }
            previews.append(CategorizedLegendEntryPreview(color: Color(color), category: categorizedEntry.category))
        }
        return previews
    }
    
}
