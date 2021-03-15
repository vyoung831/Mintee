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
    
    // Binding to date in TodayView
    @Binding var date: Date
    
    func makeUIViewController(context: Context) -> TodayCollectionViewController {
        return TodayCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    func updateUIViewController(_ uiViewController: TodayCollectionViewController, context: Context) {
        
        /*
         Construct an NSPredicate using the binding to TodayView's date and compare against the existing NSPredicate in TodayCollectionViewController's NSFetchedResultsController
         */
        let newPredicate = NSPredicate(format: "%K == %@", "date", SaveFormatter.dateToStoredString(self.date))
        if uiViewController.fetchedResultsController?.fetchRequest.predicate?.predicateFormat != newPredicate.predicateFormat {
            do {
                uiViewController.fetchedResultsController?.fetchRequest.predicate = newPredicate
                try uiViewController.fetchedResultsController?.performFetch()
                uiViewController.collectionView.reloadData()
            } catch (let error) {
                ErrorManager.recordNonFatal(.fetchRequest_failed,
                                            ["Message" : "TodayCollectionViewControllerRepresentable.updateUIViewController failed to call fetchRequest on TodayCollectionViewController's NSFetchedResultsController",
                                             "newPredicate" : newPredicate,
                                             "todayViewController.fetchedResultsController?.fetchRequest debugDescription" : uiViewController.fetchedResultsController?.fetchRequest.debugDescription,
                                             "error.localizedDescription" : error.localizedDescription])
            }
        }
        
    }
    
}
