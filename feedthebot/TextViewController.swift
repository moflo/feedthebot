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
    
    @IBAction func doTrainSkipButton(_ sender: Any) {
    }
    @IBAction func doTrainDoneButton(_ sender: Any) {
    }

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var trainTextField: MFFormTextField1!
    @IBOutlet weak var trainTextV: NSLayoutConstraint!
    
    var dataSetObj :MFDataSet? = nil
    var gameTimer : Timer? = nil
    var gameTimeSeconds : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (dataSetObj == nil) {
            dataSetObj = DataSetManager.sharedInstance.demoDataSet("Text OCR")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:
            UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        doPreloadDataSet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        doLoadDataSet()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        gameTimer?.invalidate()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Dataset methods
    
    func doPreloadDataSet() {
        guard let data = dataSetObj else { return }
        
        pointsLabel.text = "\(data.points)"
    }

    func doLoadDataSet() {
        guard let data = dataSetObj else { return }
        
        pointsLabel.text = "\(data.points)"
        progressLabel.text = "0/\(data.eventCount)"
        gameTimeSeconds = data.limitSeconds
        timeLabel.text = "00:00"
        updateTimerLabel()
        
        let alert = MFAlertTrainView(title: "Goal",
                                     icon: "",
                                     info: "This should be long texst which describes the type of training data.",
                                     prompt: "Call to Action") { (category, buttonIndex) in
                                        
            print("Completion: ",category, buttonIndex)
            self.startGameTimer()
                                        
        }
        alert.show()

    }
    
    // MARK: Timer methods
    
    func startGameTimer() {
        // Start the game timer
        if gameTimer == nil {
            let fireDate = Date()
            gameTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(self.timerCountdown),
                                             userInfo: fireDate,
                                             repeats: true)
            }
    }
    
    func stopGameTimer() {
        // Terminate game timer
        if (self.gameTimer?.isValid != nil) {
            self.gameTimer?.invalidate()
            self.gameTimer = nil
        }
    }
    
    func updateGameTime() {
        // Method to update the gameTimeSeconds using count down method, stop clock and advance period
        
        gameTimeSeconds -= 1
        
        if ( gameTimeSeconds <= 0 ) {
            gameTimeSeconds = 0
            stopGameTimer()
        }
    }
    
    func updateTimerLabel() {
        let minute = gameTimeSeconds / 60
        let second = gameTimeSeconds % 60
        
        let min = NSString(format:"%02d",minute)
        let sec = NSString(format:"%02d",second)
        
        let timeString = "\(min):\(sec)"
        
        timeLabel.text = timeString
    }
    
    @objc func timerCountdown() {
        // Method to update the UINavigationItem prompt with the elapsed time
        if (gameTimer?.isValid != nil) {

            updateGameTime()
            updateTimerLabel()
            
        }
    }
    
    
    // MARK: Keyboard View observers
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // Activate the second textField
        self.trainTextField.becomeFirstResponder()
        
        // Show the last text cell
        let info = (notification as NSNotification).userInfo
        
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
            self.trainTextV?.constant = height
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
