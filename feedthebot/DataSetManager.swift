//
//  DataSetManager.swift
//  feedthebot
//
//  Created by d. nye on 4/12/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct MFResponse  {
    var user_id :String = UserManager.sharedInstance.getUUID()
    var dataset_id :String = UUID().uuidString
    var trainingType :String
    
    var captureText :String = ""                                // Capture OCR results
    var category :String = ""                                   // For single category choice
    var cetegoryArray :[String] = [String]()                    // For multiple choice category
    var boundingBox :[Float] = [Float]()                        // For single bounding box choice
    var boundingArray :[String:[Float]] = [String:[Float]]()    // For category bounding boxes
    
    var duration :Float = 0.0   // Time to complete response

    var dictionary: [String: Any] {
        return [
            "user_id": self.user_id,
            "training_type": self.trainingType,
            "capture_text": self.captureText,
            "category": self.category,
            "cetegory_array": self.cetegoryArray,
            "bounding_box": self.boundingBox,
            "bounding_array": self.boundingArray,
            "updatedAt": Timestamp()
        ]
    }

    init() {
        self.trainingType = "Text"
    }

    init(datasetID: String, trainingType: String, captureText: String, duration :Float) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.captureText = captureText
        self.duration = duration
    }
    
    init(datasetID: String, trainingType: String, category: String, duration :Float) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.category = category
        self.duration = duration
    }
    

    
}

class MFDataSet {
    var uuid :String = UUID().uuidString
    var points :Int = 0
    var multiplier :Float = 1.0
    var trainingType :String
    var eventCount :Int = 10
    var dataURLArray :[String] = [String]()
    var categoryArray :[String] = [String]()
    var responseArray :[MFResponse] = [MFResponse]()
    var updatedAt :Date = Date()
    
    var dictionary: [String: Any] {
        return [
            "uuid": self.uuid,
            "points": self.points,
            "multiplier": self.multiplier,
            "training_type": self.trainingType,
            "eventCount": self.eventCount,
            "dataURLArray": self.dataURLArray,
            "categoryArray": self.categoryArray,
//            "responseArray": self.responseArray,
            "updatedAt": Timestamp()
        ]
    }
    
    init() {
        self.uuid = ""; self.trainingType = "Text";
    }
    
    convenience init(uuid: String, points: Int) {
        self.init()
        self.uuid = uuid
        self.points = points
    }
    
    
    convenience init?(dictionary: [String: Any] ) {
        guard let dict = dictionary as [String: Any]? else { return nil }
        guard let uuid = dict["uuid"] as? String else { return nil }
        guard let points = dict["points"] as? Int else { return nil }
        
        self.init(uuid: uuid, points: points)
        
        if let training_type = dict["training_type"] as? String { self.trainingType = training_type }
        
        
        if let timestamp = dict["updatedAt"] as? Timestamp {
            self.updatedAt = timestamp.dateValue()
        }
        
    }
    
    func getImage() -> UIImage {
        return UIImage(named: "icon_text")!
    }
}


class DataSetManager : NSObject {
    static let sharedInstance = DataSetManager()

    
    func demoDataSet(_ trainingType :String) -> MFDataSet {
        let data = MFDataSet(uuid: "DEADBEEF", points: 30)
        
        return data
    }
}

