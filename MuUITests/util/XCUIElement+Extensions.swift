//
//  XCUIElement+Extensions.swift
//  MuUITests
//
//  Created by Vincent Young on 7/4/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    
    /**
     Returns the set of descendant XCUIElements whose accessibilityIdentifier match the one provided by the caller. accessibiltyLabel is not compared
     */
    func descendantsSet(matching type: XCUIElement.ElementType, identifier: String) -> Set<XCUIElement> {
        var matchingDescendants = Set<XCUIElement>()
        let descendants = self.descendants(matching: type).allElementsBoundByIndex
        for descendant in descendants {
            if descendant.identifier == identifier {
                matchingDescendants.insert(descendant)
            }
        }
        return matchingDescendants
    }
    
    /**
     Returns the set of descendant XCUIElements whose accessibilityIdentifier match the one provided by the caller. accessibiltyLabel is not compared
     */
    func childrenSet(matching type: XCUIElement.ElementType, identifier: String) -> Set<XCUIElement> {
        var matchingChildren = Set<XCUIElement>()
        let children = self.children(matching: type).allElementsBoundByIndex
        for child in children {
            if child.identifier == identifier {
                matchingChildren.insert(child)
            }
        }
        return matchingChildren
    }
    
}
