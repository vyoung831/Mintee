//
//  AnalysisView.swift
//  Mintee
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

struct AnalysisView: View {
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    @State var isPresentingAddAnalysis: Bool = false
    @State var isPresentingAnalysisList: Bool = false
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .red
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    @FetchRequest(
        // TO-DO: Update NSSortDescriptor to use more robust way to sort Task name
        entity: Analysis.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var analysesFetch: FetchedResults<Analysis>
    
    var body: some View {
        
        NavigationView {
            
            TabView {
                ForEach(0 ..< analysesFetch.count, id: \.self) { idx in
                    if self.analysesFetch[idx]._order >= 0 {
                        AnalysisGraphPage(analysis: self.analysesFetch[idx])
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .background(themeManager.panel)
            .navigationBarTitle("Analysis")
            .navigationBarItems(trailing: HStack {
                
                Button(action: {
                    self.isPresentingAddAnalysis = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(themeManager.panelContent)
                        .accessibility(identifier: "add-analysis-button")
                })
                .scaleEffect(1.5)
                .sheet(isPresented: self.$isPresentingAddAnalysis, content: {
                    AddAnalysis(isBeingPresented: self.$isPresentingAddAnalysis)
                })
                
                Button(action: {
                    self.isPresentingAnalysisList = true
                }, label: {
                    Image(systemName: "list.bullet")
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(themeManager.panelContent)
                        .accessibility(identifier: "analysis-list-button")
                })
                .scaleEffect(1.5)
                .sheet(isPresented: self.$isPresentingAnalysisList, content: {
                    AnalysisList(isBeingPresented: self.$isPresentingAnalysisList)
                        .environment(\.managedObjectContext, CDCoordinator.moc)
                })
                
            })
            
        }
        
    }
}


struct AnalysisGraphPage: View {
    
    @ObservedObject var analysis: Analysis
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: true) {
            
            VStack(alignment: .center, spacing: 10) {
                
                Rectangle()
                    .fill(Color.clear)
                    .border(themeManager.panelContent, width: 5)
                    .cornerRadius(3)
                    .frame(height: 300)
                
                HStack {
                    Text(analysis._name ?? "")
                        .font(.largeTitle)
                    Spacer()
                }
                
                HStack {
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
                    Spacer()
                }
                
                HStack(spacing: 15) {
                    Text("Tags included:")
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 8) {
                            ForEach(0 ..< analysis.getTagNames().count) { idx in
                                TagView(name: analysis.getTagNames().sorted()[idx], removable: false, remove: {})
                            }
                        }
                    }
                }
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                
            }
            
        }
        .foregroundColor(themeManager.panelContent)
        .padding(25)
        
    }
    
}
