//
//  TodayCollectionView.swift
//  Mu
//
//  Created by Vincent Young on 4/21/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

class TodayCollectionView: UICollectionView {
    
    var fetchResults: NSFetchedResultsController<Task>?
    var moc: NSManagedObjectContext?
    
    // collectionView setup constants
    let taskCardReuseIdentifier = "task-card"
    let itemSize = CGSize(width: 150, height: 200)
    let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let minimumLineSpacing: CGFloat = 20
    let minimumInteritemSpacing: CGFloat = 20
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, moc: NSManagedObjectContext) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.moc = moc
        setupCollectionView()
        setupFetchedResults()
    }
    
    private func setupCollectionView() {
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: taskCardReuseIdentifier)
        self.dataSource = self
        self.delegate = self
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = itemSize
        collectionViewLayout.sectionInset = insets
        collectionViewLayout.minimumInteritemSpacing = minimumInteritemSpacing
        collectionViewLayout.minimumLineSpacing = minimumLineSpacing
        self.collectionViewLayout = collectionViewLayout
        
        self.backgroundColor = .white
    }
    
    private func setupFetchedResults() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let managedObjectContext = moc {
            fetchResults = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResults?.delegate = self
            do {
                try fetchResults?.performFetch()
            } catch {
                print("TodayCollectionView was unable to execute NSFetchRequest")
            }
        }
    }
    
}

extension TodayCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let frCount = fetchResults?.fetchedObjects?.count {
            return frCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: taskCardReuseIdentifier, for: indexPath)
        cell.backgroundColor = .lightGray
        if let task = fetchResults?.fetchedObjects?[indexPath.item] {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
            label.text = task.taskName
            cell.contentView.addSubview(label)
        }
        return cell
    }
    
}

extension TodayCollectionView: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.reloadData()
    }
    
}
