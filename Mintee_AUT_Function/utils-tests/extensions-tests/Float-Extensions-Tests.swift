//
//  Float-Extension-Tests.swift
//  MinteeTests
//
//  Created by Vincent Young on 9/6/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
import SharedTestUtils
import XCTest
import SharedTestUtils

class Float_Extension_Tests: XCTestCase {

    override class func setUp() {
        TestContainer.setUpTestContainer()
    }
    
    override func tearDownWithError() throws {
        TestContainer.tearDownTestContainer()
    }

    func test_clean_TrimToWholeNumber() throws {
        let someFloat = Float(3.0)
        XCTAssert(someFloat.clean == "3")
    }
    
    func test_clean_TrimInsignificantZeroes() throws {
        let someFloat = Float(3.50)
        XCTAssert(someFloat.clean == "3.5")
    }
    
    func test_clean_KeepSignificantZeroes() throws {
        let someFloat = Float(30.0)
        XCTAssert(someFloat.clean == "30")
    }

}
