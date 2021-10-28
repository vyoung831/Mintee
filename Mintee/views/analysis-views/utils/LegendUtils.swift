//
//  LegendUtils.swift
//  Mintee
//
//  Created by Vincent Young on 4/24/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import SwiftUI

class CategorizedLegendEntryPreview: ObservableObject {
    
    @Published var color: Color
    @Published var category: CategorizedLegendEntry.Category
    
    init(color: Color, category: CategorizedLegendEntry.Category) {
        self.color = color
        self.category = category
    }
    
    /**
     - returns: String representing the label on a ColorPicker associated with this object.
     */
    func getLabel() -> String {
        switch category {
        case .overTarget: return "Over target"
        case .underTarget: return "Under target"
        case .reachedTarget: return "Reached target"
        }
    }
    
    /**
     - returns: Array of `CategorizedLegendEntryPreview` with default colors and orderings (to be displayed on a form).
     */
    static func getDefaults() -> [CategorizedLegendEntryPreview] {
        return [CategorizedLegendEntryPreview(color: .green, category: .reachedTarget),
                CategorizedLegendEntryPreview(color: .red, category: .overTarget),
                CategorizedLegendEntryPreview(color: .red, category: .underTarget)]
    }
    
    /**
     Returns the provided array of CategorizedLegendEntryPreviews, sorted by `category` in the order in which they would be presented by `CategorizedLegendEntryPreview.getDefaults()`.
     Used to sort previews when being read from persistent store and displayed on a form, ensuring that the user has a consistent experience across forms.
     - parameter previews: Array of CategorizedLegendEntryPreview to sort
     - returns: Contents of CategorizedLegendEntryPreview, sorted by `category` in the same order as the array returned by `CategorizedLegendEntryPreview.getDefaults()`
     */
    static func sortedPreviews(_ previews: [CategorizedLegendEntryPreview]) -> [CategorizedLegendEntryPreview] {
        return previews.sorted(by: {
            switch $0.category {
            case .reachedTarget:
                return true
            case .overTarget:
                return $1.category == .reachedTarget ? false : true
            case .underTarget:
                return false
            }
        })
    }
    
}

class CompletionLegendEntryPreview: ObservableObject {
    
    @Published var color: Color
    @Published var min: Float
    @Published var max: Float
    @Published var minOperator: SaveFormatter.equalityOperator
    @Published var maxOperator: SaveFormatter.equalityOperator
    
    init(color: Color, min: Float, max: Float, minOperator: SaveFormatter.equalityOperator, maxOperator: SaveFormatter.equalityOperator) {
        self.color = color
        self.min = min
        self.max = max
        self.minOperator = minOperator
        self.maxOperator = maxOperator
    }
    
}
