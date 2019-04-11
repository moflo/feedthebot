//
//  ViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func doTrainButton(_ sender: Any) {
    }
    @IBAction func doPlayButton(_ sender: Any) {
        UserManager.sharedInstance.updatePointsTotal(100)
    }
    @IBAction func doPayoutButton(_ sender: Any) {
        UserManager.sharedInstance.doResetAccount()
    }
    
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        UserManager.sharedInstance.refreshUserData { (error) in
            if (error == nil) {
                DispatchQueue.main.async {
                    let points = UserManager.sharedInstance.getUserTotalPoints()
                    self.pointsLabel.text = "+ \(points)"
                    
                }
            }
        }
    }


}

