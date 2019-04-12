//
//  TextViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func doSkipButton(_ sender: Any) {
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trainTextField: MFFormTextField1!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:
            UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Keyboard View observers
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // Activate the second textField
        self.trainTextField.becomeFirstResponder()
        
        // Show the last text cell
        let info = (notification as NSNotification).userInfo as NSDictionary!
        
        let keyboardFrame = (info?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let frameH = self.view.frame.size.height
        let keyboardH = keyboardFrame.height
        
        // -60px offset for toolbar...
        print(frameH-keyboardH-60.0)
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
