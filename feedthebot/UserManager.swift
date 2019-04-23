//
//  UserManager.swift
//  feedthebot
//
//  Created by d. nye on 4/11/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseUI


struct MFUser {
    // User class object
    var uuid :String = UUID().uuidString
    var points :Int = 0
    var lifetimePoints :Int = 0
    var exchangeRate :Float = 0.013      // $0.013 per point
    var name :String
    var email :String
    var provider :String? = nil
    var avatar_url :String
    var fbid :String? = nil
    var updatedAt :Timestamp = Timestamp()
    
    var dictionary: [String: Any] {
        return [
            "uuid": self.uuid,
            "points": self.points,
            "lifetime_points": self.lifetimePoints,
            "exchange_rate": self.exchangeRate,
            "name": self.name,
            "email": self.email,
            "provider": self.provider ?? "",
            "avatar_url": self.avatar_url,
            "fbid": self.fbid ?? "",
            "updatedAt": Timestamp()
        ]
    }
    
    init() {
        self.name = ""; self.email = ""; self.avatar_url = "";
    }
    
    init(uuid: String, points: Int) {
        self.init()
        self.uuid = uuid
        self.points = points
    }
    
    
    init?(dictionary: [String: Any] ) {
        guard let dict = dictionary as [String: Any]? else { return nil }
        guard let uuid = dict["uuid"] as? String else { return nil }
        guard let points = dict["points"] as? Int else { return nil }
        
        self.init(uuid: uuid, points: points)
        
        if let lifetimePoints = dict["lifetime_points"] as? Int { self.lifetimePoints = lifetimePoints }
        if let exchangeRate = dict["exchange_rate"] as? Float { self.exchangeRate = exchangeRate }
        if let name = dict["name"] as? String { self.name = name }
        if let email = dict["email"] as? String { self.email = email }
        if let provider = dict["provider"] as? String { self.provider = provider }
        if let avatar_url = dict["avatar_url"] as? String { self.avatar_url = avatar_url }
        if let fbid = dict["fbid"] as? String { self.fbid = fbid }
        
        
        if let timestamp = dict["updatedAt"] as? Timestamp {
            self.updatedAt = timestamp
        }
        
    }
}


class MFActivity {
    var uuid :String = UUID().uuidString
    var user_id :String = UUID().uuidString
    var points :Int = 0
    var trainingType :MFTrainingType
    var wasPaid :Bool = false
    var earnings :Double = 0.0
    var updatedAt :Date = Date()
    
    var dictionary: [String: Any] {
        return [
            "user_id": self.user_id,
            "points": self.points,
            "training_type": self.trainingType.rawValue,
            "was_paid": self.wasPaid,
            "updatedAt": Timestamp()
        ]
    }
    
    init() {
        self.uuid = ""; self.trainingType = .other;
    }
    
    convenience init(type: MFTrainingType, points: Int) {
        self.init()
        let user = UserManager.sharedInstance.getUserDetails()
        self.trainingType = type
        self.user_id = user.uuid
        self.points = points
        self.earnings = Double(points) * user.exchangeRate
    }
    
    convenience init?(snapshot: DocumentSnapshot) {
        guard let dict = snapshot.data() else { return nil }
        self.init(dictionary: dict)
        self.uuid = snapshot.documentID
    }

    convenience init?(dictionary: [String: Any] ) {
        guard let dict = dictionary as [String: Any]? else { return nil }
        guard let training_type = dict["training_type"] as? String else { return nil }
        guard let trainType = MFTrainingType(rawValue: training_type) else { return nil }
        guard let points = dict["points"] as? Int else { return nil }
        
        self.init(type: trainType, points: points)
        
        if let user_id = dict["user_id"] as? String { self.user_id = user_id }
        if let was_paid = dict["was_paid"] as? Bool { self.wasPaid = was_paid }

        if let timestamp = dict["updatedAt"] as? Timestamp {
            self.updatedAt = timestamp.dateValue()
        }
        
    }
    
    func getImage() -> UIImage {
        return UIImage(named: "icon_text")!
    }
}


class UserManager : NSObject {
    static let sharedInstance = UserManager()

    fileprivate var userUUID :String = ""

    fileprivate var userObj = MFUser()

    func getUUID() -> String {
        let auth = FUIAuth.defaultAuthUI()!
        guard let user = auth.auth?.currentUser, let userID = user.uid as String? else {
            return self.userUUID
        }
        
        self.userUUID =  userID
        self.userObj.uuid = userID
        return self.userUUID
    }

    func getUserDetails() -> (uuid: String, points: Int, exchangeRate: Double) {
        let uuid = self.userUUID
        let points = self.userObj.points
        let exchangeRate = self.userObj.exchangeRate
        return (uuid,points,Double(exchangeRate))
    }

    func getUserTotalPoints() -> Int {
        return self.userObj.points
    }
    
    func shouldDoubleTapToSelect() -> Bool {
        return true
    }
    // MARK: - Server Methods
    
    func doAnonymousLogin() {
        Auth.auth().signInAnonymously() { (authResult, error) in
            // Check anonymous user
            if (error != nil) {
                print("Authentication error:", error!.localizedDescription)
            } else if (authResult != nil) {
                let user = authResult!.user
                let isAnonymous = user.isAnonymous  // true
                let uid = user.uid
                self.userUUID = uid
                
                self.userObj.uuid = uid
                self.userObj.name = user.displayName ?? ""
                self.userObj.email = user.email ?? ""
                self.userObj.avatar_url = user.photoURL != nil ? user.photoURL!.absoluteString : ""

                print("Authenticated anonymous:", uid, isAnonymous)
            }
            else {
                print("Authentication error: authResult nil")
            }
        }

    }
    
    func doResetAccount() {
        // Method to log out of previous Firebase account
        let authUI = FUIAuth.defaultAuthUI()
        try! authUI?.signOut()
        
    }

    func updatePointsTotal(_ points: Int) {
        self.updateUserDetails(uuid: self.userUUID, points: points)
    }
    
    func updateUserDetails(uuid: String, points: Int, completionHandler: ((Error?) -> () )! = nil ) {
        
        self.userObj.uuid = uuid
        self.userObj.points = self.userObj.points + points
        self.userObj.lifetimePoints = self.userObj.lifetimePoints + points
        //        self.synchronize()
        
        // Update Firebase user details
        let db = Firestore.firestore()
        db.collection("users").document(uuid).setData(userObj.dictionary, merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                if completionHandler != nil {
                    completionHandler(err)
                }
            } else {
                print("Document successfully written!")
                if completionHandler != nil {
                    completionHandler(nil)
                }
            }
        }
        

    }

    
    func refreshUserData( _ completionHandler: @escaping (Error?) -> () ) {
        let auth = FUIAuth.defaultAuthUI()!
        guard let user = auth.auth?.currentUser, let userID = user.uid as String? else {
            let error = NSError(domain: "Error user ID not set", code: -101, userInfo: nil)
            completionHandler(error)
            return
        }
        
        self.refreshUserData(userID, completionHandler: completionHandler)
    }
    
    func refreshUserData( _ userID: String, completionHandler: @escaping (Error?) -> () ) {

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
//            print("GetUser: ",document?.data())
            if document?.data() == nil && error == nil { completionHandler(nil) }
            if let user = document.flatMap({
                $0.data().flatMap({ (data) in
                    return MFUser(dictionary: data)
                })
            }) {
                self.userObj = user
                self.userUUID = user.uuid

                completionHandler(nil)
            } else {
                let error = NSError(domain: "Error refreshing users data", code: -102, userInfo: nil)
                completionHandler(error)
            }
        }
        
        
    }
    
    // MARK: MFActivity Methods
    
    func postActivity(_ type: MFTrainingType, points: Int) {
        let userID = UserManager.sharedInstance.getUUID()
        postUserActivity(userID,type: type, points: points)
    }
    
    func postUserActivity(_ userID: String, type: MFTrainingType, points: Int, completionHandler: ((Error?) -> () )! = nil ) {
        guard userID.count > 0 else { return }

        let activity = MFActivity(type: type, points: points)
        activity.user_id = userID
        
        let db = Firestore.firestore()
        db.collection("activity").document().setData(activity.dictionary, merge: false) { err in
            if let err = err {
                print("Error writing activity: \(err)")
            } else {
                print("Activity successfully written!")
            }
            if (completionHandler != nil) {
                completionHandler(err)
            }
        }
        
    }

    func loadActivity(completionHandler: @escaping ([MFActivity]?, Error?) -> () ) {
        let userID = UserManager.sharedInstance.getUUID()
        loadUserActivity(userID, completionHandler: completionHandler)
    }

    func loadUserActivity(_ userID: String, completionHandler: @escaping ([MFActivity]?, Error?) -> () ) {
        guard userID.count > 0 else {
            let error = NSError(domain: "Activity", code: -1, userInfo: ["userInfo":"UserID cannot be nil"])
            completionHandler(nil,error)
            return
        }

        let db = Firestore.firestore()
        let activityRef = db.collection("activity")
        let query = activityRef.whereField("user_id", isEqualTo: userID).order(by: "updatedAt", descending: true)
        query.getDocuments { (snapshot, err) in
            guard let snapshot = snapshot, err == nil else {
                let error = NSError(domain: "Activity", code: -1, userInfo: ["userInfo":"No activities found"])
                completionHandler(nil,error)
                return
            }
            let activities = snapshot.documents.map { (document) -> MFActivity in
                if let model = MFActivity(snapshot: document) {
                    return model
                } else {
                    return MFActivity()
                }
            }
            completionHandler(activities,nil)
        }
    }

    // MARK: - Test Methods

    func getTestActivity(_ count:Int = 6) -> [MFActivity] {
        var activityList = [MFActivity]()
        for i in 1...count {
            let activity = MFActivity(type: .textOCR, points: i*32)
            activityList.append(activity)
        }
        return activityList
    }
}


