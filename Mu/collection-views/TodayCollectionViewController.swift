//
//  TodayCollectionViewController.swift
//  Mu
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData

class TodayCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<Task>?
    var moc: NSManagedObjectContext?
    
    // collectionView setup constants
    let taskCardReuseIdentifier = "task-card"
    let itemSize = CGSize(width: 150, height: 200)
    let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let minimumLineSpacing: CGFloat = 20
    let minimumInteritemSpacing: CGFloat = 20
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(moc: NSManagedObjectContext) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.moc = moc
        setupCollectionView()
        setupFetchedResults()
    }
    
    // MARK: - UI setup
    
    private func setupCollectionView() {
        collectionView.register(TodayCollectionViewCell.self, forCellWithReuseIdentifier: taskCardReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = self.itemSize
        collectionViewLayout.sectionInset = self.insets
        collectionViewLayout.minimumInteritemSpacing = self.minimumInteritemSpacing
        collectionViewLayout.minimumLineSpacing = self.minimumLineSpacing
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.backgroundColor = .white
    }
    
    // MARK: - NSFetchedResultsController setup
    
    private func setupFetchedResults() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let managedObjectContext = moc {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("TodayCollectionViewController was unable to execute NSFetchRequest during setup")
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

extension TodayCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fetchCount = fetchedResultsController?.fetchedObjects?.count {
            return fetchCount
        }
        return 0
    }
    
    /**
     Attempts to return a cell of type TodayCollectionViewCell. Because this UICollectionViewController doesn't use any sections, the Task at (indexPath) of fetchedResultsController's objects is retrieved.
     This function provides the cell with task to display and with a Task-specific closure to call when its edit button is pressed.
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: taskCardReuseIdentifier, for: indexPath) as? TodayCollectionViewCell {
            if let task = fetchedResultsController?.fetchedObjects?[indexPath.item] {
                cell.setTaskName(taskName: task.taskName ?? "")
                cell.updateCompletionMeter(newCompletionPercentage: CGFloat(Float(arc4random()) / Float(UINT32_MAX)))
                
                cell.handleEditButtonPressed = {
                    let ethvc = EditTaskHostingController(task: task, dismiss: { [unowned self] in
                        self.dismiss(animated: true, completion: nil)
                    })
                    self.present(ethvc, animated: true, completion: nil)
                }
            
                cell.handleSetButtonPressed = {
                    // TO-DO: Present SetCountPopup
                    print("Set button pressed")
                }
                
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension TodayCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.reloadData()
    }
    
}
