//
//  TrainViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/9/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class TrainViewController: UIViewController {
    
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trainingButtonView: MFTrainingButtonView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStatButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Adjust menu
        trainingButtonView.reset()
        
    }

    func setupStatButtons() {
        
        var buttons = [MFTrainButton]()
        let buttonShot = MFTrainButton(title: "TEXT", icon: "icon_text")
        buttonShot.completionHandler = { (sender) in
            print(sender)
        }
        buttons.append(buttonShot)
        
        let buttonCorner = MFTrainButton(title: "BOUNDING BOX", icon: "icon_bounding")
        buttonCorner.completionHandler = { (sender) in
            print(sender)
        }
        buttons.append(buttonCorner)
        
        let buttonGoal = MFTrainButton(title: "POLYGON LABEL", icon: "icon_polygon")
        buttonGoal.completionHandler = { (sender) in
            print(sender)
        }
        buttons.append(buttonGoal)
        
        let buttonTurnover = MFTrainButton(title: "CLASSIFICATION", icon: "icon_classify")
        buttonTurnover.completionHandler = { (sender) in
            print(sender)
        }
        buttons.append(buttonTurnover)
        
        let buttonOff = MFTrainButton(title: "PIXEL By PIXEL", icon: "icon_pixelwise")
        buttonOff.completionHandler = { (sender) in
            print(sender)
        }
        buttons.append(buttonOff)
                
        
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

class MFTrainButton {
    
    var completionHandler:((AnyObject)->Void)!
    
    var title: String!
    var icon_name :String!
    
    init() {
        title = "Text"
        icon_name = "icon_text"
        completionHandler = nil
    }
    
    convenience init(title: String, icon: String) {
        self.init()
        self.title = title
        self.icon_name = icon
    }
    
}

class MFTrainingButtonView : UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView :UICollectionView!
    
    var menuButtons :[MFTrainButton]? = nil {
        didSet {
            self.awakeFromNib()
        }
    }
    
    override init(frame :CGRect)  {
        // Initialize the UIView
        super.init(frame : frame)
        
        self.awakeFromNib()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    override func awakeFromNib() {
        self.initialize()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.initialize()
        self.setNeedsDisplay()
    }
    
    func initialize() {
        //        print(self.bounds)
        
        self.backgroundColor = .clear
        
        // Add UICollectionView
        if self.collectionView != nil {
            self.collectionView.removeFromSuperview()
            self.collectionView = nil
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let rect       = self.bounds    // CGRect(x: 25.0, y: 85.0, width: self.bounds.width-50.0, height: 28.0 * 5)
        let width      = rect.width
        let height     = rect.height
        
        let itemWidth  = floor(width / 2)
//        let itemHeight = floor(height / 3)
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsSelection = true
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.register(MFTrainButtonCell.self, forCellWithReuseIdentifier: "MFTrainButtonCell")
        self.addSubview(self.collectionView)
        
        
        collectionView.contentOffset.x = bounds.width * 1.1
        
    }
    
    func reset() {
        // Scroll view into first posotion
        
        collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        
        //        self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
        //                                          at: .top,
        //                                          animated: true)
        
    }
    // UICollectionCell
    
    class MFTrainButtonCell: UICollectionViewCell {
        var title: UILabel!
        var icon: UIImageView!
        var btn: UIView!
        var enabled: Bool = true
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            title.text = ""
            title.textColor = UIColor.white
            icon.image = nil    // UIImage(named: "square_goal")
            self.contentView.backgroundColor = .green
        }
        
        func initialize() {
            //            print(self.bounds)
            
            self.isSelected = false
            
            let iconSize = CGFloat(64)
            
            btn = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width*0.9, height: bounds.width*0.9))
            btn.backgroundColor = .green
            
            let radius :CGFloat = 0.25 * btn.frame.size.height
            btn.layer.cornerRadius = radius
            //            btn.layer.masksToBounds = true
            btn.layer.shadowColor = UIColor.darkGray.cgColor
            
            btn.layer.shadowOffset = CGSize(width: 0.0,height: 3.0)
            
            btn.layer.shadowOpacity = 0.4
            btn.layer.shadowRadius = 3.0
            
            btn.center = self.contentView.center
            self.contentView.addSubview(btn)
            
            icon = UIImageView(frame: CGRect(x: iconSize*0.25, y: 0, width: iconSize, height: iconSize))
            //            icon.center = CGPoint(x: bounds.midX, y: bounds.midY - 12)
            icon.image = UIImage(named: "square_goal")
            btn.addSubview(icon)
            
            let fontSize = CGFloat(18.0)
            title = UILabel(frame: CGRect(x: 0, y: 0, width: btn.bounds.width, height: fontSize*1.2))
            title.textAlignment = .left
            title.numberOfLines = 1
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = UIFont(name: "HelveticaNeue", size: fontSize)
            title.textColor = .blue
            btn.addSubview(title)
            
            // Auto layout
            icon.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
            
            let views = [ "icon" : icon,  "title": title ] as [String : Any]
            
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            title.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            
            let constHbody = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=5)-[icon(\(iconSize))]-(>=5)-|", options: .alignAllCenterY, metrics: nil, views: views)
            self.addConstraints(constHbody)
            
            let constV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[icon(\(iconSize))]-(16)-[title(\(fontSize*1.2))]-(>=15)-|", options: .alignAllCenterX, metrics: nil, views: views)
            self.addConstraints(constV)

            // Add border
            //            self.layoutBorderLayer()
            
            
        }
        
        override var isSelected : Bool {
            didSet {
                //                self.backgroundColor = isSelected ? UIColor.lightGray : UIColor.white
                self.title?.textColor = isSelected ? UIColor.white : UIColor.lightGray
                
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            initialize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            initialize()
        }
        
        var borderLayer: CALayer?
        func layoutBorderLayer() {
            if let existingLayer = borderLayer {
                existingLayer.removeFromSuperlayer()
            }
            let border = CAShapeLayer()
            border.contentsScale = UIScreen.main.scale
            
            //        border.frame = bounds
            border.path = UIBezierPath(rect: bounds).cgPath
            border.lineWidth = 0.5
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = UIColor.darkGray.cgColor
            
            self.layer.insertSublayer(border, at: 1)
            self.borderLayer = border
            
        }
        
    }
    
    
    // UICollection View Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuButtons?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MFTrainButtonCell", for: indexPath) as! MFTrainButtonCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: MFTrainButtonCell, atIndexPath indexPath: IndexPath) {
        
        let item = (indexPath as NSIndexPath).item
        if let button = menuButtons?[item] {
            cell.title.text = button.title
            cell.icon.image = UIImage(named: button.icon_name)
        }
        else {
            cell.title.text = "Test Button"
            cell.icon.image = UIImage(named: "square_goal")
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! MFTrainButtonCell
        
        if cell.enabled {
            collectionView.selectItem(at: indexPath, animated:true, scrollPosition:.top)
        }
        //        else {
        //            self.selectDate(self.selectedDate)
        //        }
        
        return cell.enabled
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! MFTrainButtonCell
        
        if cell.enabled {
            
            let item = (indexPath as NSIndexPath).item
            if let button = menuButtons?[item] {
                if (button.completionHandler != nil) { button.completionHandler(self) }
            }
            else {
                print(item)
                
            }
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! MFTrainButtonCell
        
        if cell.enabled {
            
            let item = (indexPath as NSIndexPath).item
            
            print(item)
        }
        
    }
    
    
    
    
}
