//
//  ViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func doAccountButton(_ sender: Any) {
    }
    @IBAction func doSettingsButton(_ sender: Any) {
    }
    @IBAction func doTrainButton(_ sender: Any) {
    }
    @IBAction func doPlayButton(_ sender: Any) {
        UserManager.sharedInstance.updatePointsTotal(100)
    }
    @IBAction func doPayoutButton(_ sender: Any) {
        UserManager.sharedInstance.doResetAccount()
    }
    
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var trainingButtonView: MFTrainingButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let points = 1234
        self.pointsLabel.text = "\(points)"

        setupStatButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Adjust menu
        trainingButtonView.reset()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
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
        let buttonShot = MFTrainButton(title: "TEXT", icon: "icon_text")
        buttonShot.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("TEXTTRAINING")
        }
        buttons.append(buttonShot)
        
        let buttonTurnover = MFTrainButton(title: "CLASSIFICATION", icon: "icon_classify")
        buttonTurnover.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("CATEGORYTRAINING")
        }
        buttons.append(buttonTurnover)
        
        let buttonCorner = MFTrainButton(title: "BOUNDING BOX", icon: "icon_bounding")
        buttonCorner.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("TEXTTRAINING")
        }
        buttons.append(buttonCorner)
        
        let buttonGoal = MFTrainButton(title: "POLYGON LABEL", icon: "icon_polygon")
        buttonGoal.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("TEXTTRAINING")
        }
        buttons.append(buttonGoal)
        
        let buttonOff = MFTrainButton(title: "PIXEL By PIXEL", icon: "icon_pixelwise")
        buttonOff.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("TEXTTRAINING")
        }
        buttons.append(buttonOff)
        
        trainingButtonView.menuType = .DarkBlue
        trainingButtonView.menuButtons = buttons
        
    }


}

