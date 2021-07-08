//
//  SaveFormatter-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 6/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import SharedTestUtils
@testable import Mintee

class SaveFormatter_Tests: XCTestCase {
    
    override class func setUp() {
        TestContainer.setUpTestContainer()
    }

    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
    }
    
    /**
     Test the storedStringToDate function
     */
    func test_storedStringToDate() {
        let dateString = "2020-06-07"
        let date = SaveFormatter.storedStringToDate(dateString)!
        XCTAssert( Calendar.current.component(.year, from: date) == 2020)
        XCTAssert( Calendar.current.component(.month, from: date) == 6)
        XCTAssert( Calendar.current.component(.day, from: date) == 7)
    }
    
    /**
     Test the dateToStoredString function
     */
    func test_dateToStoredString() {
        let date = Date(timeIntervalSince1970: 920000)
        let year = Calendar.current.component(.year, from: date)
        
        // Append leading zeros up to length 2
        let month = String(format: "%02d", Calendar.current.component(.month, from: date))
        let day = String(format: "%02d", Calendar.current.component(.day, from: date))
        
        let dateString = "\(year)-\(month)-\(day)"
        XCTAssert( SaveFormatter.dateToStoredString(date) == dateString)
    }
    
}
