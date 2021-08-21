//
//  TagPopupUtils.swift
//  Mintee
//
//  Utility functions used by `AddTagPopup` and `SearchTagPopup`.
//
//  Created by Vincent Young on 5/8/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation

class TagPopupUtils {
    
    /**
     Compares a Tag's name to the content in a TextField to determine if the Tag matches the content and should be displayed to the user to be selected.
     - parameter tag: Tag to evaluate
     - parameter textFieldContent: Content of TextField to evaluate against Tag.
     - returns: True if tagText is a case-insensitive substring of tag's name
     */
    static func tagShouldBeDisplayed(_ tag: Tag,_ textFieldContent: String) -> Bool {
        return (tag._name.lowercased().contains(textFieldContent.lowercased()) || textFieldContent.count == 0)
    }
    
}
