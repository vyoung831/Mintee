//
//  AnalysisList.swift
//  Mintee
//
//  Created by Vincent Young on 4/7/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct AnalysisList: View {
    
    @FetchRequest(
        entity: Analysis.entity(),
        sortDescriptors: []
    ) var analysesFetch: FetchedResults<Analysis>
    
    @Binding var isBeingPresented: Bool
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            
            GeometryReader { gr in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: [GridItem(.fixed(gr.size.width))]) {
                        ForEach(0 ..< self.analysesFetch.count, id: \.self) { idx in
                            AnalysisListCard(analysis: analysesFetch[idx])
                        }
                    }
                }
            }
            .padding(CollectionSizer.gridVerticalPadding)
            .background(themeManager.panel)
            .navigationTitle("Analyses")
            .navigationBarItems(trailing:
                                    Button(action: {
                                        self.isBeingPresented = false
                                    }, label: {
                                        Text("Done")
                                    })
            )
            
        }.accentColor(themeManager.accent)
        
    }
    
}

// MARK: - Struct for representing cards in AnalysisList

struct AnalysisListCard: View {
    
    let cardPadding: CGFloat = 15
    
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
                
            } else {
                ErrorView()
            }
            
        }
        .padding(cardPadding)
        .background(ThemeManager.getElementColor(.collectionItem, .system))
        .border(themeManager.collectionItemBorder, width: CollectionSizer.borderThickness)
        .cornerRadius(CollectionSizer.cornerRadius)
        .accentColor(themeManager.accent)
        
    }
    
}
