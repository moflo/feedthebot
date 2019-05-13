//
//  ViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import FirebaseUI


class ViewController: UIViewController {
    @IBAction func doAccountButton(_ sender: Any) {
        let alert = MFAlertTrainView(title: "Feed Me!",
                                     icon: "",
                                     info: "Welcome! Try a demo, or select an activity to earn points which you can then redeem for cash.",
                                     prompt: .SELECT_SOMETHING) { (category, buttonIndex) in
                                        
        }
        alert.show()

    }
    @IBAction func doSettingsButton(_ sender: Any) {
        if UserManager.sharedInstance.isUserAnonymous() {
            let alert = UIAlertController(title: "Create Account", message: "Create an account to manage your points online?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Sign In", style: UIAlertAction.Style.default, handler: {
                (alert :UIAlertAction) -> Void in

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ACCOUNTLOGIN") as! UINavigationController
                self.present(vc, animated: true)

            }))
            self.present(alert, animated: true, completion: nil)

        }
        else {
            let email = UserManager.sharedInstance.getUserDetails().email
            let alert = UIAlertController(title: "Switch Accounts", message: "Sign out of your account (\(email)) and switch accounts", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.default, handler: {
                (alert :UIAlertAction) -> Void in
                UserManager.sharedInstance.doResetAccount()
                self.viewWillAppear(false)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    @IBAction func doTrainButton(_ sender: Any) {
    }
    @IBAction func doPlayButton(_ sender: Any) {
        UserManager.sharedInstance.updatePointsTotal(100)
    }
    @IBAction func doPayoutButton(_ sender: Any) {
//        UserManager.sharedInstance.doResetAccount()
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var trainingButtonView: MFTrainingButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let points = 1234
        self.pointsLabel.text = "\(points)"

        if let placeholderFont = UIFont(name: "Impact", size: 42) {
            let strokeTextAttributes = [
                NSAttributedString.Key.strokeColor : UIColor.white,
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.strokeWidth : -6.0,
                NSAttributedString.Key.kern: -2.0,
                NSAttributedString.Key.font : placeholderFont]
                as [NSAttributedString.Key : Any]
            
            titleLabel.attributedText = NSMutableAttributedString(string: "Feed  The  Bot", attributes: strokeTextAttributes)
        }
        
        setupStatButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Adjust menu
        trainingButtonView.reset()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // Check user authorization, show sign in screen
        if !UserManager.sharedInstance.isUserLoggedIn() {
            DEBUG_LOG("anonymous_auth", details: "home view login")
            UserManager.sharedInstance.doAnonymousLogin()
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "ACCOUNTLOGIN") as! UINavigationController
//            self.present(vc, animated: true)
        }

        UserManager.sharedInstance.refreshUserData { (error) in
            if (error == nil) {
                DispatchQueue.main.async {
                    let points = UserManager.sharedInstance.getUserTotalPoints()
                    self.pointsLabel.text = "\(points)"
                    
                }
            }
        }
    }

    func showTrainingController(_ identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as! UINavigationController
        self.present(vc, animated: true) {
            //            print("Show login...")
        }
        
    }
    
    func setupStatButtons() {
        
        var buttons = [MFTrainButton]()
        
//        let buttonShot = MFTrainButton(title: .TEXT, icon: "icon_text")
//        buttonShot.completionHandler = { (sender) in
//            print(sender)
//            self.showTrainingController("TEXTTRAINING")
//        }
//        buttons.append(buttonShot)
        
        let buttonTurnover = MFTrainButton(title: .CLASSIFICATION, icon: "icon_classify")
        buttonTurnover.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("CATEGORYTRAINING")
        }
        buttons.append(buttonTurnover)
        
        let buttonSentiment = MFTrainButton(title: .SENTIMENT, icon: "icon_text")
        buttonSentiment.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("SENTIMENTTRAINING")
        }
        buttons.append(buttonSentiment)
        
        let buttonCorner = MFTrainButton(title: .BOUNDINGBOX, icon: "icon_bounding")
        buttonCorner.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("BBOXTRAINING")
        }
        buttons.append(buttonCorner)
        
        let buttonGoal = MFTrainButton(title: .POLYGONLABEL, icon: "icon_polygon")
        buttonGoal.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("POLYTRAINING")
        }
        buttons.append(buttonGoal)
        
//        let buttonOff = MFTrainButton(title: "PIXEL By PIXEL", icon: "icon_pixelwise")
//        buttonOff.completionHandler = { (sender) in
//            print(sender)
//            self.showTrainingController("TEXTTRAINING")
//        }
//        buttons.append(buttonOff)

        trainingButtonView.menuButtons = buttons
        
    }


}

// MARK: -  Custom Login View

class CustomAuthViewController: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        let w = UIScreen.main.bounds.size.width
        let offX = (w - 200.0) * 0.5
        var offY = CGFloat(160.0)
        let logoView = UIImageView(frame: CGRect(x: offX, y: offY, width: 200, height: 200))
        logoView.image = UIImage(named: "bot_small_white")
        view.insertSubview(logoView, at: 1)
        
        offY = offY + 200 + 80
        let welcomeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: w * 0.75, height: 88))
        welcomeLabel.center = CGPoint(x: w * 0.5, y: offY)
        welcomeLabel.text = "Welcome to FeedTheBot!\nPlease sign in or create an account to continue."
        welcomeLabel.textAlignment = .center
        welcomeLabel.numberOfLines = 3
        welcomeLabel.textColor = .gray
        view.insertSubview(welcomeLabel, at: 1)
    }
    
}

extension ViewController : FUIAuthDelegate {
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return CustomAuthViewController(authUI: authUI)
        
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // handle user (`authDataResult.user`) and error as necessary
        if authDataResult != nil {
            UserManager.sharedInstance.updateUserDetails(userObj: authDataResult!.user)
            let detail = UserManager.sharedInstance.getUserDetails()
            DEBUG_USER(name: detail.name, email: detail.email)
        }
    }
    
}
