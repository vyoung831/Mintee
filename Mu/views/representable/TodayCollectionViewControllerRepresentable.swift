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
    
    typealias UIViewControllerType = TodayCollectionViewController
    
    @Binding var date: Date
    
    func makeUIViewController(context: Context) -> TodayCollectionViewController {
        return TodayCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    func updateUIViewController(_ uiViewController: TodayCollectionViewController, context: Context) {
        
        // Only have TodayCollectionViewController do a re-fetch if the date from TodayView has changed
        let newPredicate = NSPredicate(format: "%K == %@", "date", SaveFormatter.dateToStoredString(self.date))
        if uiViewController.fetchedResultsController?.fetchRequest.predicate?.predicateFormat != newPredicate.predicateFormat {
            do {
                uiViewController.fetchedResultsController?.fetchRequest.predicate = newPredicate
                try uiViewController.fetchedResultsController?.performFetch()
                uiViewController.collectionView.reloadData()
            } catch  {
                print("Error")
            }
        }
        
    }
    
}
