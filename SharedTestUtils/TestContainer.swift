//
//  TestContainer.swift
//  SharedTestUtils
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
import Foundation
import CoreData

public class TestContainer {
    
    public static func setUpTestContainer() {}
    
    public static func tearDownTestContainer() {
        MOC_Validator.validate()
        CDCoordinator.mainContext.rollback()
    }
    
}
