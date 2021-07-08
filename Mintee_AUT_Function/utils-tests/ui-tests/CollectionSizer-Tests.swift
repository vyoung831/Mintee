//
//  CollectionSizer-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 11/14/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils
@testable import Mintee

class CollectionSizer_Tests: XCTestCase {
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.teardownTestContainer()
    }
    
}

// MARK: - getCollectionViewFlowLayout tests

extension CollectionSizer_Tests {
    
    func test_getCollectionViewFlowLayout_idealItemSize_oneItem_itemShrinks() throws {
        
        let flowLayout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                                     idealItemWidth: 200,
                                                                     heightMultiplier: 1.5)
        
        XCTAssertEqual(flowLayout.layout.itemSize.width, 180)
        XCTAssertEqual(flowLayout.layout.itemSize.height, 270)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_oneItem_insetsExpandToFill() throws {
        
        let flowLayout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                                     idealItemWidth: 175,
                                                                     heightMultiplier: 1.5)
        
        XCTAssertEqual(flowLayout.layout.itemSize.width, 175)
        XCTAssertEqual(flowLayout.layout.itemSize.height, 262.5)
        XCTAssertEqual(flowLayout.layout.sectionInset.left, 12.5)
        XCTAssertEqual(flowLayout.layout.sectionInset.right, 12.5)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_oneItem_insetsMaxed_itemWidthExpands() throws {
        
        let flowLayout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                                     idealItemWidth: 110,
                                                                     heightMultiplier: 1.5)
        
        XCTAssertEqual(flowLayout.layout.itemSize.width, 120)
        XCTAssertEqual(flowLayout.layout.itemSize.height, 180)
        XCTAssertEqual(flowLayout.layout.sectionInset.left, 40)
        XCTAssertEqual(flowLayout.layout.sectionInset.right, 40)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_twoIems_idealInsets_idealSpacing() throws {
        
        let flowLayout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                                     idealItemWidth: 75,
                                                                     heightMultiplier: 1.5)
        
        XCTAssertEqual(flowLayout.layout.itemSize.width, 75)
        XCTAssertEqual(flowLayout.layout.itemSize.height, 112.5)
        XCTAssertEqual(flowLayout.layout.sectionInset.left, 20)
        XCTAssertEqual(flowLayout.layout.sectionInset.right, 20)
        XCTAssertEqual(flowLayout.layout.minimumInteritemSpacing, 10)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_twoItems_adjustedInsets_adjustedSpacing1() throws {
        
        let flowLayout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                                     idealItemWidth: 50,
                                                                     heightMultiplier: 1.5)
        
        XCTAssertEqual(flowLayout.layout.itemSize.width, 50)
        XCTAssertEqual(flowLayout.layout.itemSize.height, 75)
        XCTAssertEqual(flowLayout.layout.sectionInset.left, 110/3, accuracy: 0.00001)
        XCTAssertEqual(flowLayout.layout.sectionInset.right, 110/3, accuracy: 0.00001)
        XCTAssertEqual(flowLayout.layout.minimumInteritemSpacing, 80/3, accuracy: 0.00001)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_twoItems_adjustedInsets_adjustedSpacing2() throws {
        
        let flowLayout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                                     idealItemWidth: 141/3,
                                                                     heightMultiplier: 1.5)
        
        XCTAssertEqual(flowLayout.layout.itemSize.width, 141/3, accuracy: 0.00001)
        XCTAssertEqual(flowLayout.layout.itemSize.height, 70.5)
        XCTAssertEqual(flowLayout.layout.sectionInset.left, 116/3, accuracy: 0.00001)
        XCTAssertEqual(flowLayout.layout.sectionInset.right, 116/3, accuracy: 0.00001)
        XCTAssertEqual(flowLayout.layout.minimumInteritemSpacing, 86/3, accuracy: 0.00001)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_threeIems_idealInsets_idealSpacing() throws {
        
        let flowLayout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                                     idealItemWidth: 140/3,
                                                                     heightMultiplier: 1.5)
        
        XCTAssertEqual(flowLayout.layout.itemSize.width, 140/3, accuracy: 0.00001)
        XCTAssertEqual(flowLayout.layout.itemSize.height, 70)
        XCTAssertEqual(flowLayout.layout.sectionInset.left, 20)
        XCTAssertEqual(flowLayout.layout.sectionInset.right, 20)
        XCTAssertEqual(flowLayout.layout.minimumInteritemSpacing, 10)
        
    }
    
}

// MARK: - getVGridLayout tests

extension CollectionSizer_Tests {
    
    func test_getVGridLayout_idealItemSize_oneItem_itemShrinks() throws {
        
        let gridLayout = CollectionSizer.getVGridLayout(widthAvailable: 200,
                                                        idealItemWidth: 200)
        
        XCTAssertEqual(gridLayout.grid.count, 1)
        XCTAssertEqual(gridLayout.itemWidth, 180)
        XCTAssertEqual(gridLayout.leftRightInset, 10)
        
    }
    
    func test_getVGridLayout_idealItemSize_oneItem_insetsExpandToFill() throws {
        
        let gridLayout = CollectionSizer.getVGridLayout(widthAvailable: 200,
                                                        idealItemWidth: 175)
        
        XCTAssertEqual(gridLayout.grid.count, 1)
        XCTAssertEqual(gridLayout.itemWidth, 175)
        XCTAssertEqual(gridLayout.leftRightInset, 12.5)
        
    }
    
    func test_getVGridLayout_idealItemSize_oneItem_insetsMaxed_itemWidthExpands() throws {
        
        let gridLayout = CollectionSizer.getVGridLayout(widthAvailable: 200,
                                                        idealItemWidth: 110)
        XCTAssertEqual(gridLayout.grid.count, 1)
        XCTAssertEqual(gridLayout.itemWidth, 120)
        XCTAssertEqual(gridLayout.leftRightInset, 40)
        
    }
    
    func test_getVGridLayout_idealItemSize_twoIems_idealInsets_idealSpacing() throws {
        
        let gridLayout = CollectionSizer.getVGridLayout(widthAvailable: 200,
                                                        idealItemWidth: 75)
        
        XCTAssertEqual(gridLayout.grid.count, 2)
        XCTAssertEqual(gridLayout.grid[0].spacing, 10)
        XCTAssertEqual(gridLayout.itemWidth, 75)
        XCTAssertEqual(gridLayout.leftRightInset, 20)
        
    }
    
    func test_getVGridLayout_idealItemSize_twoItems_adjustedInsets_adjustedSpacing1() throws {
        
        let gridLayout = CollectionSizer.getVGridLayout(widthAvailable: 200,
                                                        idealItemWidth: 50)
        
        XCTAssertEqual(gridLayout.grid.count, 2)
        XCTAssertEqual(Double(gridLayout.grid[0].spacing!), 80/3, accuracy: 0.00001)
        XCTAssertEqual(gridLayout.itemWidth, 50)
        XCTAssertEqual(gridLayout.leftRightInset, 110/3, accuracy: 0.00001)
        
    }
    
    func test_getVGridLayout_idealItemSize_twoItems_adjustedInsets_adjustedSpacing2() throws {
        
        let gridLayout = CollectionSizer.getVGridLayout(widthAvailable: 200,
                                                        idealItemWidth: 141/3)
        
        XCTAssertEqual(gridLayout.grid.count, 2)
        XCTAssertEqual(Double(gridLayout.grid[0].spacing!), 86/3, accuracy: 0.00001)
        XCTAssertEqual(gridLayout.itemWidth, 141/3, accuracy: 0.00001)
        XCTAssertEqual(gridLayout.leftRightInset, 116/3, accuracy: 0.00001)
        
    }
    
    func test_getVGridLayout_idealItemSize_threeIems_idealInsets_idealSpacing() throws {
        
        let gridLayout = CollectionSizer.getVGridLayout(widthAvailable: 200,
                                                        idealItemWidth: 140/3)
        
        XCTAssertEqual(gridLayout.grid.count, 3)
        XCTAssertEqual(gridLayout.grid[0].spacing!, 10)
        XCTAssertEqual(gridLayout.itemWidth, 140/3, accuracy: 0.00001)
        XCTAssertEqual(gridLayout.leftRightInset, 20)
        
    }
    
}
