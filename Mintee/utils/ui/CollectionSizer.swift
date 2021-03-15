//
//  CollectionSizer.swift
//  Mintee
//
//  Provides functions for views to use so that collections are sized consistently across SwiftUI and non-SwiftUI components.
//
//  Created by Vincent Young on 11/14/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftUI

class CollectionSizer {
    
    // MARK: - Properties with set app-wide constant values
    
    static let gridVerticalPadding: CGFloat = 20
    static let cornerRadius: CGFloat = 5
    static let borderThickness: CGFloat = 3
    
    // MARK: - Properties used for sizing comparison
    
    static let idealSideInset: CGFloat = 20
    static let minSideInset: CGFloat = 10
    static let maxSideInset: CGFloat = 40
    
    static let idealInterItemSpacing: CGFloat = 10
    
    // MARK: - UICollectionView sizing
    
    /**
     Returns a UICollectionViewFlowLayout to use for a UICollectionView.
     The return UICollectionViewFlowLayout sets the following properties:
     - itemSize: The ideal item size calculated from the parameters idealItemWidth and heightMultiplier.
     If the width available cannot fit the ideal item's width with left/right insets set to the minimum, the item size is shrunk as needed.
     If the width available can fit only one item but has too much remaining width after setting left/right insets to maximum, the item size is increased as needed.
     - parameter widthAvailable: The total width of the UICollectionView's frame
     - parameter idealItemWidth: The ideal width of each UICollectionView item
     - parameter heightMultiplier: The height-to-width ratio of each UICollectionView item
     - returns: UICollectionViewFlowLayout that fits as many 
     */
    static func getCollectionViewFlowLayout(widthAvailable: CGFloat,
                                            idealItemWidth: CGFloat,
                                            heightMultiplier: CGFloat) -> (layout: UICollectionViewFlowLayout, itemsPerRow: Int) {
        
        let flowLayout = UICollectionViewFlowLayout()
        let idealItemHeight = idealItemWidth * heightMultiplier
        var itemCount: Int = 0
        
        if idealItemWidth + (2 * idealSideInset) > widthAvailable {
            
            // An ideal size item can't be fit into the availble width.
            if idealItemWidth + (2 * minSideInset) > widthAvailable {
                // An ideal size item with minimum side insets still cannot fit, so left/right insets are set to minimum, the itemSize is shrunk, and a bug is reported.
                let trueItemWidth = widthAvailable - (2 * minSideInset)
                flowLayout.itemSize = CGSize(width: trueItemWidth, height: trueItemWidth * heightMultiplier)
                flowLayout.sectionInset = UIEdgeInsets(top: 20, left: minSideInset, bottom: 20, right: minSideInset)
            } else {
                // An ideal size item can fit with smaller left/right insets, so insets are adjusted accordingly.
                let trueSideInset = (widthAvailable - idealItemWidth) / 2
                flowLayout.sectionInset = UIEdgeInsets(top: 20, left: trueSideInset, bottom: 20, right: trueSideInset)
                flowLayout.itemSize = CGSize(width: idealItemWidth, height: idealItemHeight)
            }
            itemCount = 1
            
        } else if (2 * idealItemWidth) + (2 * idealSideInset) + idealInterItemSpacing > widthAvailable {
            
            // Only one ideal size item can be fit.
            if idealItemWidth + (maxSideInset * 2) < widthAvailable {
                // Setting the side insets to the max value is still not enough to fill the space, so the itemSize is increased.
                let trueItemWidth = widthAvailable - (2 * maxSideInset)
                flowLayout.itemSize = CGSize(width: trueItemWidth, height: trueItemWidth * heightMultiplier)
                flowLayout.sectionInset = UIEdgeInsets(top: 20, left: maxSideInset, bottom: 20, right: maxSideInset)
            } else {
                // The ideal size item can be fit without maxing out left/right insets, so the insets are set accordingly.
                let trueSideInset = (widthAvailable - idealItemWidth) / 2
                flowLayout.sectionInset = UIEdgeInsets(top: 20, left: trueSideInset, bottom: 20, right: trueSideInset)
                flowLayout.itemSize = CGSize(width: idealItemWidth, height: idealItemHeight)
            }
            itemCount = 1
            
        } else {
            
            /*
             More than one ideal size item can be fit.
             After finding the max number of items that can be fit per row with ideal insets and interitem spacing, the remaining width available is distributed equally to insets and spacing, ensuring that left/right insets are still greater than interitem spacing by 10 pixels.
             */
            let idealWidthAvailable = (widthAvailable - idealItemWidth - (2 * idealSideInset))
            itemCount = Int( floor(idealWidthAvailable / (idealItemWidth + idealInterItemSpacing)) + 1 )
            
            let insetAndSpacingAvailable = widthAvailable - (CGFloat(itemCount) * idealItemWidth)
            let trueSpacing = (insetAndSpacingAvailable - 20)/(CGFloat(itemCount) + 1)
            let trueSideInset = trueSpacing + 10
            
            flowLayout.itemSize = CGSize(width: idealItemWidth, height: idealItemHeight)
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: trueSideInset, bottom: 20, right: trueSideInset)
            flowLayout.minimumInteritemSpacing = trueSpacing
            
        }
        
        flowLayout.minimumLineSpacing = 20
        return (layout: flowLayout, itemsPerRow: itemCount)
        
    }
    
    // MARK: - LazyVGrid (SwiftUI) sizing
    
    /**
     Converts the return value from CollectionSizer.getCollectionViewFlowLayout to a tuple of values for SwiftUI LazyVGrids to use
     - parameter totalWidth: Total width of View that can be used for sizing items, spacing, and left/right insets.
     - parameter idealItemWidth: The ideal width of each item in the mock collection
     - returns: Tuple containing array of GridItem with fixed item widths and spacing, itemWidth, and horizontal insets for the mock collection view
     */
    static func getVGridLayout(widthAvailable: CGFloat, idealItemWidth: CGFloat) -> ( grid: [GridItem], itemWidth: CGFloat, leftRightInset: CGFloat) {
        
        let layoutTuple = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: widthAvailable,
                                                                      idealItemWidth: idealItemWidth,
                                                                      heightMultiplier: 0)
        
        var gridItems: [GridItem] = []
        for _ in 0 ..< layoutTuple.itemsPerRow {
            gridItems.append(GridItem(.fixed(layoutTuple.layout.itemSize.width), spacing: layoutTuple.layout.minimumInteritemSpacing))
        }
        return (gridItems, layoutTuple.layout.itemSize.width, layoutTuple.layout.sectionInset.left)
        
    }
    
}
