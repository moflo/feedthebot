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
    var updatedAt :Date = Date()
    
    var dictionary: [String: Any] {
        return [
            "uuid": self.uuid,
            "points": self.points,
            "training_type": self.trainingType.rawValue,
            "updatedAt": Timestamp()
        ]
    }
    
    init() {
        self.uuid = ""; self.trainingType = .other;
    }
    
    convenience init(type: MFTrainingType, points: Int) {
        self.init()
        self.trainingType = type
        self.user_id = UserManager.sharedInstance.getUUID()
        self.points = points
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

    fileprivate var userPoints :Int = 0

    func getUUID() -> String {
        let auth = FUIAuth.defaultAuthUI()!
        guard let user = auth.auth?.currentUser, let userID = user.uid as String? else {
            return self.userUUID
        }
        
        self.userUUID =  userID
        return self.userUUID
    }

    func getUserDetails() -> (uuid: String, points: Int) {
        let uuid = self.userUUID
        let points = self.userPoints
        
        return (uuid,points)
    }

    func getUserTotalPoints() -> Int {
        return self.userPoints
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
        
        self.updateUserDetails(uuid: self.userUUID, points: points + self.userPoints)
    }
    
    func updateUserDetails(uuid: String, points: Int) {
        
         let userObj = MFUser(uuid: uuid, points: points)
        //        self.synchronize()
        
        // Update Firebase user details
        let db = Firestore.firestore()
        db.collection("users").document(uuid).setData(userObj.dictionary, merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        self.userUUID = userObj.uuid
        self.userPoints = userObj.points

    }

    
    func refreshUserData( _ completionHandler: @escaping (Error?) -> () ) {
        let auth = FUIAuth.defaultAuthUI()!
        guard let user = auth.auth?.currentUser, let userID = user.uid as String? else {
            let error = NSError(domain: "Error user ID not set", code: -101, userInfo: nil)
            completionHandler(error)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let user = document.flatMap({
                $0.data().flatMap({ (data) in
                    return MFUser(dictionary: data)
                })
            }) {
//                self.userObj = user
                self.userUUID = user.uuid
//                self.userName = user.name
//                self.userEmail = user.email
//                self.userName = user.name
//                self.userAvatarURL = user.avatar_url
                self.userPoints = user.points

                completionHandler(nil)
            } else {
                let error = NSError(domain: "Error refreshing users data", code: -102, userInfo: nil)
                completionHandler(error)
            }
        }
        
        
    }
    
    // MARK: - Test Methods

    func getTestActivity(_ count:Int = 2) -> [MFActivity] {
        var activityList = [MFActivity]()
        for i in 1...count {
            let activity = MFActivity(type: .textOCR, points: i*32)
            activityList.append(activity)
        }
        return activityList
    }
}


