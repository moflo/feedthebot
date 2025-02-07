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
    
    var categoryArray :[String] = [String]()                            // For multiple choice category
    var boundingArray :[String:[Float]] = [String:[Float]]()            // For category bounding boxes
    var catPolyArray: [ [String:[Float]] ] = [ [String:[Float]] ]()     // For category polygons
    
    var duration :Int = 0   // Time (seconds) to complete response

    var updatedAt :Date = Date()

    var dictionary: [String: Any] {
        return [
            "user_id": self.user_id,
            "training_type": self.trainingType,
            "category_array": self.categoryArray,
            "bounding_array": self.boundingArray,
            "cat_poly_array": self.catPolyArray,
            "updatedAt": Timestamp()
        ]
    }

    init() {
        self.trainingType = "Text"
    }

    init(datasetID: String, trainingType: String, duration :Int, categoryArray :[String]) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.duration = duration
        self.categoryArray = categoryArray
    }
    
    init(datasetID: String, trainingType: String, duration :Int, boundingArray :[String:[Float]]) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.duration = duration
        self.boundingArray = boundingArray
    }
    
    init(datasetID: String, trainingType: String, duration :Int, catPolyArray :[[String:[Float]]]) {
        self.init()
        self.dataset_id = datasetID
        self.trainingType = trainingType
        self.duration = duration
        self.catPolyArray = catPolyArray
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
    
    func iconName() -> String {
        switch self {
        case .textOCR : return "icon_text"
        case .textSentiment : return "icon_text"
        case .imageCategory : return "icon_classify"
        case .imageBBox : return "icon_bounding"
        case .imageBBoxCategory : return "icon_classify"
        case .imagePolygon : return "icon_polygon"
        default : return "icon_text"
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
    var instruction :String = "Tap on the image once to start drawing a rectangle. Tap again to finish."
    var eventCount :Int = 10
    var limitSeconds :Int = 60*2
    var dataURLArray :[String] = [String]()
    var categoryArray :[String] = [String]()
    var responseArray :[MFResponse] = [MFResponse]()
    var responseCount :Int = 0
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
            "responseCount": self.responseCount,
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
        self.uuid = snapshot.documentID
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
        if let responseCount = dict["responseCount"] as? Int { self.responseCount = responseCount }
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
        let imageName = self.training_type.iconName()
        return UIImage(named: imageName)!
    }
}


class DataSetManager : NSObject {
    static let sharedInstance = DataSetManager()


    
    // MARK: - Server Methods
    
    func postTraining(_ data:MFDataSet?, duration: Int, categoryArray: [String]?) {
        guard data != nil, categoryArray != nil else { return }
        
        let user = UserManager.sharedInstance.getUserDetails()
        
        var response = MFResponse(datasetID: data!.uuid,
                                  trainingType: data!.trainingType,
                                  duration: duration,
                                  categoryArray: categoryArray!)
        
        response.user_id = user.uuid
        
        let db = Firestore.firestore()
        db.collection("response").document().setData(response.dictionary, merge: false) { err in
            if let err = err {
                print("Error writing response: \(err)")
            } else {
                print("Response successfully written!")
                
                UserManager.sharedInstance.postUserActivity(user.uuid,
                                                            type: data!.training_type,
                                                            points: data!.points)
                
                UserManager.sharedInstance.updatePointsTotal(Int(data!.points))
            }
        }

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
        let query = activityRef.whereField("training_type", isEqualTo: type.rawValue).order(by: "updatedAt", descending: true).limit(to: page)
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
    
    func demoDataSet(_ trainingType :MFTrainingType) -> MFDataSet {
        let data = MFDataSet(order_id: "DEADBEEF", trainingType: "textOCR")
        
        if trainingType == .textSentiment {
            data.dataURLArray.append("We encourage you to review your app concept and incorporate different content and features that are in compliance with the App Store Review Guidelines.")
            data.dataURLArray.append("Specifically, your app contains placeholder text in the description and throughout the app.")
            data.dataURLArray.append("While some migth find this to be true, we are driven by back end processes.")
            data.dataURLArray.append("We are providing a service for data scientist and CoreML developers to improve their machine learning models.")
            data.dataURLArray.append("What we hope to accomplish is to provide a method for rapid improvement of the embedded machine learning models using crowdsourced workers.")
            data.dataURLArray.append("We think it's appropriate to compensate the mobile app users for the work they are doing, similar to how artists are compenstated for their work.")
            data.dataURLArray.append("This solution is a marketplace for human intelligence, we are paying users for their skill.")
            data.dataURLArray.append("We think there are socially beneficial data labeling work that is best performed by skilled users, and these users are often on mobile platforms.")
            data.dataURLArray.append("While other solutions are using so-called responsive websites, we are working with customers who need to have their CoreML model tuned and therefore are providing a native mobile app.")
            data.dataURLArray.append("We appreciate the chance to discuss this business approach with you.")

            data.instruction = "Read the message and then select the sentiment using buttons below."
        }
        else {
            data.dataURLArray.append("https://github.com/wangpengnorman/SAR-Strong-Baseline-for-Text-Recognition/blob/master/data/beach.jpg?raw=true")
            data.dataURLArray.append("https://github.com/wangpengnorman/SAR-Strong-Baseline-for-Text-Recognition/blob/master/data/united.jpg?raw=true")
            
            // https://www.kaggle.com/backalla/words-mnist
            
            data.dataURLArray.append("https://storage.googleapis.com/kagglesdsdata/datasets%2F30321%2F38645%2Fdataset%2Fv011_words_small%2F1020.jpeg?GoogleAccessId=datasets-dataviewer@kaggle-161607.iam.gserviceaccount.com&Expires=1555804635&Signature=I%2FniQUbbpULfjYB%2BMR9A0R1v3H%2Bh5ONimd93l5Pzc5XEO%2F0InALRVgdarJUfRUHXx2OYMvItsxyLpH79q5I52rXtLP60NYGBLpIMEFhgLgb8YkHVc9jfYx%2F1cdApn5AhwwziMKSYcn2Sdig9cGUpYLffBoJ9ySjkJ%2BCe03XkrBRJiKCV5G4MBckHGHKqHZwgBgN3j%2FsrUM8Q8DkKuHedDGunRykZlDd3f%2B52r2bn1ru%2FZLZsR%2FR3NIk2Vyf0Je%2B2IV%2F9UH8Bs7u%2Fyi3wt4FQPpQKml4kykDEBPydxkP3BOHszowF1glgUUyUKy6utI4XbfuFL5DdbZ8TtsV0z%2BqpqQ%3D%3D")
            
            data.dataURLArray.append("https://storage.googleapis.com/kagglesdsdata/datasets%2F30321%2F38645%2Fdataset%2Fv011_words_small%2F1077.png?GoogleAccessId=datasets-dataviewer@kaggle-161607.iam.gserviceaccount.com&Expires=1555804635&Signature=jdgs0TiW71HiMPcvc%2BqdQOyZBXHfzNQuYI7ccjVoGblFNDY04a7g9tvH6UeBKshfm2hH5KsBSzSnmGxcfrEdOI9sGxEjbkIZ8SaHJFPcSOuKrHpSmJoFJb5L5THo146QuiZ%2BoUICcGDHnoj23eeDfxtATF9mrH1ZligBD%2B0RFBglcLHXS%2FR1M%2BmLaj98JM8g4WuiDrp3W8aX6O%2FxxXc9tVNjQQQ%2B7UiPc7UxXHg8OaIHV7waUjkdjwrFDpZQb303W9OQ6T2Oe9vKzdByMzyx3y01T%2Fv0uPD%2FZfPKZ2yT%2FO6bk1WuQCkztzpam0KjoEEomq4Kdwmn5ckEnOvnOZkhew%3D%3D")
            
            data.dataURLArray.append("https://storage.googleapis.com/kagglesdsdata/datasets%2F130171%2F311075%2Fkaggle%2FTrain%2F0iuj.png?GoogleAccessId=datasets-dataviewer@kaggle-161607.iam.gserviceaccount.com&Expires=1555784360&Signature=poySvUTvUJ91sh%2BfC60KUjwGEUgWsZzOpuuMLtFAN05Zj6tNuiG4VJ8PIUSq1zxOthvr1YttbeFOOvDMupNI92gGolb1o4s%2BTQk3OJKg80SRU6vEA92bjGDnP7XzEOo8Y1nUi2H0OsnarT2iXFOVKB0JubUbDDfpA1lCTM6vsgtK91BejCKHuCjdsdfqcbOlf%2FJ8wCQBgmAZD6X6ayrr1PiGF5vhtf6D1FDUz7nPQedptBPKZ50F8HdPRrcciOiUSB%2F2Bp4oo6mnNL0WJPJuVXxlo2WYtTEYIK66pOUqh7J5lRGgcWIsi0wphHKLvrUQgXf5mTfTajrzPb%2BTg9YIDw%3D%3D")
            
        }
        
        // Category
        
        data.categoryArray.append(contentsOf: ["Mild","Rough","Obvious","Likely","Negative"])
        
        return data
    }
    
}

