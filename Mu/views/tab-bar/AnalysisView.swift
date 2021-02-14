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
            .navigationTitle("Analysis")
            
        }
        
    }
}

struct AnalysisGraphPage: View {
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: true, content: {
            Text("Graph page")
        })
        .padding(25)
        
    }
    
}

struct AnalysisTextPage: View {
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: true, content: {
            Text("Text page")
        })
        .padding(25)
        
    }
    
}
