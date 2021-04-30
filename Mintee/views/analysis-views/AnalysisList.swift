//
//  AnalysisList.swift
//  Mintee
//
//  This View's implementation was based largely on the accepted answer here: https://stackoverflow.com/questions/62606907/swiftui-using-ondrag-and-ondrop-to-reorder-items-within-one-single-lazygrid
//
//  Analyses are loaded from the MOC to present to the user. However, to avoid letting user interaction with AnalysisListCard edit the MOC in place, a model class (AnalysisListModel) serves as AnalysisList's source of truth.
//  AnalysisListModel fetches and maintains Analyses as a sorted array of identifiable and equatable previews, and AnalysisList draws/re-draws AnalysisListCards based on the AnalysisListModel's data.
//  AnalysisListModel's previews reflect both user interaction with AnalysisListCards (through closures), and changes to the MOC (through NSFetchedResultsControllerDelegate functions).
//  When the user presses `Save` on AnalysisList, the Analyses in the MOC are updated based on the previews' values.
//
//  Created by Vincent Young on 4/7/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct AnalysisList: View {
    
    @State var errorMessage: String = ""
    @State var draggedPreview: AnalysisListModel.AnalysisListCardPreview?
    @Binding var isBeingPresented: Bool
    
    @StateObject var model: AnalysisListModel = AnalysisListModel()
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    /**
     Re-assigns `order` to Analyses in the MOC by iterating over the model's previews.
     */
    func saveAnalysisOrdering() throws {
        
        for preview in model.sortedPreviews {
            if preview.order >= 0 {
                (preview.id as Analysis).setOrder(Int16(preview.order))
            } else {
                (preview.id as Analysis).setUnincluded()
            }
        }
        
        try CDCoordinator.moc.save()
        
    }
    
    var body: some View {
        
        NavigationView {
            
            GeometryReader { gr in
                ScrollView(.vertical, showsIndicators: true) {
                    
                    if errorMessage.count > 0 {
                        Text(self.errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    LazyVGrid(columns: [GridItem(.fixed(gr.size.width))]) {
                        
                        /*
                         Each AnalysisListCard's drop delegate re-sorts the model's sorted previews if the dragged preview enters.
                         To only allow AnalysisListCards to be dropped onto this page, each drop delegate maintains bindings to the dragged preview and to the model's sorted array of previews rather than using information in NSItemProvider.
                         */
                        ForEach(model.sortedPreviews) { preview in
                            AnalysisListCard(
                                togglePreview: {
                                    AnalysisListModel.togglePreview(preview: preview, previews: &model.sortedPreviews)
                                },
                                analysis: preview.id,
                                isChecked: preview.id._order >= 0 ? true : false
                            )
                            .onDrag({
                                // Only "included" previews can be dragged and reordered within AnalysisList.
                                if preview.order >= 0 {
                                    self.draggedPreview = preview
                                }
                                return NSItemProvider(object: "" as NSString)
                            })
                            .onDrop(of: [UTType.text], delegate: AnalysisListModel.AnalysisListCardDropDelegate(item: preview,
                                                                                                                sortedPreviews: $model.sortedPreviews,
                                                                                                                draggedPreview: self.$draggedPreview))
                        }
                        
                    }.animation(.default)
                    
                }
            }
            .padding(CollectionSizer.gridVerticalPadding)
            .background(themeManager.panel)
            .navigationTitle("Analyses")
            .navigationBarItems(leading:
                                    Button(action: {
                                        self.isBeingPresented = false
                                    }, label: {
                                        Text("Cancel")
                                    }),
                                trailing:
                                    Button(action: {
                                        do {
                                            try saveAnalysisOrdering()
                                            self.isBeingPresented = false
                                        } catch {
                                            var userInfo: [String : Any] = ["Message" : "AnalysisList failed to save new Analysis orders"]
                                            for idx in 0 ..< model.sortedPreviews.count {
                                                userInfo["preview[\(idx)].order"] = model.sortedPreviews[idx].order
                                                userInfo["preview[\(idx)].id"] = (model.sortedPreviews[idx].id as Analysis).debugDescription
                                                (model.sortedPreviews[idx].id as Analysis).mergeDebugDictionary(userInfo: &userInfo, prefix: "preview[\(idx)].id.")
                                            }
                                            ErrorManager.recordNonFatal(.persistentStore_saveFailed, userInfo)
                                            self.errorMessage = ErrorManager.unexpectedErrorMessage
                                        }
                                    }, label: {
                                        Text("Save")
                                    })
            )
            
        }.accentColor(themeManager.accent)
        
    }
    
}

// MARK: - Struct for representing cards in AnalysisList

struct AnalysisListCard: View {
    
    let cardPadding: CGFloat = 15
    let togglePreview: () -> () // Closure for toggling the order of the AnalysisListCardPreview held in AnalysisListModel.
    var analysis: Analysis
    
    @State var isChecked: Bool
    @State var isPresentingEditAnalysis: Bool = false
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    /**
     Using the `Analysis` assigned to this View, converts its AnalysisLegend to an array of CategorizedLegendEntryPreview.
     - returns: (Optional) Array of CategorizedLegendEntryPreview representing the Analysis' legend.
     */
    func extractCategorizedPreviews() -> [CategorizedLegendEntryPreview]? {
        
        guard let legend = self.analysis._legend else {
            var userInfo: [String : Any] = ["Message" : "AnalysisList.extractCategorizedPreviews() found nil legend in an Analysis"]
            self.analysis.mergeDebugDictionary(userInfo: &userInfo)
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
            return nil
        }
        
        var previews: [CategorizedLegendEntryPreview] = []
        for categorizedEntry in legend.categorizedEntries {
            guard let color = UIColor(hex: categorizedEntry.color) else {
                var userInfo: [String : Any] = ["Message" : "AnalysisList.extractCategorizedPreviews() could not initialize a UIColor from a CategorizedLegendEntry's color String"]
                self.analysis.mergeDebugDictionary(userInfo: &userInfo)
                ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
                return nil
            }
            previews.append(CategorizedLegendEntryPreview(color: Color(color), category: categorizedEntry.category))
        }
        return previews
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            if let analysisName = analysis._name,
               let analysisType = SaveFormatter.storedToAnalysisType(analysis._analysisType) {
                
                HStack {
                    Text(analysisName)
                    Spacer()
                    Button("Edit", action: {
                        self.isPresentingEditAnalysis = true
                    })
                    .foregroundColor(.primary)
                    .sheet(isPresented: self.$isPresentingEditAnalysis, content: {
                        if let legendPreviews = extractCategorizedPreviews() {
                            if let startString = analysis._startDate,
                               let endString = analysis._endDate,
                               let start = SaveFormatter.storedStringToDate(startString),
                               let end = SaveFormatter.storedStringToDate(endString) {
                                EditAnalysis(isBeingPresented: self.$isPresentingEditAnalysis,
                                             analysis: analysis,
                                             analysisName: analysisName,
                                             tags: analysis.getTagNames().sorted(),
                                             analysisType: analysisType,
                                             rangeType: .startEnd,
                                             legendType: .categorized,
                                             legendPreviews: CategorizedLegendEntryPreview.sortedPreviews(legendPreviews),
                                             startDate: start,
                                             endDate: end)
                            } else {
                                EditAnalysis(isBeingPresented: self.$isPresentingEditAnalysis,
                                             analysis: analysis,
                                             analysisName: analysisName,
                                             tags: analysis.getTagNames().sorted(),
                                             analysisType: analysisType,
                                             rangeType: .dateRange,
                                             legendType: .categorized,
                                             legendPreviews: CategorizedLegendEntryPreview.sortedPreviews(legendPreviews),
                                             dateRangeString: String(analysis._dateRange))
                            }
                        } else {
                            ErrorView()
                        }
                    })
                }
                
                Text("Type: \(analysisType.stringValue)")
                
                if let startString = analysis._startDate,
                   let endString = analysis._endDate,
                   let start = SaveFormatter.storedStringToDate(startString),
                   let end = SaveFormatter.storedStringToDate(endString) {
                    
                    // Start/end date analysis
                    Text("\(Date.toMDYPresent(start)) to \(Date.toMDYPresent(end))")
                    
                } else {
                    
                    // Ranged analysis
                    Text("Last \(analysis._dateRange) days")
                    
                }
                
                Button(action: {
                    isChecked.toggle()
                    togglePreview()
                }){
                    HStack{
                        Image(systemName: isChecked ? "checkmark.square": "square")
                        Text("Include on homepage")
                    }
                }.foregroundColor(.primary)
                
            } else {
                ErrorView()
            }
            
        }
        .padding(cardPadding)
        .background(ThemeManager.getElementColor(.collectionItem, .system))
        .border(themeManager.collectionItemBorder, width: CollectionSizer.borderThickness)
        .cornerRadius(CollectionSizer.cornerRadius)
        .accentColor(themeManager.accent)
        .opacity(self.isChecked ? 1 : 0.2)
        
    }
    
}

// MARK: - Mock model

class AnalysisListModel: NSObject, ObservableObject {
    
    class AnalysisListCardPreview: Identifiable, Equatable {
        
        @ObservedObject var id: Analysis
        var order: Int
        
        static func == (lhs: AnalysisListModel.AnalysisListCardPreview, rhs: AnalysisListModel.AnalysisListCardPreview) -> Bool {
            return lhs.id == rhs.id
        }
        
        init(id: Analysis, order: Int) {
            self.id = id
            self.order = order
        }
        
    }
    
    struct AnalysisListCardDropDelegate: DropDelegate {
        
        let item: AnalysisListCardPreview
        @Binding var sortedPreviews: [AnalysisListCardPreview]
        @Binding var draggedPreview: AnalysisListCardPreview?
        
        /**
         Called when a drop enters an AnalysisListCard with NSItemProvider of type `UTType.text` (AnalysisListCards' onDrag modifiers return NSItemProviders that carry empty NSStrings)
         If the binded-to dragged preview is non-nil, it's swapped with the AnalysisListPreview that's associated with this drop delegate.
         If the binded-to dragged preview is nil, a drop that originated elswhere entered, and this function disregards it.
         */
        func dropEntered(info: DropInfo) {
            if item != draggedPreview,
               item.order >= 0,
               let preview = draggedPreview,
               let draggedIndex = sortedPreviews.firstIndex(of: preview),
               let currentIndex = sortedPreviews.firstIndex(of: item) {
                sortedPreviews.swapAt(draggedIndex, currentIndex)
            }
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }
        
        func performDrop(info: DropInfo) -> Bool {
            AnalysisListModel.reorderPreviews(&sortedPreviews)
            draggedPreview = nil
            return true
        }
        
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Analysis> = NSFetchedResultsController()
    @Published var sortedPreviews: [AnalysisListCardPreview] = []
    
    override init() {
        super.init()
        setUpFetchedResults()
        AnalysisListModel.sortPreviews(&self.sortedPreviews)
    }
    
    /**
     Re-assigns `order` to an array of AnalysListCardPreview.
     All "included" previews before the first "nonincluded" preview have `order` reassigned based on their order in the array of previews.
     All previews after (and including) the first 'nonincluded' preview have `order` set to -1.
     - parameter previews: (inout) The array of AnalysisListCardPreview to reorder.
     */
    static func reorderPreviews(_ previews: inout [AnalysisListCardPreview]) {
        var order = 0
        let firstUnincluded = previews.firstIndex(where: { $0.order < 0 } ) ?? previews.count
        for idx in 0 ..< firstUnincluded {
            previews[idx].order = order
            order += 1
        }
        
        for idx in firstUnincluded ..< previews.count {
            previews[idx].order = -1
        }
    }
    
    /**
     Sorts an array of AnalysListCardPreview.
     Previews with order == -1 are sorted to the end of the array; others are sorted at the front of the array in ascending order of var `order`.
     - parameter previews: (inout) The array of AnalysisListCardPreview to sort.
     */
    static func sortPreviews(_ previews: inout [AnalysisListCardPreview]) {
        previews.sort(by: {
            if $0.order >= 0 && $1.order >= 0 {
                return $0.order < $1.order
            } else if $0.order >= 0 {
                return true
            } else {
                return false
            }
        })
    }
    
    /**
     Toggles the order of an AnalysisListCardPreview and re-sorts the provided (inout) previews.
     A preview that was to be included on the Analysis homepage (positive, non-zero order) has its order toggled to -1.
     Otherwise, the preview's order is set to the lowest priority compared to all currently  'included' previews.
     - parameter preview: The AnalysisListCardPreview in the previews for which to toggle order.
     - parameter previews: (inout) Array of AnalysisListCardPreview to look for `preview` in, and to re-sort.
     */
    static func togglePreview(preview: AnalysisListCardPreview, previews: inout [AnalysisListCardPreview]) {
        if previews.contains(preview) {
            if preview.order >= 0 {
                preview.order = -1
            } else {
                if let lastIncludedIndex = previews.lastIndex(where: { $0.order >= 0 }) {
                    preview.order = previews[lastIncludedIndex].order + 1
                } else {
                    preview.order = 0
                }
            }
        }
        AnalysisListModel.sortPreviews(&previews)
    }
    
}

extension AnalysisListModel: NSFetchedResultsControllerDelegate {
    
    /**
     Sets fetchedResultsController's delegate as AnalysisListModel, and performs initial fetch of Analyses.
     */
    private func setUpFetchedResults() {
        
        let fetchRequest: NSFetchRequest<Analysis> = Analysis.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDCoordinator.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if let fetchedAnalyses = fetchedResultsController.fetchedObjects {
                sortedPreviews = fetchedAnalyses.map{
                    AnalysisListCardPreview(id: $0, order: Int($0._order))
                }
            }
        } catch {
            ErrorManager.recordNonFatal(.fetchRequest_failed,
                                        ["Message" : "AnalysisListModel.setUpFetchedResults() failed to call performFetch on fetchedResultsController",
                                         "fetchRequest" : fetchRequest.debugDescription,
                                         "error.localizedDescription" : error.localizedDescription])
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            
            // A new Analysis was inserted into the MOC; insert it into the previews but set it as not included on Analysis homepage.
            if let insertedAnalysis = anObject as? Analysis {
                sortedPreviews.append(AnalysisListCardPreview(id: insertedAnalysis, order: Int(insertedAnalysis._order)))
                AnalysisListModel.sortPreviews(&self.sortedPreviews)
            }
            break
            
        case .delete:
            
            if let deletedAnalysis = anObject as? Analysis,
               let idx = sortedPreviews.firstIndex(where: { $0.id == deletedAnalysis }) {
                sortedPreviews.remove(at: idx)
                AnalysisListModel.sortPreviews(&self.sortedPreviews)
            }
            break
            
        case .update:
            // Invoked when a change occurs to an attribute of a fetched object that IS NOT included in the NSFetchedResultsController's sort descriptors.
            AnalysisListModel.sortPreviews(&self.sortedPreviews)
            break
        case .move:
            // Invoked when a change occurs to an attribute of a fetched object that IS included in the NSFetchedResultsController's sort descriptors.
            AnalysisListModel.sortPreviews(&self.sortedPreviews)
            break
        @unknown default:
            fatalError()
        }
        
    }
    
}
