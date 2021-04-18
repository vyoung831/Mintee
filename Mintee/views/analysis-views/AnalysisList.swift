//
//  AnalysisList.swift
//  Mintee
//
//  This View's implementation was based largely on the accepted answer here: https://stackoverflow.com/questions/62606907/swiftui-using-ondrag-and-ondrop-to-reorder-items-within-one-single-lazygrid
//
//  Created by Vincent Young on 4/7/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

struct AnalysisList: View {
    
    @Binding var isBeingPresented: Bool
    
    @StateObject var model: AnalysisListModel = AnalysisListModel()
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            
            GeometryReader { gr in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: [GridItem(.fixed(gr.size.width))]) {
                        
                        ForEach(model.sortedPreviews) { preview in
                            AnalysisListCard(togglePreview: {
                                AnalysisListModel.togglePreview(preview: preview, previews: &model.sortedPreviews)
                            },
                            isChecked: preview.id._order >= 0 ? true : false,
                            analysis: preview.id)
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
                                        self.isBeingPresented = false
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
    
    @State var isChecked: Bool
    
    @ObservedObject var analysis: Analysis
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            if let analysisName = analysis._name,
               let analysisType = SaveFormatter.storedToAnalysisType(analysis._analysisType) {
                
                HStack {
                    Text(analysisName)
                    Spacer()
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

/*
 This class fetches and maintains Analyses as a sorted array of identifiable and equatable previews.
 Because AnalysisList's user interaction doesn't edit the MOC in place, and because it needs a source of truth for its AnalysisListCards', this class serves as its source of truth.
 This class' previews thus represents both user interaction with AnalysisList's AnalysisListCards (through closures), and changes to the MOC (through NSFetchedResultsControllerDelegate functions).
 When the user presses save, the Analyses in the MOC are updated based on the previews' values.
 */
class AnalysisListModel: NSObject, ObservableObject {
    
    class AnalysisListCardPreview: Identifiable, Equatable {
        
        var id: Analysis
        var order: Int
        
        static func == (lhs: AnalysisListModel.AnalysisListCardPreview, rhs: AnalysisListModel.AnalysisListCardPreview) -> Bool {
            return lhs.id == rhs.id
        }
        
        init(id: Analysis, order: Int) {
            self.id = id
            self.order = order
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
                sortedPreviews.append(AnalysisListCardPreview(id: insertedAnalysis, order: -1))
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
