//
//  CardViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/12/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit



class CardViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doPayoutButton(_ sender: Any) {
        if self.checkFieldValid() {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            self.dismissKeyboard()
        }

    }
    
    
    @IBOutlet weak var firstName: MFFormTextField1!
    @IBOutlet weak var lastName: MFFormTextField1!
    @IBOutlet weak var cardNumber: MFFormTextField1!
    @IBOutlet weak var expMonth: MFFormTextField1!
    @IBOutlet weak var expYear: MFFormTextField1!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    // MARK: - TextField methods
    
    func checkFieldValid() -> Bool {
        // Method to check whether the text fields are valid (non-empty)
        let len1 = self.firstName.text!.count
        let len2 = self.lastName.text!.count
        let len3 = self.cardNumber.text!.count
        let len4 = self.expMonth.text!.count
        let len5 = self.expYear.text!.count
        return len1+len2+len3+len4+len5 > 0
        
    }
    
    func dismissKeyboard() {
        // Method to dismiss all the keyboards
        self.view.endEditing(true)
    }
    
    // MARK: - TextField methods
    
    // Method to list of TextFields and TextViews, in order, that can be tabbed to
    func orderedInputFields() -> [MFFormTextField1] {
        return [ firstName, lastName, cardNumber, expMonth, expYear ]
    }
    
    // Method to set delegate for all input fields, run a viewDidLoad
    func setDelegateForInputFields() {
        for textInput :UITextField in self.orderedInputFields() {
            if textInput.isKind(of: UITextField.self) {
                textInput.delegate = self
                textInput.returnKeyType = .next
            }
        }
    }
    
    // Method to loop over ordered textfields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //! Move to next field, or dismiss keyboard
        
        let orderedFields :[UITextField] = self.orderedInputFields()
        
        if orderedFields.count == 0 {
            return true
        }
        
        let index = orderedFields.index(of: textField)
        
        if (index == NSNotFound) {
            return true
        }
        
        if (index == (orderedFields.count-1)) {
            // Last object, dismiss keyboard and call done method
            textField.resignFirstResponder()
            return true
        }
        
        if (index! < orderedFields.count) {
            let nextTextField = orderedFields[index!+1];
            if nextTextField.isKind(of: UITextField.self) {
                nextTextField.becomeFirstResponder()
            }
        }
        
        return true
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
