//
//  CategoryViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/16/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryViewController: UIViewController, UIScrollViewDelegate {
    @IBAction func doSettingsButton(_ sender: Any) {
        let alert = MFAlertTrainView(title: "Image Category",
                                     icon: "",
                                     info: "Select the category of the image by pressing the buttons below. Press check (√) to confirm.",
                                     prompt: "Identify this photo!") { (category, buttonIndex) in
                                        
                                        
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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

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
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        categoryLabel.isEnabled = false
        categoryLabel.isHidden = true
        trainDoneButton.isEnabled = false
        
        if (dataSetObj == nil) {
            dataSetObj = DataSetManager.sharedInstance.demoDataSet("Text OCR")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        doPreloadDataSet()
        
        setupStatButtons()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        doLoadDataSet()

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
    
    // MARK: ScrollView methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }

    // MARK: Dataset methods
    
    func doPreloadDataSet() {
        guard let data = dataSetObj else { return }
        
        pointsLabel.text = "\(data.points)"

        if data.dataURLArray.count > 0 {
            let prefetcher = SDWebImagePrefetcher.shared
            let urlArray = data.dataURLArray.map { URL(string: $0) }
            let urls :[URL] = urlArray.compactMap { $0 }    // $0 as? URL
            prefetcher.cancelPrefetching()
            prefetcher.prefetchURLs( urls )
            
        }
        
        imageView.image = UIImage(named:"placeholder_image")
    }
    
    func doLoadDataSet() {
        guard let data = dataSetObj else { return }
        
        pointsLabel.text = "\(data.points)"
        trainingCount = 0
        progressLabel.text = "\(trainingCount)/\(data.eventCount)"
        
        if trainingCount < data.dataURLArray.count {
            let urlString = data.dataURLArray[trainingCount]
            if let url = URL(string: urlString) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named:"placeholder_image"))
            }
        }

        responseStrings = [String].init(repeating: "", count: data.eventCount)
        
        gameTimeSeconds = data.limitSeconds
        let prompt = "You have \(gameTimeSeconds/60) minutes"
        timeLabel.text = "00:00"
        updateTimerLabel()
        
        let alert = MFAlertTrainView(title: "Image Classification",
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
                self.imageView.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named:"placeholder_image"))
            }
            else {
                self.imageView.image = UIImage(named:"placeholder_image")
            }
        }
        
        // Check for game over
        if trainingCount >= data.eventCount {
            doEndGame()
        }
    }
    
    func doEndGame() {
        stopGameTimer()
        
        DataSetManager.sharedInstance.postTraining(dataSetObj)
        
        let alert = MFAlertCompleteView(title: "Training Done") { (buttonIndex) in
            
            switch buttonIndex {
            case 0: self.doDoneButton(self)
                //            case 1:
            //            case 2:
            default :
                print("DoEndGame: ", buttonIndex)
            }
            
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
        let buttonShot = MFTrainButton(title: "CATEGORY1", icon: "icon_text", category: .mark)
        buttonShot.completionHandler = { (sender) in
            self.showSelectedCateogory("CATEGORY ONE")
        }
        buttons.append(buttonShot)
        
        let buttonCorner = MFTrainButton(title: "CATEGORY2", icon: "icon_bounding", category: .goal)
        buttonCorner.completionHandler = { (sender) in
            self.showSelectedCateogory("CATEGORY TWO")
        }
        buttons.append(buttonCorner)

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
