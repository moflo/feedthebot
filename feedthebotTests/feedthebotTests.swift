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

    
    // MARK: - MFDataset Testing
    
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
//        expect(dSet2?.updatedAt).to(beCloseTo(Date()))
        expect(dSet2?.updatedAt) ≈ (Date(), 0.1)

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

    
    // MARK: - MFResponse Testing
    
    func testMFResponse() {
        
        let catArray = ["TEST1","TEST2"]
        
        var dSet1 = MFResponse(datasetID: "UUID1", trainingType: "textOCR", duration: 10, categoryArray: catArray)
        let updated = Date.init(timeIntervalSinceNow: -60*60*60*2)
        dSet1.updatedAt = updated
        
        expect(dSet1).notTo(beNil())
        expect(dSet1.dataset_id).to(equal("UUID1"))
        expect(dSet1.trainingType).to(equal("textOCR"))
        expect(dSet1.duration).to(equal(10))
        
        expect(dSet1.categoryArray).notTo(beNil())
        expect(dSet1.categoryArray.count) == 2
        expect(dSet1.boundingArray).notTo(beNil())
        expect(dSet1.boundingArray.count) == 0
        expect(dSet1.catPolyArray).notTo(beNil())
        expect(dSet1.catPolyArray.count) == 0

        let bboxArray:[String:[Float]] =
            [
                "TEST1":[1.0,2.0,3.0,4.0],
                "TEST2":[1.0,2.0,3.0,4.0]
            ]
        
        var dSet2 = MFResponse(datasetID: "UUID2", trainingType: "textOCR", duration: 10, boundingArray: bboxArray)
        let updated2 = Date.init(timeIntervalSinceNow: -60*60*60*2)
        dSet2.updatedAt = updated2
        
        expect(dSet2).notTo(beNil())
        expect(dSet2.dataset_id).to(equal("UUID2"))
        expect(dSet2.trainingType).to(equal("textOCR"))
        expect(dSet2.duration).to(equal(10))
        
        expect(dSet2.categoryArray).notTo(beNil())
        expect(dSet2.categoryArray.count) == 0
        expect(dSet2.boundingArray).notTo(beNil())
        expect(dSet2.boundingArray.count) == 2
        expect(dSet2.catPolyArray).notTo(beNil())
        expect(dSet2.catPolyArray.count) == 0

        let catPolyArray:[[String:[Float]]] =
            [
                [
                    "TEST1":[1.0,2.0,3.0,4.0],
                    "TEST2":[1.0,2.0,3.0,4.0]
                ],
                [
                    "TEST3":[1.0,2.0,3.0,4.0,5.0,6.0]
                ]
            ]
        
        var dSet3 = MFResponse(datasetID: "UUID3", trainingType: "textOCR", duration: 10, catPolyArray: catPolyArray)
        let updated3 = Date.init(timeIntervalSinceNow: -60*60*60*2)
        dSet3.updatedAt = updated3
        
        expect(dSet3).notTo(beNil())
        expect(dSet3.dataset_id).to(equal("UUID3"))
        expect(dSet3.trainingType).to(equal("textOCR"))
        expect(dSet3.duration).to(equal(10))
        
        expect(dSet3.categoryArray).notTo(beNil())
        expect(dSet3.categoryArray.count) == 0
        expect(dSet3.boundingArray).notTo(beNil())
        expect(dSet3.boundingArray.count) == 0
        expect(dSet3.catPolyArray).notTo(beNil())
        expect(dSet3.catPolyArray.count) == 2

        

        
    }
    
    // MARK: - MFActivity Test
    
    func testMFActivity() {
        
        let act1 = MFActivity(type: .textOCR, points: 10)
        let updated = Date.init(timeIntervalSinceNow: -60*60*60*2)
        act1.updatedAt = updated
        
        expect(act1).notTo(beNil())
        expect(act1.trainingType.rawValue).to(equal("textOCR"))
        expect(act1.points).to(equal(10))
        expect(act1.user_id).notTo(beNil())
        
        
        let act2 = MFActivity(dictionary: act1.dictionary)
        
        expect(act2).notTo(beNil())
        expect(act2?.trainingType).to(equal(act1.trainingType))
        expect(act2?.points).to(equal(act1.points))
        expect(act2?.user_id).to(equal(act1.user_id))
//        expect(act2?.updatedAt).to(beCloseTo(Date()))
        expect(act2?.updatedAt) ≈ (Date(), 0.1)

        let act3 = MFActivity(dictionary: ["nada":"nada"])
        
        expect(act3).to(beNil())
        
        let dict: [String:Any] = [
            "uuid": "TEST1",
            "points": 102,
            "training_type": "textOCR",
            "user_id": "TEST2"
        ]
        
        let act4 = MFActivity(dictionary: dict)
        
        expect(act4).notTo(beNil())
        if (act4 != nil ) {
            expect(act4!.user_id).to(equal("TEST2"))
            expect(act4!.trainingType).to(equal(.textOCR))
            expect(act4!.points).to(equal(102))
            expect(act4!.uuid).notTo(beNil())
        }
    }

    func testServerPostActivity() {
        

        var expectation1 = XCTestExpectation(description: "Post Activity, error")

        UserManager.sharedInstance.postUserActivity("DEADBEEF", type:.textOCR, points: 1) { (error) in
            expect(error).to(beNil())
            
            expectation1.fulfill()

        }
        
        wait(for: [expectation1], timeout: 10.0)

        expectation1 = XCTestExpectation(description: "Post Activity, error")

        UserManager.sharedInstance.postUserActivity("DEADBEEF", type: .textSentiment, points: 1) { (error) in
            expect(error).to(beNil())
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 10.0)

        expectation1 = XCTestExpectation(description: "Post Activity, error")
        
        UserManager.sharedInstance.postUserActivity("DEADBEEF", type: .imageCategory, points: 1) { (error) in
            expect(error).to(beNil())
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 10.0)
        
        expectation1 = XCTestExpectation(description: "Post Activity, error")
        
        UserManager.sharedInstance.postUserActivity("DEADBEEF", type: .imageBBox, points: 1) { (error) in
            expect(error).to(beNil())
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 10.0)

        expectation1 = XCTestExpectation(description: "Post Activity, error")
        
        UserManager.sharedInstance.postUserActivity("DEADBEEF", type: .imageBBoxCategory, points: 1) { (error) in
            expect(error).to(beNil())
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 10.0)

        expectation1 = XCTestExpectation(description: "Post Activity, error")
        
        UserManager.sharedInstance.postUserActivity("DEADBEEF", type: .imagePolygon, points: 1) { (error) in
            expect(error).to(beNil())
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 10.0)

    }
    
    func testServerActivityLoad() {
        
        let expectation1 = XCTestExpectation(description: "Load Activity, error")
        
        
        UserManager.sharedInstance.loadUserActivity("XXX") { (activity, error) in
            
            expect(error).to(beNil())
            expect(activity).to(beEmpty())
            
            expectation1.fulfill()
            
        }
        
        wait(for: [expectation1], timeout: 10.0)
        
        let expectation2 = XCTestExpectation(description: "Load Activity, user")
        
        UserManager.sharedInstance.loadUserActivity("DEADBEEF") { (activity, error) in
            
            expect(error).to(beNil())
            expect(activity).notTo(beNil())
            expect(activity?.count) > 1
            
//            print(activity?.first)
            
            expectation2.fulfill()
            
        }
        
        wait(for: [expectation2], timeout: 10.0)
        
        
    }
    
//    func testPerformanceExample() {
//        self.measure {
//        }
//    }

}
