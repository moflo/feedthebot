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
        
        let alert = MFAlertTrainView(title: "Bounding Box",
                                     icon: "",
                                     info: "Tap on the image to add the first point in a rectangle. Tap a second location to draw a box. You can change the box size by dragging the anchor points around.",
                                     prompt: "Add some boxes") { (category, buttonIndex) in
                                        
                                        
        }
        alert.show()

    }
    @IBAction func doTrainRemoveButton(_ sender: Any) {
        trainingImage.reset()
    }
    @IBAction func doTrainDoneButton(_ sender: Any) {
        let polyArray = trainingImage.resetAndGetPolyArray()
        if polyArray.count > 0 {
            print("PolyArray ", polyArray)
            doSaveTrainingEvent("")
        }
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
            return MFGreen().cgColor
        case .goal :
            return MFYellow().cgColor
        case .allowed :
            return MFRed().cgColor
        case .miss :
            return MFBlue().cgColor
        case .block :
            return UIColor.darkGray.cgColor
        }
    }
    
    func strokeColor() -> CGColor {
        switch self {
        case .none :
            return UIColor.clear.cgColor
        case .mark :
            return MFDarkBlue().cgColor
        case .goal :
            return UIColor.darkGray.cgColor
        case .allowed :
            return UIColor.darkGray.cgColor
        case .miss :
            return UIColor.lightGray.cgColor
        case .block :
            return UIColor.black.cgColor
        }
    }
    
    func polyColor() -> CGColor {
        switch self {
        case .none :
            return UIColor.clear.cgColor
        case .mark :
            return MFDarkBlue(0.3).cgColor
        case .goal :
            return UIColor.green.cgColor
        case .allowed :
            return UIColor.red.cgColor
        case .miss :
            return UIColor.yellow.cgColor
        case .block :
            return UIColor.darkGray.cgColor
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
        
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        self.isUserInteractionEnabled = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BoundingBoxView.handleTap(_:))))

    }
    
    // MARK: Data methods
    
    func resetAndGetPolyArray() -> [BoundingBoxPoly] {
        if let poly = activePoly { polyArray.append(poly) }
        let newArray = [BoundingBoxPoly].init(polyArray)
        reset()
        
        return newArray
    }
    
    func reset() {
        // Data reset
        polyArray.removeAll()
        activePoly = nil
        drawState = .quescient
        
        // UI reset
        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    func clearActive() {
        guard let poly = activePoly else { return }
        
        poly.polyLayer?.removeFromSuperlayer()
        poly.anchorLayers?.forEach { $0?.removeFromSuperlayer() }
        activePoly = nil
        
        drawState = .quescient
    }
    
    func undoAnchor() {
        guard let poly = activePoly, poly.points != nil, poly.points!.count > 0 else { return }

        poly.polyLayer?.removeFromSuperlayer()
        activePoly!.points?.removeLast()
        
        activePoly!.anchorLayers?.last??.removeFromSuperlayer()
        activePoly!.anchorLayers?.removeLast()
        
        // Redraw if points >= 2 (ie., rectangle and poly)
        if poly.points!.count >= 2 {
            activePoly!.polyLayer = drawPoly(poly)
        }
        
        drawState = (poly.points!.count == 1 ? .first_tap : .add_tap)
        
    }
    
    // MARK: UI Methods
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("TouchesMoved ",touches.first?.location(in: self) ?? "none")
        
        // Only check whether an anchor in the activePoly is being dragged
        guard let point = touches.first?.location(in: self),
                let poly = activePoly,
                let activeAnchors = poly.anchorLayers,
                let layer = self.layer.hitTest(point) as? CAShapeLayer else { return }
        
        for (i,anchor) in activeAnchors.enumerated() {
            if anchor == layer {
//                print("Touch Moved in Layer ", point, layer)
                // Update location of anchor
                activePoly!.polyLayer?.removeFromSuperlayer()
                activePoly!.anchorLayers?.forEach { $0?.removeFromSuperlayer() }
                activePoly!.points![i] = point
                drawActivePoly()
                activePoly!.polyLayer = drawPoly(activePoly!)
                
                drawState = .update
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("TouchesEnded ",touches.first?.location(in: self) ?? "none")
        
        drawState = .add_tap
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
//                            print("handleTap: ended", point, layer)
                            handleEditLayer(layer)
                            return
                        }
                    }
                }
            }
            
            // Add new polygon
            if drawState == .quescient {
                drawState = .first_tap
                
                updatePolygon(point)
                return
            }
            
            // Expand current polygon
            if drawState == .add_tap {
                // Assume rectangles
                if let active = activePoly, let points = active.points, points.count == 2 {
                    updatePolyArray(active)
                    drawPolyArray()
                    
                    // remote previous anchors
                    drawState = .first_tap
                }
                updatePolygon(point)
                return
            }

        }
    }
    
    func handleEditLayer(_ layer:CALayer) {
        // Search for layer within existing polygons
        var selectedPoly :BoundingBoxPoly? = nil
        var polyIndex :Int = -1
        for (i,poly) in polyArray.enumerated() {
            if poly.polyLayer == layer {
                selectedPoly = poly
                polyIndex = i
            }
        }
        
        if selectedPoly != nil {
            // Remove any existing activePoly
            if let poly = activePoly {
                poly.polyLayer?.removeFromSuperlayer()
                poly.anchorLayers?.forEach { $0?.removeFromSuperlayer() }
            }
            // Selected poly becomes the activePoly
            activePoly = selectedPoly
            drawActivePoly()

            // Enter into add_tap state, with activePoly not yet commited to polyArray...
            if polyIndex >= 0 { polyArray.remove(at: polyIndex) }
            drawState = .add_tap
            
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
        
        // Remove previous anchors
        if let anchorLayers = poly.anchorLayers {
            for layer in anchorLayers {
                layer?.removeFromSuperlayer()
            }
        }
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
            if poly.anchorLayers != nil && i < poly.anchorLayers!.count {
                let existingLayer = poly.anchorLayers![i]
                existingLayer?.removeFromSuperlayer()
                // Set global activePoly anchorLayer
                activePoly!.anchorLayers![i] = markShape
            }
            
            self.layer.insertSublayer(markShape, at: 3)
        }
        
    }
    
    func drawPolyArray() {
        guard polyArray.count > 0 else { return }
    
        for (i,poly) in polyArray.enumerated() {
            if let layer = drawPoly(poly) {
                polyArray[i].polyLayer = layer
            }
        }
    }
    
    func drawPoly(_ poly:BoundingBoxPoly) -> CALayer? {
        // Assume rectangles
        guard let points = poly.points, points.count >= 2 else { return nil }
        
        poly.polyLayer?.removeFromSuperlayer()

        let start = points[0]
        let end = points[1]
        let w = end.x-start.x
        let h = end.y-start.y
        
        let polyShape = CAShapeLayer()
        polyShape.contentsScale = UIScreen.main.scale
        polyShape.frame = CGRect(x: start.x, y: start.y, width: w, height: h)
        
        let roundRect = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        polyShape.path = UIBezierPath(roundedRect: roundRect, cornerRadius: 3.0).cgPath
        polyShape.fillColor = poly.category.polyColor()
        polyShape.strokeColor = poly.category.fillColor()
        polyShape.lineWidth = 2.5
        self.layer.insertSublayer(polyShape, at: 1)

        return polyShape
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        layoutMarkLayer()
        
    }
    
}

