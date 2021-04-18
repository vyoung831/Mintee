//
//  AnalysisList-Tests.swift
//  Mintee_AUT_Function
//
//  Created by Vincent Young on 4/18/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import XCTest
@testable import Mintee

class AnalysisList_Tests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

}

// MARK: - Test for AnalysisListModel

extension AnalysisList_Tests {
    
    func test_analysisListModel_sortPreviews() throws {
        
        var previews = [AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 0),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 2),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -3),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 4),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 0),]
        AnalysisListModel.sortPreviews(&previews)
        let mappedOrders = previews.map{ $0.order }
        XCTAssert(mappedOrders == [0,0,2,4,-1,-1,-3])
        
    }
    
    func test_analysisListModel_togglePreview_toggleFirstIncludedPreview() {
        
        var previews = [AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 0),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 2),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1)]
        AnalysisListModel.togglePreview(preview: previews[0], previews: &previews)
        let mappedOrders = previews.map{ $0.order }
        XCTAssert(mappedOrders == [1,2,-1,-1])
        
    }
    
    func test_analysisListModel_togglePreview_toggleMiddleIncludedPreview() {
        
        var previews = [AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 0),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 2),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1)]
        AnalysisListModel.togglePreview(preview: previews[1], previews: &previews)
        let mappedOrders = previews.map{ $0.order }
        XCTAssert(mappedOrders == [0,2,-1,-1])
        
    }
    
    func test_analysisListModel_togglePreview_toggleLastIncludedPreview() {
        
        var previews = [AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 0),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 2),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1)]
        AnalysisListModel.togglePreview(preview: previews[2], previews: &previews)
        let mappedOrders = previews.map{ $0.order }
        XCTAssert(mappedOrders == [0,1,-1,-1])
        
    }
    
    func test_analysisListModel_togglePreview_toggleUnincludedPreview() {
        
        var previews = [AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 0),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: 1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1),
                        AnalysisListModel.AnalysisListCardPreview(id: Analysis(), order: -1)]
        AnalysisListModel.togglePreview(preview: previews[3], previews: &previews)
        let mappedOrders = previews.map{ $0.order }
        XCTAssert(mappedOrders == [0,1,2,-1,-1])
        
    }
    
}
