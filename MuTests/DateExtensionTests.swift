//
//  DateExtensionTests.swift
//  MuTests
//
//  Created by Vincent Young on 6/20/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mu

class DateExtensionTests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    /**
     Test with GMT June 16, 2001 10:29:11 AM
     */
    func testToMDYPresent() {
        let date = Date(timeIntervalSince1970: 992687351)
        let day = String(format: "%02d", Calendar.current.component(.day, from: date))
        XCTAssert(Date.toMDYPresent(date) == "Jun \(day), 2001" )
    }
    
    /**
     Test with GMT June 16, 2001 10:29:11 AM
     */
    func testToMDYShort() {
        let date = Date(timeIntervalSince1970: 992687351)
        let day = String(Calendar.current.component(.day, from: date))
        XCTAssert(Date.toMDYShort(date) == "6-\(day)-2001" )
    }

    /**
     Test lessThanEqualToDate and lessThanDate.
     This test covers cases where the start Date's day, month, and/or year are (less than, equal to, or greater than) those of the end Date
     */
    func testLessThanFunctions() {
        
        // Test same month and year, with different days
        var startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        var endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        
        // Test same year, with different month and day comparisons (Same month already tested)
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 4, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 4, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 4, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 6, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 6, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 6, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        
        /*
         Test different day, month, and year relationships (Same year already tested)
         */
        // Start year > end year
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 4, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 4, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 4, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 5, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 5, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 5, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 6, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 6, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 6, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(!startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(!startDate.lessThanDate(endDate))
        
        // Start year < end year
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 4, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 4, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 4, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 5, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 5, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 5, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 6, day: 15))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 6, day: 14))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 6, day: 16))!
        endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
        XCTAssert(startDate.lessThanOrEqualToDate(endDate))
        XCTAssert(startDate.lessThanDate(endDate))
        
    }
    
}
