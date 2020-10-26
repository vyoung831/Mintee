//
//  SettingsView-Tests.swift
//  MuTests
//
//  Created by Vincent Young on 10/7/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import XCTest

class SettingsView_Tests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func test_getExactItemWidth() throws {
        let sv = SettingsView()
        let expectedItemWidth = (500 - (19 * sv.itemSpacing)) / 20
        XCTAssertEqual(sv.getExactItemWidth(widthAvailable: 500, count: 20), expectedItemWidth)
    }

}
