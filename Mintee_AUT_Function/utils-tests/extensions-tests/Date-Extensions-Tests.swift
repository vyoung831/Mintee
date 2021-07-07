//
//  Date-Extension-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 6/20/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
@testable import SharedTestUtils
@testable import Mintee

class Date_Extension_Tests: XCTestCase {

    override func setUpWithError() throws {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.rollbackTestContainer()
    }

    /**
     Test with GMT June 16, 2001 10:29:11 AM
     */
    func test_toMDYPresent() {
        let date = Date(timeIntervalSince1970: 992687351)
        let day = String(format: "%02d", Calendar.current.component(.day, from: date))
        XCTAssert(Date.toMDYPresent(date) == "Jun \(day), 2001" )
    }
    
    /**
     Test with GMT June 16, 2001 10:29:11 AM
     */
    func test_toMDYShort() {
        let date = Date(timeIntervalSince1970: 992687351)
        let day = String(Calendar.current.component(.day, from: date))
        XCTAssert(Date.toMDYShort(date) == "6-\(day)-2001" )
    }

    /**
     Test lessThanEqualToDate and lessThanDate using Dates with
     - Different days
     - Same month
     - Same year
     */
    func test_lessThanFunctions_sameMonth_sameYear() {
        
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
    
    }
    
    /**
     Test lessThanEqualToDate and lessThanDate using Dates of
     - Different days
     - Different months
     - Same year
     */
    func test_lessThanFunctions_differentMonth_sameYear() {
        
        var startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 4, day: 15))!
        var endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
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
        
    }
    
    /**
     Test lessThanEqualToDate and lessThanDate using Dates with
     - Different days
     - Different months
     - Start year later than end year
     */
    func test_lessThanFunctions_startYearLaterThanEndYear() {
        
        var startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2011, month: 4, day: 15))!
        var endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
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
           
    }
    
    /**
     Test lessThanEqualToDate and lessThanDate using Dates with
     - Different days
     - Different months
     - Start year earlier than end year
     */
    func test_lessThanFunctions_startYearEarlierThanEndYear() {
        
        var startDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2009, month: 4, day: 15))!
        var endDate = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, timeZone: .current, year: 2010, month: 5, day: 15))!
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
    
    // MARK: - daysToDate tests
    
    func test_daysToDate_oneDay_exact() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 15, hour: 0, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 16, hour: 0, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == 1)
    }
    
    func test_daysToDate_oneDay_lessThan24Hours() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 15, hour: 23, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 16, hour: 1, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == 1)
    }
    
    func test_daysToDate_oneDay_greaterThan24Hours() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 15, hour: 12, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 16, hour: 13, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == 1)
    }
    
    func test_daysToDate_twoDays_lessThan48Hours() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 15, hour: 23, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 17, hour: 1, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == 2)
    }
    
    func test_daysToDate_oneDayBack_exact() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 16, hour: 0, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 15, hour: 0, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == -1)
    }
    
    func test_daysToDate_oneDayBack_lessThan24Hours() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 16, hour: 1, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 15, hour: 23, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == -1)
    }
    
    func test_daysToDate_oneDayBack_greaterThan24Hours() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 16, hour: 13, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 15, hour: 12, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == -1)
    }
    
    func test_daysToDate_twoDaysBack_lessThan48Hours() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 16, hour: 1, minute: 0, second: 0))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 14, hour: 23, minute: 0, second: 0))!
        XCTAssert(startDate.daysToDate(endDate) == -2)
    }
    
}
