//
//  BBoxViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/17/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class BBoxViewController: UIViewController, UIScrollViewDelegate {
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func doSkipButton(_ sender: Any) {
        doSaveTrainingEvent("")
    }
    
    @IBAction func doTrainAddButton(_ sender: Any) {
    }
    @IBAction func doTrainRemoveButton(_ sender: Any) {
    }
    @IBAction func doTrainDoneButton(_ sender: Any) {
        doSaveTrainingEvent("")
    }
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var trainingImage: BoundingBoxView!

    @IBOutlet weak var trainAddButton: UIButton!
    @IBOutlet weak var trainRemoveButton: UIButton!
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
        
        if (dataSetObj == nil) {
            dataSetObj = DataSetManager.sharedInstance.demoDataSet("Text OCR")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    // MARK: ScrollView methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return trainingImage
    }
    
    // MARK: Dataset methods
    
    func doPreloadDataSet() {
        guard let data = dataSetObj else { return }
        
        pointsLabel.text = "\(data.points)"
    }
    
    func doLoadDataSet() {
        guard let data = dataSetObj else { return }
        
        pointsLabel.text = "\(data.points)"
        trainingCount = 0
        progressLabel.text = "\(trainingCount)/\(data.eventCount)"
        
        responseStrings = [String].init(repeating: "", count: data.eventCount)
        
        gameTimeSeconds = data.limitSeconds
        let prompt = "You have \(gameTimeSeconds/60) minutes"
        timeLabel.text = "00:00"
        updateTimerLabel()
        
        let alert = MFAlertTrainView(title: "Text Recognition",
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
    
    
    
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension BBoxViewController : BoundingBoxViewDelegate {
    
    func didFinishTouch(_ positionX: Float, positionY: Float) {
        print("didFinishTouch", positionX, positionY)
        
    }
}

// BoundingBoxView
// MARK: - BoundingBoxView
// Subclass of UIViewImage which tracks a users touches to draw a bounding box around
// relative points on the underlying image

/*
    BoundingBox UIImageView subclass tracks creation, deletion and update of multiple
    polygons superimposed on an UIImage, used for identifying points of interest in the underlying
    image.
 
    polyArray - an array of identified polygons, ordered list of verticies (>= 4) and category
 
    category - a category type and corresponding color
 
 Processes :
 
    1) Create -
        a) Respond to tap down (confirm tap is not update request, not within existing polygon / handle)
        b) Add CAShapeLayer (anchor) at tap point
        c) Wait for additional tap down
        d1) If creating a rectangle, add a second CAShapeLayer (anchor) and a colored polygon (rectangle)
        d2) If creating a polygon, add a second CAShapeLayer (anchor) and go to (c)
        e) Finalize polygon
        e1) If creating a rectangle, finalize creation if a user presses a third time
        e2) If creating a polygon, finaize creation if a user pressed the "Add (+)" key
 
    2) Update -
        a) User can drag an existing anchor (un-finalized creation)
        b) Selecting an existing polygon will "activate" that polygon (ie., show anchor points)
        c) Dragging (panning) an existing anhor updates the polygon in realtime
 
    3) Delete -
        a) User presses the "Delete (X)" key
        b) Active polygon and anchor points are deleted
 
 */

protocol BoundingBoxViewDelegate {
    //    func didFinishTouch(distance :Float, angle :Float)
    func didFinishTouch(_ positionX: Float, positionY: Float)
}

enum BoundingBoxShotType {
    case none, mark, goal, allowed, miss, block
    
    func fillColor() -> CGColor {
        switch self {
        case .none :
            return UIColor.clear.cgColor
        case .mark :
            return MFDarkBlue().cgColor
        case .goal :
            return UIColor.green.cgColor
        case .allowed :
            return UIColor.red.cgColor
        case .miss :
            return UIColor.yellow.cgColor
        case .block :
            return UIColor.darkGray.cgColor
        default :
            return UIColor.lightGray.cgColor
        }
    }
    
    func strokeColor() -> CGColor {
        switch self {
        case .none :
            return UIColor.clear.cgColor
        case .mark :
            return UIColor.black.cgColor
        case .goal :
            return UIColor.darkGray.cgColor
        case .allowed :
            return UIColor.darkGray.cgColor
        case .miss :
            return UIColor.lightGray.cgColor
        case .block :
            return UIColor.black.cgColor
        default :
            return UIColor.lightGray.cgColor
        }
    }
}

enum BoundingBoxState {
    case quescient, first_tap, add_tap, finalize, update, delete
}

struct BoundingBoxPoly {
    var category : BoundingBoxShotType = .none
    var points : [CGPoint]? = nil
    var anchorLayers : [CALayer?]? = nil
    var polyLayer : CALayer? = nil
}

class BoundingBoxView : UIImageView {
    var drawState : BoundingBoxState = .quescient
    var polyArray = [BoundingBoxPoly]()
    var tapStart : CGPoint? = nil
    var dragStart : CGPoint? = nil
    var locInView : CGPoint? = nil
    var activePoly : BoundingBoxPoly? = nil
    var delegate : BoundingBoxViewDelegate? = nil
    
    var tapType : BoundingBoxShotType! = BoundingBoxShotType.mark {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BoundingBoxView.handleTap(_:))))
        
//        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BoundingBoxView.handlePan(_:))))

    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        self.isUserInteractionEnabled = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BoundingBoxView.handleTap(_:))))

//        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BoundingBoxView.handlePan(_:))))

    }

    @objc func handlePan(_ sender:UITapGestureRecognizer!) {
        if sender.state == UIGestureRecognizer.State.began {
            let point = sender.location(in: self)

            print("handlePan: start", point)
        }
    }
    
    @objc func handleTap(_ sender:UITapGestureRecognizer!) {
        if sender.state == UIGestureRecognizer.State.ended {
            
            // Testing hit points
            let point = sender.location(in: self)

            if let layer = self.layer.hitTest(point) as? CAShapeLayer { // Check for Shapelayer
                if let sublayers = self.layer.sublayers as? [CAShapeLayer] {
                    for sub in sublayers {
//                        if let path = layer.path, path.contains(point) {
                        if sub == layer {
                            print("handleTap: ended", point, layer)
                        }
                    }
                }
            }
            
            // Add new polygon
            if drawState == .quescient {
                drawState = .first_tap
                
                updatePolygon(point)
            }
            else if drawState == .add_tap {
                // Assume rectangles
                if let active = activePoly, let points = active.points, points.count == 2 {
                    updatePolyArray(active)
                    drawPolyArray()
                    // remote previous anchors?
                    drawState = .first_tap
                }
                updatePolygon(point)
            }

        }
    }
    
    func updatePolygon(_ point:CGPoint) {
        if drawState == .first_tap {
            drawState = .add_tap
            
            // Initalize new activePoly
            activePoly = BoundingBoxPoly()
            activePoly?.category = tapType
            activePoly?.points = [CGPoint]()
            activePoly?.points?.append(point)
            activePoly?.anchorLayers = [CALayer?]()
            activePoly?.anchorLayers?.append(nil)
        }
        else if drawState == .add_tap {
            guard activePoly != nil else { return }
            
            // Add new anchor point
            activePoly!.points?.append(point)
            activePoly!.anchorLayers?.append(nil)

            // Assumes rectangles
            if activePoly!.points!.count == 2 {
                drawPoly(activePoly!)
            }
        }
        
        drawActivePoly()
        
    }

    func updatePolyArray(_ poly:BoundingBoxPoly) {
        // Add active polygon to polyArray
        polyArray.append(poly)
        
    }
    
    func drawActivePoly() {
        guard var poly = activePoly, poly.points != nil else { return }
        
        for (i,point) in poly.points!.enumerated() {
            let nativeScreenW = UIScreen.main.nativeBounds.size.width
            let radii_scale :CGFloat = nativeScreenW < 1400.0 ? 0.04 : 0.04
            
            let radii = self.frame.size.height * radii_scale
            let xOff = point.x - radii*0.5
            let yOff = point.y - radii*0.5
            _ = CGRect(x: xOff, y: yOff, width: radii, height: radii)
            
            let markShape = CAShapeLayer()
            markShape.contentsScale = UIScreen.main.scale
            markShape.frame = CGRect(x: xOff, y: yOff, width: radii, height: radii)
            
            let roundRect = CGRect(x: 0.0, y: 0.0, width: radii, height: radii)
            markShape.path = UIBezierPath(roundedRect: roundRect, cornerRadius: radii).cgPath
            markShape.fillColor = self.tapType.fillColor()
            markShape.strokeColor = self.tapType.strokeColor()
            markShape.lineWidth = 1.5
            
            // Remove older layer, save and draw new one
            if poly.anchorLayers != nil && poly.anchorLayers!.count < i {
                let existingLayer = poly.anchorLayers![i]
                existingLayer?.removeFromSuperlayer()
                poly.anchorLayers![i] = markShape
            }
            
            self.layer.insertSublayer(markShape, at: 3)
        }
        
    }
    
    func drawPolyArray() {
        guard polyArray.count > 0 else { return }
    
        for poly in polyArray {
            drawPoly(poly)
        }
    }
    
    func drawPoly(_ poly:BoundingBoxPoly) {
        // Assume rectangles
        guard let points = poly.points, points.count >= 2 else { return }
        
        let start = points[0]
        let end = points[1]
        let w = end.x-start.x
        let h = end.y-start.y
        
        let polyShape = CAShapeLayer()
        polyShape.contentsScale = UIScreen.main.scale
        polyShape.frame = CGRect(x: start.x, y: start.y, width: w, height: h)
        
        let roundRect = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        polyShape.path = UIBezierPath(roundedRect: roundRect, cornerRadius: 8.0).cgPath
        polyShape.fillColor = poly.category.fillColor()
        polyShape.strokeColor = poly.category.strokeColor()
        polyShape.lineWidth = 2.5
        self.layer.insertSublayer(polyShape, at: 1)

    }
    
    func testDouble(_ sender:UITapGestureRecognizer!) {
        // Recieved a tap, mark the origin and check for two consecuitive taps in the same region
        let doubleClick :Bool = UserManager.sharedInstance.shouldDoubleTapToSelect()
        if doubleClick {
            if self.tapStart != nil {
                // compare first tap to current tap location
                let newTapPoint = sender.location(in: self)
                let xDist = newTapPoint.x - self.tapStart!.x
                let yDist = newTapPoint.y - self.tapStart!.y
                let distance = sqrt((xDist * xDist) + (yDist * yDist))
                if distance < self.frame.size.height * 0.05 {
                    // Second tap was on top of first tap, show shot mark
                    self.tapType = BoundingBoxShotType.mark
                    self.setNeedsLayout()
                    if self.delegate != nil {
                        let shotVector = self.calcLocationPosition()
                        self.delegate?.didFinishTouch(shotVector.horizontal, positionY: shotVector.vertical)
                    }
                }
                else {
                    self.tapStart = sender.location(in: self)
                    self.tapType = BoundingBoxShotType.mark
                    self.setNeedsLayout()
                    
                }
                
            }
            else {
                // Record first tap
                self.tapStart = sender.location(in: self)
                self.tapType = BoundingBoxShotType.mark
                self.setNeedsLayout()
                
            }
        }
        else {
            // Single click
            self.tapStart = sender.location(in: self)
            self.tapType = BoundingBoxShotType.mark
            self.setNeedsLayout()
            if self.delegate != nil {
                let shotVector = self.calcLocationPosition()
                self.delegate?.didFinishTouch(shotVector.horizontal, positionY: shotVector.vertical)
            }
            
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutMarkLayer()
        layoutTitleLayer()
        
    }
    
    fileprivate var markLayer: CALayer?
    fileprivate func layoutMarkLayer() {
        if let existingLayer = markLayer {
            // Testing
//            existingLayer.removeFromSuperlayer()
        }
        
        if self.tapStart != nil {
            let nativeScreenW = UIScreen.main.nativeBounds.size.width
            let radii_scale :CGFloat = nativeScreenW < 1400.0 ? 0.04 : 0.04
            
            let radii = self.frame.size.height * radii_scale
            let xOff = self.tapStart!.x - radii*0.5
            let yOff = self.tapStart!.y - radii*0.5
            _ = CGRect(x: xOff, y: yOff, width: radii, height: radii)
            
            let markShape = CAShapeLayer()
            markShape.contentsScale = UIScreen.main.scale
            markShape.frame = CGRect(x: xOff, y: yOff, width: radii, height: radii)
            
            let roundRect = CGRect(x: 0.0, y: 0.0, width: radii, height: radii)
            markShape.path = UIBezierPath(roundedRect: roundRect, cornerRadius: radii).cgPath
            markShape.fillColor = self.tapType.fillColor()
            markShape.strokeColor = self.tapType.strokeColor()
            markShape.lineWidth = 0.5
            self.layer.insertSublayer(markShape, at: 3)
            self.markLayer = markShape
        }
        
    }
    fileprivate var goalLayer: CALayer?
    fileprivate func layoutGoalLayer() {
        if let existingLayer = goalLayer {
            existingLayer.removeFromSuperlayer()
        }
        let radii = self.frame.size.height * 0.12
        let xOff = self.frame.size.width * 0.145
        let yOff = self.frame.size.height * 0.5 - radii*0.5
        let frameRect = CGRect(x: xOff, y: yOff, width: radii, height: radii)
        
        if self.locInView != nil && frameRect.contains(self.locInView!) {
            let goalShape = CAShapeLayer()
            goalShape.contentsScale = UIScreen.main.scale
            goalShape.frame = CGRect(x: xOff, y: yOff, width: radii, height: radii)
            
            let roundRect = CGRect(x: 0.0, y: 0.0, width: radii, height: radii)
            goalShape.path = UIBezierPath(roundedRect: roundRect, cornerRadius: radii).cgPath
            goalShape.fillColor = UIColor.green.cgColor
            goalShape.strokeColor = UIColor.black.cgColor
            goalShape.lineWidth = 0.5
            self.layer.insertSublayer(goalShape, at: 3)
            self.goalLayer = goalShape
        }
        
    }
    
    fileprivate func calcLocationPosition() -> (horizontal: Float, vertical: Float) {
        let xMax = self.frame.size.width
        let yMax = self.frame.size.height
        
        var xDist :Float = 0.0
        var yDist :Float = 0.0
        
        if self.tapStart != nil {
            xDist = xMax != 0.0 ? Float(self.tapStart!.x / xMax) : 0.0
            yDist = yMax != 0.0 ? 1.0 - Float(self.tapStart!.y / yMax) : 0.0
            
        }
        
        return (xDist, yDist)
    }
    
    fileprivate var markerLayer: CALayer?
    func addMarker(_ type: BoundingBoxShotType, positionX: Float, positionY: Float) {
        if self.markerLayer == nil {
            self.markerLayer = CALayer()
            self.layer.insertSublayer(self.markerLayer!, at: 0)
        }
        let nativeScreenW = UIScreen.main.nativeBounds.size.width
        let radii_scale :CGFloat = nativeScreenW < 1400.0 ? 0.06 : 0.04
        
        let radii = self.frame.size.height * radii_scale
        let xMax = nativeScreenW / UIScreen.main.scale   //self.frame.size.width
        let yMax = self.frame.size.height
        
        
        let x = xMax * CGFloat(0.9 * positionX)
        let y = yMax * CGFloat(1.0 - positionY) - radii * 0.5
        
        let markShape = CAShapeLayer()
        markShape.contentsScale = UIScreen.main.scale
        markShape.frame = CGRect(x: x, y: y, width: radii, height: radii)
        
        let roundRect = CGRect(x: 0.0, y: 0.0, width: radii, height: radii)
        markShape.path = UIBezierPath(roundedRect: roundRect, cornerRadius: radii).cgPath
        markShape.fillColor = type.fillColor()
        markShape.strokeColor = type.strokeColor()
        markShape.lineWidth = 0.5
        
        self.markerLayer?.insertSublayer(markShape, at: 1)
        
    }
    func removeAllMarkers() {
        self.markerLayer?.removeFromSuperlayer()
    }
    
    
    fileprivate var textLayer: CATextLayer?
    fileprivate func layoutTitleLayer() {
        if let existingLayer = textLayer {
            existingLayer.removeFromSuperlayer()
        }
        let doubleClick :Bool = UserManager.sharedInstance.shouldDoubleTapToSelect()
        if doubleClick && self.tapStart != nil {
//            let labelText = CATextLayer()
//            labelText.contentsScale = UIScreen.main.scale
//            let w = self.frame.size.width
//            let h = self.frame.size.height
//            let yOff = h*0.1
//            let xOff = w*0.5 - 45.0
//            labelText.frame = CGRect(x: xOff, y: yOff, width: 90.0, height: 12)
//            labelText.string = "Tap Twice to Save"
//            labelText.fontSize = 11.0
//            labelText.font = CTFontCreateWithName("ArialMT" as CFString, 12, nil)
//            labelText.alignmentMode = CATextLayerAlignmentMode.center
//            labelText.foregroundColor = UIColor.lightGray.cgColor
//            self.layer.insertSublayer(labelText, at: 2)
//            self.textLayer = labelText
        }
    }
    
    
}

