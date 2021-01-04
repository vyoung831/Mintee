//
//  Task-TagHandling-Tests-Util.swift
//  SharedTestUtils
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

@testable import Mu
import Foundation

class Task_TagHandling_Tests_Util {
    
    static func setUp() {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    static func tearDown() {
        CDCoordinator.moc.rollback()
    }
    
}
