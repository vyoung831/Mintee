//
//  CollectionSizer-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 11/14/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class CollectionSizer_Tests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_getCollectionViewFlowLayout_idealItemSize_oneItem_itemShrinks() throws {
        
        let layout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                    idealItemWidth: 200,
                                                    heightMultiplier: 1.5)
        
        XCTAssertEqual(layout.itemSize.width, 180)
        XCTAssertEqual(layout.itemSize.height, 270)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_oneItem_insetsExpandToFill() throws {
        
        let layout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                    idealItemWidth: 175,
                                                    heightMultiplier: 1.5)
        
        XCTAssertEqual(layout.itemSize.width, 175)
        XCTAssertEqual(layout.itemSize.height, 262.5)
        XCTAssertEqual(layout.sectionInset.left, 12.5)
        XCTAssertEqual(layout.sectionInset.right, 12.5)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_oneItem_insetsMaxed_itemWidthExpands() throws {
        
        let layout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                    idealItemWidth: 110,
                                                    heightMultiplier: 1.5)
        
        XCTAssertEqual(layout.itemSize.width, 120)
        XCTAssertEqual(layout.itemSize.height, 180)
        XCTAssertEqual(layout.sectionInset.left, 40)
        XCTAssertEqual(layout.sectionInset.right, 40)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_twoIems_idealInsets_idealSpacing() throws {
        
        let layout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                    idealItemWidth: 75,
                                                    heightMultiplier: 1.5)
        
        XCTAssertEqual(layout.itemSize.width, 75)
        XCTAssertEqual(layout.itemSize.height, 112.5)
        XCTAssertEqual(layout.sectionInset.left, 20)
        XCTAssertEqual(layout.sectionInset.right, 20)
        XCTAssertEqual(layout.minimumInteritemSpacing, 10)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_twoItems_adjustedInsets_adjustedSpacing1() throws {
        
        let layout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                    idealItemWidth: 50,
                                                    heightMultiplier: 1.5)
        
        XCTAssertEqual(layout.itemSize.width, 50)
        XCTAssertEqual(layout.itemSize.height, 75)
        XCTAssertEqual(layout.sectionInset.left, 110/3, accuracy: 0.00001)
        XCTAssertEqual(layout.sectionInset.right, 110/3, accuracy: 0.00001)
        XCTAssertEqual(layout.minimumInteritemSpacing, 80/3, accuracy: 0.00001)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_twoItems_adjustedInsets_adjustedSpacing2() throws {
        
        let layout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                    idealItemWidth: 141/3,
                                                    heightMultiplier: 1.5)
        
        XCTAssertEqual(layout.itemSize.width, 141/3, accuracy: 0.00001)
        XCTAssertEqual(layout.itemSize.height, 70.5)
        XCTAssertEqual(layout.sectionInset.left, 116/3, accuracy: 0.00001)
        XCTAssertEqual(layout.sectionInset.right, 116/3, accuracy: 0.00001)
        XCTAssertEqual(layout.minimumInteritemSpacing, 86/3, accuracy: 0.00001)
        
    }
    
    func test_getCollectionViewFlowLayout_idealItemSize_threeIems_idealInsets_idealSpacing() throws {
        
        let layout = CollectionSizer.getCollectionViewFlowLayout(widthAvailable: 200,
                                                    idealItemWidth: 140/3,
                                                    heightMultiplier: 1.5)
        
        XCTAssertEqual(layout.itemSize.width, 140/3, accuracy: 0.00001)
        XCTAssertEqual(layout.itemSize.height, 70)
        XCTAssertEqual(layout.sectionInset.left, 20)
        XCTAssertEqual(layout.sectionInset.right, 20)
        XCTAssertEqual(layout.minimumInteritemSpacing, 10)
        
    }

}
