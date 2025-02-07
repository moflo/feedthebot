//
//  SetimentViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/17/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class SentimentViewController: UIViewController {
    @IBAction func doSettingsButton(_ sender: Any) {
        let alert = MFAlertTrainView(title: "Text Sentiment",
                                     icon: "",
                                     info: "Identify the sentiment category of the text by selecting the button below. Press check (√) to confirm.",
                                     prompt: "Check some text!") { (category, buttonIndex) in
                                        
                                        
        }
        alert.show()
    }
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func doSkipButton(_ sender: Any) {
//        doSaveTrainingEvent("")
        doSettingsButton(sender)
    }
    
    @IBAction func doTrainSkipButton(_ sender: Any) {
        doSaveTrainingEvent("")
    }
    @IBAction func doTrainDoneButton(_ sender: Any) {
        let category = categoryLabel.text ?? ""
        doSaveTrainingEvent(category)
        
        UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
            
            self.categoryLabel.isHidden = true
            self.trainDoneButton.isEnabled = false
            self.trainingButtonView.reset()
            
        }, completion: { (done) -> Void in
            // Set underLine width
            
        })
        
    }
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var categoryLabel: MFFormTextField1!
    @IBOutlet weak var trainingButtonView: MFTrainingButtonView!
    @IBOutlet weak var trainDoneButton: UIButton!
    
    var dataSetObj :MFDataSet? = nil
    var trainingCount :Int = 0
    var gameTimer : Timer? = nil
    var gameTimeSeconds : Int = 0
    
    var responseStrings: [String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        categoryLabel.isEnabled = false
        categoryLabel.isHidden = true
        trainDoneButton.isEnabled = false
        
        // Load the latest Dataset
        DataSetManager.sharedInstance.loadPage(type: .textSentiment, page: 1) { (datasets, error) in
            if error == nil && datasets != nil && datasets!.count > 0 {
                self.dataSetObj = datasets!.first
            }
            else {
                self.dataSetObj = DataSetManager.sharedInstance.demoDataSet(.textSentiment)
            }
            
            DispatchQueue.main.async {
                self.doPreloadDataSet()
                self.doLoadDataSet()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        doPreloadDataSet()
        
//        setupStatButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        doLoadDataSet()
        
        // Adjust menu
        trainingButtonView.reset()
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
        textView.text = "Loading..."
        
        setupStatButtons()
    }
    
    func doLoadDataSet() {
        guard let data = dataSetObj else { return }
        
        pointsLabel.text = "\(data.points)"
        trainingCount = 0
        progressLabel.text = "\(trainingCount)/\(data.eventCount)"
        
        if trainingCount < data.dataURLArray.count {
            let urlString = data.dataURLArray[trainingCount]
            textView.text = urlString
        }
        else {
            textView.text = "Thinking..."

        }
        textView.centerVertically()
        
        responseStrings = [String].init(repeating: "", count: data.eventCount)
        
        gameTimeSeconds = data.limitSeconds
        let prompt = "You have \(gameTimeSeconds/60) minutes"
        timeLabel.text = "00:00"
        updateTimerLabel()
        
        let alert = MFAlertTrainView(title: "Sentiment Analysis",
                                     icon: "",
                                     info: data.instruction,
                                     prompt: prompt) { (category, buttonIndex) in
                                        
                                        self.startGameTimer()
                                        
        }
        alert.show()
        
    }
    
    func doSaveTrainingEvent(_ text:String) {
        guard let data = dataSetObj else { return }
        guard responseStrings != nil else { return }
        guard responseStrings!.count <= data.eventCount else { return }
        
        responseStrings![trainingCount] = text
        
        trainingCount = trainingCount + 1
        
        DispatchQueue.main.async {
            self.progressLabel.text = "\(self.trainingCount)/\(data.eventCount)"
            if self.trainingCount < data.dataURLArray.count {
                let urlString = data.dataURLArray[self.trainingCount]
                self.textView.text = urlString
            }
            else {
                self.textView.text = "Thinking..."
                
            }
            self.textView.centerVertically()
        }
        
        // Check for game over
        if trainingCount >= data.eventCount {
            doEndGame()
        }
    }
    
    func doEndGame() {
        stopGameTimer()
        
        DataSetManager.sharedInstance.postTraining(dataSetObj,
                                                   duration:gameTimeSeconds,
                                                   categoryArray: responseStrings)

        let alert = MFAlertCompleteView(title: "Training Done") { (buttonIndex) in
            
            switch buttonIndex {
            case 0: self.doDoneButton(self)
                //            case 1:
            //            case 2:
            default :
                print("DoEndGame: ", buttonIndex)
            }
            self.doDoneButton(self)

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
    
    // MARK: Category button methods
    func showSelectedCateogory(_ identifier: String) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.33, delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
                
                self.categoryLabel.text = identifier
                self.categoryLabel.isHidden = false
                self.trainDoneButton.isEnabled = true
                
                
            }, completion: { (done) -> Void in
                // Set underLine width
                
            })
        }
    }
    
    func setupStatButtons() {
        
        var buttons = [MFTrainButton]()

        if let categoryArray = self.dataSetObj?.categoryArray {
            var catType = BoundingBoxShotType.mark
            
            for category in categoryArray {
                let buttonShot = MFTrainButton(title: category.uppercased(), icon: "icon_text", category: catType)
                buttonShot.completionHandler = { (sender) in
                    self.showSelectedCateogory(category)
                }
                buttons.append(buttonShot)
                
                catType = catType.next()
            }
        }
        else {
            let buttonCorner = MFTrainButton(title: "OPTION1", icon: "icon_text", category: .goal)
            buttonCorner.completionHandler = { (sender) in
                self.showSelectedCateogory("OPTION1")
            }
            buttons.append(buttonCorner)
        }

        trainingButtonView.menuType = .DarkBlue
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

extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
