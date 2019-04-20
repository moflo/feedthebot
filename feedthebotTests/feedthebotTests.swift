//
//  feedthebotTests.swift
//  feedthebotTests
//
//  Created by d. nye on 4/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import XCTest
@testable import feedthebot
import Nimble


class feedthebotTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMFDataSet() {
        
        let dSet1 = MFDataSet(order_id: "UUID1", trainingType: "textOCR")
        let updated = Date.init(timeIntervalSinceNow: -60*60*60*2)
        dSet1.updatedAt = updated
        
        expect(dSet1).notTo(beNil())
        expect(dSet1.order_id).to(equal("UUID1"))
        expect(dSet1.trainingType).to(equal("textOCR"))
        expect(dSet1.training_type.rawValue).to(equal("textOCR"))
        expect(dSet1.training_type).to(equal(.textOCR))
        expect(dSet1.points).to(equal(0))
        expect(dSet1.multiplier).to(beCloseTo(1.0, within:0.01))
        expect(dSet1.instruction).notTo(beNil())
        expect(dSet1.eventCount).to(equal(10))
        expect(dSet1.limitSeconds).to(equal(2*60))

        expect(dSet1.dataURLArray).notTo(beNil())
        expect(dSet1.categoryArray).notTo(beNil())
        expect(dSet1.responseArray).notTo(beNil())


        let dSet2 = MFDataSet(dictionary: dSet1.dictionary)
        
        expect(dSet2).notTo(beNil())
        expect(dSet2?.order_id).to(equal("UUID1"))
        expect(dSet2?.training_type).to(equal(dSet1.training_type))
        expect(dSet2?.training_type).to(equal(dSet1.training_type))
        expect(dSet2?.trainingType).to(equal(dSet1.trainingType))
        expect(dSet2?.points).to(equal(dSet1.points))
        expect(dSet2?.multiplier).to(equal(dSet1.multiplier))
        expect(dSet2?.instruction).to(equal(dSet1.instruction))
        expect(dSet2?.updatedAt).to(beCloseTo(Date()))
        
        let dSet3 = MFDataSet(dictionary: ["nada":"nada"])
        
        expect(dSet3).to(beNil())
        
        let dict: [String:Any] = [
            "uuid": "TEST1",
            "order_id": "TESTID",
            "points": 102,
            "multiplier": 10.0,
            "training_type": "textOCR",
            "instruction": "TEST2",
            "eventCount": 103,
            "limitSeconds": 104,
            "dataURLArray": [
                "URL1",
                "URL2"
            ],
            "categoryArray": [
                "CAT1",
                "CAT2"
            ]
            //            "responseArray": self.responseArray,
//            "updatedAt": Timestamp()
        ]
        
        let dSet4 = MFDataSet(dictionary: dict)
        
        expect(dSet4).notTo(beNil())
        if (dSet4 != nil ) {
            expect(dSet4!.order_id).to(equal("TESTID"))
            expect(dSet4!.trainingType).to(equal("textOCR"))
            expect(dSet4!.training_type.rawValue).to(equal("textOCR"))
            expect(dSet4!.training_type).to(equal(.textOCR))
            expect(dSet4!.points).to(equal(102))
            expect(dSet4!.multiplier).to(beCloseTo(10.0, within:0.01))
            expect(dSet4!.instruction).notTo(beNil())
            expect(dSet4!.eventCount).to(equal(103))
            expect(dSet4!.limitSeconds).to(equal(104))
            
            expect(dSet4!.dataURLArray).notTo(beNil())
            expect(dSet4!.dataURLArray.count).to(equal(2))
            expect(dSet4!.dataURLArray[0]).to(equal("URL1"))
            expect(dSet4!.dataURLArray[1]).to(equal("URL2"))

            expect(dSet4!.categoryArray).notTo(beNil())
            expect(dSet4!.categoryArray.count).to(equal(2))
            expect(dSet4!.categoryArray[0]).to(equal("CAT1"))
            expect(dSet4!.categoryArray[1]).to(equal("CAT2"))
            expect(dSet4!.responseArray).notTo(beNil())
        }
    }
    
    func testServerDataSetLoad() {
        
        let expectation1 = XCTestExpectation(description: "Load Datasets, error")
        
        DataSetManager.sharedInstance.loadPage(type: .textOCR, page: 0) { (datasets, error) in
            
            expect(error).notTo(beNil())
            expect(datasets).to(beNil())
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 10.0)

        let expectation2 = XCTestExpectation(description: "Load Datasets, page 1")
        
        DataSetManager.sharedInstance.loadPage(type: .textOCR, page: 1) { (datasets, error) in
            
            expect(error).to(beNil())
            expect(datasets).notTo(beNil())
            expect(datasets?.count).to(equal(1))
            
            expectation2.fulfill()
            
        }
        
        wait(for: [expectation2], timeout: 10.0)
        

    }

    
//    func testPerformanceExample() {
//        self.measure {
//        }
//    }

}
