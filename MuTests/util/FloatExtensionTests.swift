//
//  FloatExtensionTests.swift
//  MuTests
//
//  Created by Vincent Young on 9/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mu
import XCTest

class FloatExtensionTests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testClean_TrimToWholeNumber() throws {
        let someFloat = Float(3.0)
        XCTAssert(someFloat.clean == "3")
    }
    
    func testClean_TrimInsignificantZeroes() throws {
        let someFloat = Float(3.50)
        XCTAssert(someFloat.clean == "3.5")
    }
    
    func testClean_KeepSignificantZeroes() throws {
        let someFloat = Float(30.0)
        XCTAssert(someFloat.clean == "30")
    }

}
