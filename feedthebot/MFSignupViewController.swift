//
//  MFSignupViewController.swift
//  fieldforcebeta
//
//  Created by d. nye on 4/20/16.
//  Copyright © 2016 Mobile Flow LLC. All rights reserved.
//

import UIKit

class MFSignupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    
    @IBOutlet weak var loginButton: MFRoundedButton!
    @IBAction func doLoginButton(_ sender: AnyObject) {
        
        self.doDismissKeyboard()
        
        if self.checkFieldValid() {
            MFProgressHUD.sharedView.show("Logging In", detail: "Please wait…")
            MFProgressHUD.sharedView.progress = 0.33
            
            let user = self.emailText.text
            let pass = self.passwordText.text
            
            UserManager.sharedInstance.doAccountLogin(user!, password: pass!, completionHandler: {
                (user, error) in
                
                MFProgressHUD.sharedView.progress = 1.0
                MFProgressHUD.sharedView.hide()

                if error == nil {
                    MFAlertView(title: "Success!", message: "We'll set up your account.", cancelPrompt: "Let's Go", completionHandler: { (buttonIndex) -> () in
                        self.dismiss(animated: true, completion: nil)
                        
                    }).show()
                }
                else {
                    MFAlertView(title: "Ooops...", message: "Error trying to log in.", cancelPrompt: "Sorry", completionHandler: nil).show()
                }

                
            })
            
        }
        else {
            
            MFAlertView(title: "Sorry...", message: "Enter valid email and password…", cancelPrompt: "Got it", completionHandler: nil).show()

            
        }
        
        
        
    }
    
    @IBOutlet weak var layoutEmailHeight: NSLayoutConstraint!
    @IBOutlet weak var layoutLogoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var passResetButton: UIButton!
    @IBOutlet weak var passUnderline: UIView!
    
    @IBOutlet weak var emailText: MFSignupTextField!
    @IBOutlet weak var passwordText: MFSignupTextField!
    @IBAction func doBeginEdit(_ sender: AnyObject) {
        print("doSearchBeginEdit")
        
        if !self.isKeyboardShown {
            self.isKeyboardShown = true
            self.doAnimateTextViews()
        }
    }
    @IBAction func doTextDidEnd(_ sender: AnyObject) {
        print("doSearchTextDidEnd")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailText {
            self.passwordText.becomeFirstResponder()
        }
        if textField == self.passwordText {
            self.doDismissKeyboard()
        }
        return true
    }
    
    func checkFieldValid() -> Bool {
        // Method to check whether the text fields are valid (non-empty)
        let len1 = self.emailText.text!.count
        let len2 = self.passwordText.text!.count
        return len1>0 && len2>0
    }
    
    
    
    var isKeyboardShown :Bool = false
    func doDismissKeyboard() {
        self.emailText.resignFirstResponder()
        self.passwordText.resignFirstResponder()
        self.isKeyboardShown = false
        self.doAnimateTextViews()
        
    }
    
    let CONST_LOGO_INITIAL = CGFloat(130)
    let CONST_LOGO_MIN = CGFloat(54)
    let CONST_EMAIL_INITIAL = CGFloat(60)
    let CONST_EMAIL_MIN = CGFloat(30)
    
    func doAnimateTextViews() {
        // Method to animate the showing / hiding of the textFields
        
        if self.isKeyboardShown {
            
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                // Step 1. Fade label
//                self.bodyLabel.alpha = 0.0
                
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.15, animations: { () -> Void in
                        // Step 2. Move fields & buttons
                        self.layoutEmailHeight?.constant = self.CONST_LOGO_MIN
                        self.layoutLogoHeight?.constant = self.CONST_EMAIL_MIN
                        self.view.layoutIfNeeded()
                        
                        }, completion: { (completed) -> Void in
                            // Done.
                    })
            })
            
        }
        else {
            
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                // Step 1. Move fields & buttons
                self.layoutEmailHeight?.constant = self.CONST_LOGO_INITIAL
                self.layoutLogoHeight?.constant = self.CONST_EMAIL_INITIAL
                self.view.layoutIfNeeded()
                
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.01, animations: { () -> Void in
                        // Step 2. Fade label
//                        self.bodyLabel.alpha = 1.0
                        
                        }, completion: { (completed) -> Void in
                            // Done.
                            
                    })
            })
            
        }
    }
    
    @IBAction func doPassResetButton(_ sender: AnyObject) {
        
    }
    
    @IBAction func doRegisterButton(_ sender: AnyObject) {


    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController!.isNavigationBarHidden = false
        
        self.layoutEmailHeight?.constant = self.CONST_LOGO_INITIAL
        self.layoutLogoHeight?.constant = self.CONST_EMAIL_INITIAL
        
        // Adjust nav bar items
        
        // Remove default backbutton
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationController.self])
        
        appearance.setBackButtonBackgroundImage(nil, for: UIControl.State(), barMetrics: .default)



    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.isNavigationBarHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.doDismissKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
