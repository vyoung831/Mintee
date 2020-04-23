//
//  TodayCollectionViewRepresentable.swift
//  Mu
//
//  Created by Vincent Young on 4/21/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

struct TodayCollectionViewRepresentable: UIViewRepresentable {
    
    @Environment(\.managedObjectContext) var moc
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = TodayCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout(), moc: self.moc)
        return collectionView
    }
    
    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {}
    
}

struct TodayCollectionViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        TodayCollectionViewRepresentable()
    }
}
