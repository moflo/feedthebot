//
//  TrainViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class TrainViewController: UIViewController {
    
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trainingButtonView: MFTrainingButtonView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStatButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Adjust menu
        trainingButtonView.reset()
        
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
        
        let buttonTurnover = MFTrainButton(title: "CLASSIFICATION", icon: "icon_classify")
        buttonTurnover.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("CATEGORYTRAINING")
        }
        buttons.append(buttonTurnover)
        
        let buttonOff = MFTrainButton(title: "PIXEL By PIXEL", icon: "icon_pixelwise")
        buttonOff.completionHandler = { (sender) in
            print(sender)
            self.showTrainingController("TEXTTRAINING")
        }
        buttons.append(buttonOff)
                
        
        trainingButtonView.menuButtons = buttons
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

