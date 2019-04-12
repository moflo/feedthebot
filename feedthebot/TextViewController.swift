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
    @IBOutlet weak var trainTextV: NSLayoutConstraint!
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
    
    override var prefersStatusBarHidden : Bool {
        return true
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
        let scale = UIScreen.main.scale
        
        print("keyboardWillShow: ",frameH, keyboardH, scale)
        // -60px offset for toolbar...
//        animateToolbar(frameH-keyboardH-60.0)
        animateToolbar(keyboardH)

    }
    

    func animateToolbar(_ height: CGFloat) {
        UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
            
            print("animateToolbar: ",self.trainTextV?.constant ?? 0,height)
            
            // Animate underLine position
            self.trainTextV?.constant = -height
            self.view.layoutIfNeeded()

            
        }, completion: { (done) -> Void in
            // Set underLine width
            
        })

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
