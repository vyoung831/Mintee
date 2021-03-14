//
//  AnalysisView.swift
//  Mu
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct AnalysisView: View {
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    @State var isPresentingAddAnalysis: Bool = false
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .red
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    var body: some View {
        
        NavigationView {
            
            Group {
                
                TabView {
                    AnalysisGraphPage()
                    AnalysisTextPage()
                }
                .tabViewStyle(PageTabViewStyle())
                
            }
            .background(themeManager.panel)
            .navigationBarTitle("Analysis")
            .navigationBarItems(trailing:
                                    Button(action: {}, label: {
                                        Image(systemName: "plus.circle")
                                            .frame(width: 30, height: 30, alignment: .center)
                                            .foregroundColor(themeManager.panelContent)
                                            .accessibility(identifier: "add-analysis-button")
                                    })
                                    .scaleEffect(1.5)
            )
            
        }
        .sheet(isPresented: self.$isPresentingAddAnalysis, content: {
            AddAnalysis(isBeingPresented: self.$isPresentingAddAnalysis)
        })
        
        
    }
}

struct AnalysisGraphPage: View {
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: true, content: {
            Text("Sample page")
                .foregroundColor(themeManager.panelContent)
        })
        .padding(25)
        
    }
    
}

struct AnalysisTextPage: View {
    
    @ObservedObject var themeManager: ThemeManager = ThemeManager.shared
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: true, content: {
            Text("Sample page")
                .foregroundColor(themeManager.panelContent)
        })
        .padding(25)
        
    }
    
}
