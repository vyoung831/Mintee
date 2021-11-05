//
//  TagValidator.swift
//  Mintee_AUT_Function
//
//  Business rules NOT checked for by this validator:
//  * TAG-1 (validated by MOC_Validator)
//
//  Created by Vincent Young on 7/4/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import XCTest
@testable import Mintee

class TagValidator {
    
    static var validators: [(Tag) throws -> ()] = [
        TagValidator.validateTagAssociation
    ]
    
    static func validateTags(_ tags: Set<Tag>) {
        for tag in tags {
            for validator in TagValidator.validators {
                try! validator(tag)
            }
        }
    }
    
    /**
     TAG-2
     */
    static var validateTagAssociation: (Tag) throws -> () = { tag in
        XCTAssert((try tag._tasks).count >= 1)
    }
    
}
