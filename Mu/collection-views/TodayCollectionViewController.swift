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
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
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
        collectionView.backgroundColor = UIColor(named: "default-panel-colors")
    }
    
    // MARK: - NSFetchedResultsController setup
    
    private func setupFetchedResults() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDCoordinator.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("TodayCollectionViewController was unable to execute NSFetchRequest during setup")
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
                cell.setTaskName(taskName: task.name ?? "")
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

extension TodayCollectionViewController : NSFetchedResultsControllerDelegate {
    
    func controller (_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            collectionView.insertSections([sectionIndex])
        case .delete:
            collectionView.deleteSections([sectionIndex])
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let path = newIndexPath {
                collectionView.insertItems(at: [path])
            }
        case .delete:
            if let path = indexPath {
                collectionView.deleteItems(at: [path])
            }
        case .update:
            if let path = indexPath {
                collectionView.reloadItems(at: [path])
            }
        case .move:
            if let source = indexPath, let target = newIndexPath {
                let minRow = min(source.row, target.row)
                let maxRow = max(source.row, target.row)
                for index in minRow...maxRow {
                    collectionView.reloadItems(at: [IndexPath.init(row: index, section: source.section)])
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // collectionView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //  collectionView.endUpdates()
    }
    
}

