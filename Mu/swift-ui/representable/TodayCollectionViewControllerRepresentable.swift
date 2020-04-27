//
//  TodayCollectionViewControllerRepresentable.swift
//  Mu
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

struct TodayCollectionViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> TodayCollectionViewController {
        return TodayCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    func updateUIViewController(_ uiViewController: TodayCollectionViewController, context: Context) {}
    
}

struct TodayCollectionViewControllerRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        TodayCollectionViewControllerRepresentable()
    }
}
