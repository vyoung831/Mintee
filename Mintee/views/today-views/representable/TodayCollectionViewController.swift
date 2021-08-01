//
//  TodayCollectionViewController.swift
//  Mintee
//
//  Created by Vincent Young on 4/23/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI
import CoreData
import Firebase

class TodayCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<TaskInstance>?
    
    // collectionView setup constants
    let taskCardReuseIdentifier = "task-card"
    let itemTaskCardWidth: CGFloat = 150
    let taskCardHeightMultiplier: CGFloat = (4/3)
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        setUpCollectionView()
        setUpFetchedResults()
        observeNotificationCenter()
    }
    
    // MARK: - Appearance updates
    
    private func observeNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
    }
    
    @objc func updateTheme() {
        collectionView.backgroundColor = UIColor(ThemeManager.shared.panel)
    }
    
    // MARK: - UI setup
    
    private func setUpCollectionView() {
        
        collectionView.register(TodayCollectionViewCell.self, forCellWithReuseIdentifier: taskCardReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        updateTheme()
        
    }
    
    // MARK: - NSFetchedResultsController setup
    
    /**
     Initializes fetchedResultsController by querying for all TaskInstances with date = today
     */
    private func setUpFetchedResults() {
        let fetchRequest: NSFetchRequest<TaskInstance> = TaskInstance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "date", SaveFormatter.dateToStoredString(Date()))
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDCoordinator.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch (let error) {
            ErrorManager.recordNonFatal(.fetchRequest_failed,
                                        ["Message" : "TodayCollectionViewController.setUpFetchedResults() failed to call performFetch on fetchedResultsController",
                                         "fetchRequest" : fetchRequest.debugDescription,
                                         "error.localizedDescription" : error.localizedDescription])
            return
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
        
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: taskCardReuseIdentifier, for: indexPath)
        guard let cell = dequeuedCell as? TodayCollectionViewCell else {
            ErrorManager.recordNonFatal(.uiCollectionViewController_castDequeuedCellFailed,
                                        ["Message" : "TodayCollectionViewController could not cast dequeued UICollectionViewCell as TodayCollectionViewCell"])
            return dequeuedCell
        }
        
        if let instance = fetchedResultsController?.fetchedObjects?[indexPath.item] {
            
            guard let task = instance._task else {
                var userInfo: [String : Any] =
                    ["Message" : "TodayCollectionViewController.collectionView found a TaskInstance with nil _task"]
                if let taskThroughTargetSet = instance._targetSet?._task {
                    userInfo = taskThroughTargetSet.mergeDebugDictionary(userInfo: userInfo)
                } else {
                    userInfo["TaskInstance"] = instance.debugDescription
                }
                ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, userInfo)
                return cell
            }
            
            cell.setTaskName(taskName: task._name)
            cell.updateAppearance(instance: instance)
            cell.handleEditButtonPressed = {
                do {
                    let ethvc = try EditTaskHostingController(task: task,
                                                              dismiss: { [unowned self] in self.dismiss(animated: true, completion: nil) })
                    self.present(ethvc, animated: true, completion: nil)
                } catch {
                    let evhc = ErrorViewHostingController()
                    self.navigationController?.pushViewController(evhc, animated: true)
                }
            }
            
            cell.handleSetButtonPressed = {
                let scphc =
                    SetCountPopupHostingController(count: instance._completion, done: { [unowned self, instance] in
                        instance._completion = $0
                        CDCoordinator.shared.saveContext()
                        self.dismiss(animated: true, completion: nil)
                    }, cancel: { [unowned self] in
                        self.dismiss(animated: true, completion: nil)
                    })
                self.modalPresentationStyle = .overCurrentContext
                self.present(scphc, animated: true, completion: nil)
            }
        }
        return cell
    }
    
    /**
     The system calls this method when the iOS interface environment changes.
     Implement this method in view controllers and views, according to your app’s needs, to respond to such changes.
     For example, you might adjust the layout of the subviews of a view controller when an iPhone is rotated from portrait to landscape orientation.
     The default implementation of this method is empty.
     */
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if collectionView.frame.width > 0 {
            collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.collectionViewLayout =  CollectionSizer.getCollectionViewFlowLayout(widthAvailable: self.collectionView.frame.width,
                                                                                                    idealItemWidth: itemTaskCardWidth,
                                                                                                    heightMultiplier: taskCardHeightMultiplier).layout
        }
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

