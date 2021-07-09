//
//  SetDatePopupUITests.swift
//  MinteeUITests
//
//  Created by Vincent Young on 7/12/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import XCTest
import SharedTestUtils
@testable import Mintee

class SetDatePopupUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS" : "YES"]
        app.launch()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Today"].tap()
        app.navigationBars["Today"].buttons["add-task-button"].tap()
    }
    
    /**
     Navigate to AddTask and to SetDatePopup.
     Set the start date and confirm that the start date label was updated on AddTask
     */
    func testSetStartDate() throws {
        let app = XCUIApplication()
        app.buttons["start-date"].tap()
        
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "December")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "1")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2050")
        app.buttons["set-date-popup-done-button"].tap()
        
        XCTAssert(app.buttons["start-date"].label == "Start Date: Dec 1, 2050")
    }
    
    /**
     Navigate to AddTask and to SetDatePopup.
     Set the start date to later than current end date, and confirm that both dates were updated on AddTask
     */
    func testSetStartDateLaterThanEndDate() throws {
        let app = XCUIApplication()
        
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        let endDateLabel = app.buttons["end-date"].label
        let endDateString = String(endDateLabel[endDateLabel.index(endDateLabel.startIndex, offsetBy: "End Date: ".count)...])
        let endDateComponents = Calendar.current.dateComponents([.day,.month,.year],
                                                                from: df.date(from: endDateString)!)
        let endYear = endDateComponents.year
        
        app.buttons["start-date"].tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "December")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "1")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: String(endYear! + 1))
        app.buttons["set-date-popup-done-button"].tap()
        
        XCTAssert(app.buttons["start-date"].label == "Start Date: Dec 1, \(endYear! + 1)")
        XCTAssert(app.buttons["end-date"].label == "End Date: Dec 1, \(endYear! + 1)")
    }
    
    /**
     Navigate to AddTask and to SetDatePopup.
     Set the end date to earlier than current start date, and confirm that both dates were updated on AddTask
     */
    func testSetEndDateEarlierThanStartDate() throws {
        let app = XCUIApplication()
        
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        let startDateLabel = app.buttons["start-date"].label
        let startDateString = String(startDateLabel[startDateLabel.index(startDateLabel.startIndex, offsetBy: "Start Date: ".count)...])
        let startDateComponents = Calendar.current.dateComponents([.day,.month,.year],
                                                                  from: df.date(from: startDateString)!)
        let startYear = startDateComponents.year
        
        app.buttons["end-date"].tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "December")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "1")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: String(startYear! - 1))
        app.buttons["set-date-popup-done-button"].tap()
        
        XCTAssert(app.buttons["start-date"].label == "Start Date: Dec 1, \(startYear! - 1)")
        XCTAssert(app.buttons["end-date"].label == "End Date: Dec 1, \(startYear! - 1)")
        
    }
    
    /**
     Navigate to AddTask and to SetDatePopup.
     Attempt to update the start date's day and month (in order), and verify that the update was successful
     Test written because bug was found where dates were not being updated after only month and day were changed in SetDatePopup
     */
    func testUpdateStartDateDayAndMonth() throws {
        let app = XCUIApplication()
        
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        let startDateLabel = app.buttons["start-date"].label
        let startDateString = String(startDateLabel[startDateLabel.index(startDateLabel.startIndex, offsetBy: "Start Date: ".count)...])
        let startDateComponents = Calendar.current.dateComponents([.day,.month,.year],
                                                                  from: df.date(from: startDateString)!)
        let startDay = startDateComponents.day!
        let startMonth = startDateComponents.month!
        let startYear = startDateComponents.year!
        let finalStartDay = String(startDay > 15 ? startDay - 10 : startDay + 10)
        let finalStartMonth = startMonth > 6 ? startMonth - 3 : startMonth + 3
        
        app.buttons["start-date"].tap()
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: finalStartDay)
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: DateFormatter().monthSymbols[finalStartMonth - 1])
        app.buttons["set-date-popup-done-button"].tap()
        
        XCTAssert(app.buttons["start-date"].label == "Start Date: \(DateFormatter().shortMonthSymbols[finalStartMonth - 1]) \(finalStartDay), \(startYear)")
        
    }
    
    /**
     Navigate to AddTask and to SetDatePopup.
     Attempt to update the start date's month and day (in order), and verify that the update was successful
     Test written because bug was found where dates were not being updated after only month and day were changed in SetDatePopup
     */
    func testUpdateStartDateMonthAndDay() throws {
        let app = XCUIApplication()
        
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        let startDateLabel = app.buttons["start-date"].label
        let startDateString = String(startDateLabel[startDateLabel.index(startDateLabel.startIndex, offsetBy: "Start Date: ".count)...])
        let startDateComponents = Calendar.current.dateComponents([.day,.month,.year],
                                                                  from: df.date(from: startDateString)!)
        let startDay = startDateComponents.day!
        let startMonth = startDateComponents.month!
        let startYear = startDateComponents.year!
        let finalStartDay = String(startDay > 15 ? startDay - 10 : startDay + 10)
        let finalStartMonth = startMonth > 6 ? startMonth - 3 : startMonth + 3
        
        app.buttons["start-date"].tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: DateFormatter().monthSymbols[finalStartMonth - 1])
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: finalStartDay)
        app.buttons["set-date-popup-done-button"].tap()
        
        XCTAssert(app.buttons["start-date"].label == "Start Date: \(DateFormatter().shortMonthSymbols[finalStartMonth - 1]) \(finalStartDay), \(startYear)")
        
    }
    
}
