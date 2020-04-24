//
//  TodayCollectionViewControllerRepresentable.swift
//  Mu
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TodayCollectionViewControllerRepresentable: UIViewControllerRepresentable {
    
    @Environment(\.managedObjectContext) var moc
    
    func makeUIViewController(context: Context) -> TodayCollectionViewController {
        return TodayCollectionViewController(moc: moc)
    }
    
    func updateUIViewController(_ uiViewController: TodayCollectionViewController, context: Context) {
        
    }
    
}

struct TodayCollectionViewControllerRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        TodayCollectionViewControllerRepresentable()
    }
}
