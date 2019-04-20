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

enum MFTrainingType :String {
    case textOCR = "textOCR"
    case textSentiment = "textSentiment"
    case imageCategory = "imageCategory"
    case imageBBox = "imageBBox"
    case imageBBoxCategory = "imageBBoxCategory"
    case imagePolygon = "imagePolygon"
    case other = ""
    
    func detail() -> String {
        switch self {
        case .textOCR : return "Text Recognition"
        case .textSentiment : return "Text Sentiment"
        case .imageCategory : return "Image Category"
        case .imageBBox : return "Image Bounding Box"
        case .imageBBoxCategory : return "Image Bounding Categories"
        case .imagePolygon : return "Image Polygon"
        default : return "Training"
        }
    }
}

class MFDataSet {
    var uuid :String = UUID().uuidString
    var order_id :String
    var points :Int = 0
    var multiplier :Float = 1.0
    var trainingType :String
    var training_type :MFTrainingType
    var instruction :String = "This should be long text which describes the type of training data."
    var eventCount :Int = 10
    var limitSeconds :Int = 60*2
    var dataURLArray :[String] = [String]()
    var categoryArray :[String] = [String]()
    var responseArray :[MFResponse] = [MFResponse]()
    var updatedAt :Date = Date()
    
    var dictionary: [String: Any] {
        return [
            "uuid": self.uuid,
            "order_id": self.order_id,
            "points": self.points,
            "multiplier": self.multiplier,
            "training_type": self.trainingType,
            "instruction": self.instruction,
            "eventCount": self.eventCount,
            "limitSeconds": self.limitSeconds,
            "dataURLArray": self.dataURLArray,
            "categoryArray": self.categoryArray,
//            "responseArray": self.responseArray,
            "updatedAt": Timestamp()
        ]
    }
    
    init() {
        self.uuid = ""; self.order_id = ""; self.trainingType = "textOCR"; self.training_type = .textOCR
    }
    
    convenience init(order_id: String, trainingType: String) {
        self.init()
        self.order_id = order_id
        self.trainingType = trainingType
        self.training_type = MFTrainingType(rawValue: trainingType) ?? .textOCR
    }
    
    convenience init?(snapshot: DocumentSnapshot) {
        guard let dict = snapshot.data() else { return nil }
        self.init(dictionary: dict)
    }

    convenience init?(dictionary: [String: Any] ) {
        guard let dict = dictionary as [String: Any]? else { return nil }
        guard let order_id = dict["order_id"] as? String else { return nil }
        guard let training_type = dict["training_type"] as? String else { return nil }
        
        self.init(order_id: order_id, trainingType: training_type)
        
        if let points = dict["points"] as? Int { self.points = points }
        if let multiplier = dict["multiplier"] as? Double { self.multiplier = Float(multiplier) }
        if let eventCount = dict["eventCount"] as? Int { self.eventCount = eventCount }
        if let limitSeconds = dict["limitSeconds"] as? Int { self.limitSeconds = limitSeconds }
        if let instruction = dict["instruction"] as? String { self.instruction = instruction }

        if let dataURLArray = dict["dataURLArray"] as? [String] {
            dataURLArray.forEach { self.dataURLArray.append($0) }
        }
        if let categoryArray = dict["categoryArray"] as? [String] {
            categoryArray.forEach { self.categoryArray.append($0) }
        }
        
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


    
    // MARK: - Server Methods
    
    func postTraining(_ data:MFDataSet?) {
        guard data != nil else { return }
        
    }
    
    func loadPage(type: MFTrainingType, page: Int, completionHandler: @escaping ([MFDataSet]?, Error?) -> () ) {
        let userID = UserManager.sharedInstance.getUUID()
        loadPage(userID: userID, type: type, page: page) { (datasets, error) in
            completionHandler(datasets,error)
        }
        
    }
    
    func loadPage(userID: String, type: MFTrainingType, page: Int, completionHandler: @escaping ([MFDataSet]?, Error?) -> () ) {
        guard userID.count > 0 else {
            let error = NSError(domain: "DataSetManager", code: -1, userInfo: ["userInfo":"UserID cannot be nil"])
            completionHandler(nil,error)
            return
        }
        guard page > 0 else {
            let error = NSError(domain: "DataSetManager", code: -1, userInfo: ["userInfo":"Page cannot be 0"])
            completionHandler(nil,error)
            return
        }
        
        let db = Firestore.firestore()
        let activityRef = db.collection("datasets")
        let query = activityRef.order(by: "updatedAt", descending: true).limit(to: page)
        query.getDocuments { (snapshot, err) in
            guard let snapshot = snapshot, err == nil else {
                let error = NSError(domain: "DataSetManager", code: -1, userInfo: ["userInfo":"No activities found"])
                completionHandler(nil,error)
                return
            }
            let datasets = snapshot.documents.map { (document) -> MFDataSet in
                if let model = MFDataSet(snapshot: document) {
                    return model
                } else {
                    return MFDataSet()
                }
            }
            completionHandler(datasets,nil)
        }
    }

    // MARK: Demo methods
    
    func demoDataSet(_ trainingType :String) -> MFDataSet {
        let data = MFDataSet(order_id: "DEADBEEF", trainingType: "textOCR")
        
        data.dataURLArray.append("https://github.com/wangpengnorman/SAR-Strong-Baseline-for-Text-Recognition/blob/master/data/beach.jpg?raw=true")
        data.dataURLArray.append("https://github.com/wangpengnorman/SAR-Strong-Baseline-for-Text-Recognition/blob/master/data/united.jpg?raw=true")
        
        // https://www.kaggle.com/backalla/words-mnist
        
        data.dataURLArray.append("https://storage.googleapis.com/kagglesdsdata/datasets%2F30321%2F38645%2Fdataset%2Fv011_words_small%2F1020.jpeg?GoogleAccessId=datasets-dataviewer@kaggle-161607.iam.gserviceaccount.com&Expires=1555804635&Signature=I%2FniQUbbpULfjYB%2BMR9A0R1v3H%2Bh5ONimd93l5Pzc5XEO%2F0InALRVgdarJUfRUHXx2OYMvItsxyLpH79q5I52rXtLP60NYGBLpIMEFhgLgb8YkHVc9jfYx%2F1cdApn5AhwwziMKSYcn2Sdig9cGUpYLffBoJ9ySjkJ%2BCe03XkrBRJiKCV5G4MBckHGHKqHZwgBgN3j%2FsrUM8Q8DkKuHedDGunRykZlDd3f%2B52r2bn1ru%2FZLZsR%2FR3NIk2Vyf0Je%2B2IV%2F9UH8Bs7u%2Fyi3wt4FQPpQKml4kykDEBPydxkP3BOHszowF1glgUUyUKy6utI4XbfuFL5DdbZ8TtsV0z%2BqpqQ%3D%3D")
        
        data.dataURLArray.append("https://storage.googleapis.com/kagglesdsdata/datasets%2F30321%2F38645%2Fdataset%2Fv011_words_small%2F1077.png?GoogleAccessId=datasets-dataviewer@kaggle-161607.iam.gserviceaccount.com&Expires=1555804635&Signature=jdgs0TiW71HiMPcvc%2BqdQOyZBXHfzNQuYI7ccjVoGblFNDY04a7g9tvH6UeBKshfm2hH5KsBSzSnmGxcfrEdOI9sGxEjbkIZ8SaHJFPcSOuKrHpSmJoFJb5L5THo146QuiZ%2BoUICcGDHnoj23eeDfxtATF9mrH1ZligBD%2B0RFBglcLHXS%2FR1M%2BmLaj98JM8g4WuiDrp3W8aX6O%2FxxXc9tVNjQQQ%2B7UiPc7UxXHg8OaIHV7waUjkdjwrFDpZQb303W9OQ6T2Oe9vKzdByMzyx3y01T%2Fv0uPD%2FZfPKZ2yT%2FO6bk1WuQCkztzpam0KjoEEomq4Kdwmn5ckEnOvnOZkhew%3D%3D")
        
        data.dataURLArray.append("https://storage.googleapis.com/kagglesdsdata/datasets%2F130171%2F311075%2Fkaggle%2FTrain%2F0iuj.png?GoogleAccessId=datasets-dataviewer@kaggle-161607.iam.gserviceaccount.com&Expires=1555784360&Signature=poySvUTvUJ91sh%2BfC60KUjwGEUgWsZzOpuuMLtFAN05Zj6tNuiG4VJ8PIUSq1zxOthvr1YttbeFOOvDMupNI92gGolb1o4s%2BTQk3OJKg80SRU6vEA92bjGDnP7XzEOo8Y1nUi2H0OsnarT2iXFOVKB0JubUbDDfpA1lCTM6vsgtK91BejCKHuCjdsdfqcbOlf%2FJ8wCQBgmAZD6X6ayrr1PiGF5vhtf6D1FDUz7nPQedptBPKZ50F8HdPRrcciOiUSB%2F2Bp4oo6mnNL0WJPJuVXxlo2WYtTEYIK66pOUqh7J5lRGgcWIsi0wphHKLvrUQgXf5mTfTajrzPb%2BTg9YIDw%3D%3D")
        
        return data
    }
    
}

