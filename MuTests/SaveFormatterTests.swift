//
//  SaveFormatterTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/16/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class SaveFormatterTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /**
     Test the storedStringToDate function
     */
    func testStoredStringToDate() {
        let dateString = "2020-06-07"
        let date = SaveFormatter.storedStringToDate(dateString)
        XCTAssert( Calendar.current.component(.year, from: date) == 2020)
        XCTAssert( Calendar.current.component(.month, from: date) == 6)
        XCTAssert( Calendar.current.component(.day, from: date) == 7)
    }
    
    /**
     Test the dateToStoredString function
     */
    func testDateToStoredString() {
        let date = Date(timeIntervalSince1970: 920000)
        let year = Calendar.current.component(.year, from: date)
        
        // Append leading zeros up to length 2
        let month = String(format: "%02d", Calendar.current.component(.month, from: date))
        let day = String(format: "%02d", Calendar.current.component(.day, from: date))
        
        let dateString = "\(year)-\(month)-\(day)"
        XCTAssert( SaveFormatter.dateToStoredString(date) == dateString)
    }
    
}
