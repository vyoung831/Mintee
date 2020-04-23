//
//  TodayViewController.swift
//  Mu
//
//  This UIViewController handles the presentation of the initial page of the Today tab of TabBarController. It is the first UIViewController pushed onto the navigation stack of TodayNavigationController
//
//  Created by Vincent Young on 4/4/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit
import SwiftUI

class TodayViewController: UIViewController {
    
    // Constants
    let navbarTitle: String = "Today"
    
    // UICollectionView containing Task cards
    var collectionView: UICollectionView!
    let collectionViewCellReuseIdentifier: String = "task-card"
    
    // collectionView layout and appearance
    let collectionViewEdgeInsetTop: CGFloat = 20
    let collectionViewEdgeInsetBottom: CGFloat = 20
    let collectionViewLineSpacing: CGFloat = 20
    let collectionViewMinimumHorizontalSpacing: CGFloat = 20
    
    // collectionView cell sizing
    let collectionViewItemWidth: CGFloat = 150
    let collectionViewItemHeight: CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupCollectionView()
    }
    
    private func setupNavbar() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchButtonPressed))
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonPressed))
        let dateButton = UIBarButtonItem(title: "Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dateButtonPressed))
        
        self.navigationItem.leftBarButtonItems = [searchButton,dateButton]
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.title = navbarTitle
    }
    
    private func setupCollectionView() {
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.itemSize = CGSize(width: collectionViewItemWidth, height: collectionViewItemHeight)
        collectionViewFlowLayout.minimumLineSpacing = collectionViewLineSpacing
        
        /*
         * Here, collectionView's minimumInteritemSpacing and sectionInset is calculated
         * collectionViewMinimumHorizontalSpacing represents both the collection view's minimum left/right insets and inter-item spacing.
         * Given the constants collectionViewItemWidth and collectionViewMinimumHorizontalSpacing, the maximum amount of cells that can fit into a row is calculated.
         * Then, collectionView's section insets and minimumInteritemSpacing are adjusted to be equal.
         */
        let maxCellsPerRow = floor((self.view.bounds.width - collectionViewMinimumHorizontalSpacing)/(collectionViewFlowLayout.itemSize.width + collectionViewMinimumHorizontalSpacing))
        let actualHorizontalSpacing = (self.view.bounds.width - (maxCellsPerRow*collectionViewFlowLayout.itemSize.width))/(maxCellsPerRow + 1)
        collectionViewFlowLayout.minimumInteritemSpacing = actualHorizontalSpacing
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: collectionViewEdgeInsetTop, left: actualHorizontalSpacing, bottom: collectionViewEdgeInsetBottom, right: actualHorizontalSpacing)
        
        // Setup collectionView's layout and appearance
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.backgroundColor = UIColor.white
        
        // Set collectionView's delegate and data source, and register UICollectionViewCells for reuse
        collectionView.register(TaskCardCollectionViewCell.self,forCellWithReuseIdentifier: collectionViewCellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    @objc func searchButtonPressed() {
        // TO-DO: Present SetFilter
    }
    
    @objc func addButtonPressed() {
        // TO-DO: Present AddTask
    }
    
    @objc func dateButtonPressed() {
        // TO-DO: Present SelectDatePopup
    }
    
}

// MARK: - UICollectionViewDataSource extension

extension TodayViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TO-DO: Push TaskSummary onto navigation task
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TO-DO: Retrieve Task count from CoreData
        return 48
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellReuseIdentifier,for: indexPath) as? TaskCardCollectionViewCell {
            
            cell.backgroundColor = .white
            
            // TaskCardCollectionViewCell calls its handleEditButtonPressed closure when its subview editButton is pressed. Set it here
            cell.handleEditButtonPressed = { [unowned self] in
                // TO-DO: Present EditTask
                print("Go to EditTask")
            }
            
            cell.handleSetButtonPressed = { [unowned self] in
                // TO-DO: Present SetCountPopup
                print("Go to SetCountPopup")
            }
            return cell
            
        } else {
            exit(-1)
        }
        
    }
    
}

// MARK: - UICollectionViewDelegate extension

extension TodayViewController: UICollectionViewDelegate {
    
}
