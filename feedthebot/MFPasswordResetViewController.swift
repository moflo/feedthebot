//
//  MFPasswordResetViewController.swift
//  fieldforcebeta
//
//  Created by d. nye on 4/20/16.
//  Copyright © 2016 Mobile Flow LLC. All rights reserved.
//

import UIKit

class MFPasswordResetViewController: UIViewController {
    
    @IBOutlet weak var email: MFSignupTextField!
    @IBAction func doSendButton(_ sender: AnyObject) {
        self.email.resignFirstResponder()
        
        if self.checkFieldValid() {
            
            MFProgressHUD.sharedView.wait("Reset Password…", detail: "Contacting server")

            UserManager.sharedInstance.doAccountPasswordReminder(self.email.text!, completionHandler: { (error) -> () in
                
                // Dismiss dialog or show error
                MFProgressHUD.sharedView.hide()

                if error == nil {
                    MFAlertView(title: "Password Reset", message: "Please check your email for instructions.", cancelPrompt: "Got It", completionHandler: { (buttonIndex) -> () in
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    }).show()
                }
                else {
                    MFAlertView(title: "Ooops...", message: "Error trying to reset password.", cancelPrompt: "Sorry", completionHandler: nil).show()
                }
                
            })
        }
        else {
            MFAlertView(title: "Ooops...", message: "Need to enter an email address.", cancelPrompt: "Got It", completionHandler: nil).show()
            
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController!.isNavigationBarHidden = false
        
        // Adjust nav bar items
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkFieldValid() -> Bool {
        // Method to check whether the text fields are valid (non-empty)
        var count_chars = 1
        for textInput :UITextField in self.orderedInputFields() {
            count_chars = count_chars * textInput.text!.count
        }
        return count_chars > 0
        
    }

    // Method to list of TextFields and TextViews, in order, that can be tabbed to
    func orderedInputFields() -> [MFSignupTextField] {
        return [ email ]
    }
    


}
