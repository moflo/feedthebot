//
//  MFAlerts.swift
//  feedthebot
//
//  Created by d. nye on 4/15/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class MFAlertTrainView: UIView {
    
    // Custom alert view globals
    var completionHandler :((_ category: String, _ buttonIndex :Int) -> ())!
    var showGradientBlur = true
    var backView :UIView!
    
    // Custom alert view methods
    
    convenience init(title: String, icon: String, info: String, prompt: String, completionHandler: @escaping (_ category: String, _ buttonIndex :Int) -> () ) {
        self.init(frame: CGRect.zero)
        
        self.completionHandler = completionHandler
        
        self.configure(title, icon:icon, info:info, prompt:prompt)
        
    }
    
    func configure(_ title: String, icon: String, info: String, prompt: String) {
        
        // Create & size the alert UIView based on the button & text settings
        var viewHeight :CGFloat = 280.0
        let viewWidth :CGFloat = 250.0
        
        let titleHeight :CGFloat = 35.0
        let textffset :CGFloat = 30.0 + titleHeight
        let buttonHeight :CGFloat = 40.0
        
//        viewHeight = titleHeight + switchHeight + scrollHeight - 24.0
        
        self.frame = CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewHeight)
        
        // Add title label
        let titleLabel = UILabel(frame: CGRect(x: 0.0, y: 10.0, width: viewWidth, height: titleHeight))
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        // Add Info view
        let textFrame = CGRect(x: 0.0, y: textffset, width: viewWidth, height: buttonHeight*3)
        let textField = UITextView(frame: textFrame)
        textField.text = info
        textField.isEditable = false
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.backgroundColor = .clear
        self.addSubview(textField)
        

        // Add Prompt view
        let promptFrame = CGRect(x: 0.0, y: viewHeight-(buttonHeight*2), width: viewWidth, height: buttonHeight)
        let promptField = UILabel(frame: promptFrame)
        promptField.text = prompt
        promptField.textAlignment = .center
        promptField.backgroundColor = .white
        self.addSubview(promptField)
        

        // Add Cancel button
        let buttonFrame = CGRect(x: 0.0, y: viewHeight-buttonHeight, width: viewWidth, height: buttonHeight)
        let cancelButton = MFAlertButton(frame: buttonFrame)
        cancelButton.setTitle("Start", for: UIControl.State())
        cancelButton.setTitle("Start", for: .highlighted)
        cancelButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)
        cancelButton.addTarget(self, action: #selector(self.doCancelButton(_:)), for: .touchUpInside)
        
        cancelButton.tag = 100
        self.addSubview(cancelButton)
        

        
        // Magic code to force a rounded rectangle mask on the layer...
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
        // Add border with 1.0 pixel width
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.shadowColor = UIColor.lightText.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 2.0
        
        self.backgroundColor = MFBlueStart()
        
        
        // Create backing view
        let window :UIWindow = UIApplication.shared.keyWindow!
        self.backView = UIView(frame: window.frame)
        self.backView.isUserInteractionEnabled = true
        if showGradientBlur {
            let gradient = CAGradientLayer()
            gradient.bounds = self.backView.bounds
            gradient.position = self.backView.center
            let gray1 = UIColor(r:103,g:115,b:134,a:0.8).cgColor
            let gray2 = UIColor(r:103,g:115,b:134,a:0.8).cgColor
            gradient.colors = [gray1,gray2]
            gradient.locations = [0.0,1.0]
            self.backView.layer.insertSublayer(gradient, at: 0)
        }
        else {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = backView.frame
            self.backView.addSubview(blurView)
        }
        
        
    }
    
    // MARK: Display methods
    
    func show() {
        // Method to display a previously initialized view
        if let window :UIWindow = UIApplication.shared.keyWindow {
            let center = window.center
            
            window.addSubview(self.backView)
            self.center = CGPoint(x: center.x, y: center.y-20)
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.alpha = 0.5
            window.addSubview(self)
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                // Step 1.
                self.backView.alpha = 1.0
            }, completion: { (finished) -> Void in
                // Step 2.
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    // Step 3.
                    self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.center = center
                    self.alpha = 1.0
                }, completion: { (finished) -> Void in
                    // Step 4.
                    UIView.animate(withDuration: 0.10, animations: { () -> Void in
                        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    })
                })
                
            })
        }
    }
    
    @objc func doOptionButton(_ sender :AnyObject) {
        // User selected an option
        let tag :Int = (sender as! UIButton).tag
        self.dismissView(tag)
    }
    
    @objc func doCancelButton(_ sender :AnyObject) {
        // User opted-out of the view
        self.dismissView(0)
    }
    
    func dismissView(_ buttonIndex :Int) {
        // Method to hide the view and background
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.backView.alpha = 0.5
            self.alpha = 0.2
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        }, completion: { (completed) -> Void in
            self.backView.removeFromSuperview()
            self.removeFromSuperview()
            
            // Remove subviews
            self.backView = nil
            
            if self.completionHandler != nil {
                self.completionHandler("", buttonIndex)
            }
        })
    }
    
    
    
}

// MARK: - MFAlertCompleteView

class MFAlertCompleteView: UIView {
    
    // Custom alert view globals
    var completionHandler :((_ buttonIndex :Int) -> ())!
    var showGradientBlur = true
    var backView :UIView!
    
    // Custom alert view methods
    
    convenience init(title: String, completionHandler: @escaping (_ buttonIndex :Int) -> () ) {
        self.init(frame: CGRect.zero)
        
        self.completionHandler = completionHandler
        
        self.configure(title)
        
    }
    
    func configure(_ title: String) {
        
        // Create & size the alert UIView based on the button & text settings
        var viewHeight :CGFloat = 350.0
        let viewWidth :CGFloat = 250.0
        
        let titleHeight :CGFloat = 35.0
        let nextOffset :CGFloat = 30.0 + titleHeight
        let buttonHeight :CGFloat = 40.0
        
        //        viewHeight = titleHeight + switchHeight + scrollHeight - 24.0
        
        self.frame = CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewHeight)
        
        // Add title label
        let titleLabel = UILabel(frame: CGRect(x: 10.0, y: 10.0, width: viewWidth-10.0, height: titleHeight))
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        // Add Next button
        let nextFrame = CGRect(x: 0.0, y: nextOffset, width: buttonHeight*4, height: buttonHeight*4)
        let nextButton = MFRectIconButton(frame: nextFrame)
        nextButton.configure("Next Set",icon:"icon_right_arrow",tag:100)
        nextButton.addTarget(self, action: #selector(self.doNextButton(_:)), for: .touchUpInside)
        nextButton.imageEdgeInsets = UIEdgeInsets(top: -100, left: 48, bottom: -40, right: 0)
        nextButton.titleEdgeInsets = UIEdgeInsets(top: 50, left: -70, bottom: 0, right: 0)
        nextButton.center = CGPoint(x: self.center.x, y: nextButton.center.y)
        self.addSubview(nextButton)
        
        // Add Prompt view
        let subBtnSize = buttonHeight*1.8
        let subBtnX = nextButton.frame.origin.x
        let repeatFrame = CGRect(x: subBtnX, y: buttonHeight*6, width: subBtnSize, height: subBtnSize)
        let repeatButton = MFRectIconButton(frame: repeatFrame)
        repeatButton.configure("Repeat",icon:"icon_redo",tag:101)
        repeatButton.fontSize = 12.0
        repeatButton.addTarget(self, action: #selector(self.doRepeatButton(_:)), for: .touchUpInside)
        repeatButton.imageEdgeInsets = UIEdgeInsets(top: -60, left: 20, bottom: -40, right: 20)
        repeatButton.titleEdgeInsets = UIEdgeInsets(top: 26, left: -60, bottom: 0, right: 0)
        self.addSubview(repeatButton)
        
        // Add Cancel button
        let subBtnX2 = subBtnX + nextButton.frame.size.width - subBtnSize
        let quitFrame = CGRect(x: subBtnX2, y: buttonHeight*6, width: subBtnSize, height: subBtnSize)
        let quitButton = MFRectIconButton(frame: quitFrame)
        quitButton.configure("Exit",icon:"icon_close",tag:102)
        quitButton.fontSize = 12.0
        quitButton.addTarget(self, action: #selector(self.doCancelButton(_:)), for: .touchUpInside)
        quitButton.imageEdgeInsets = UIEdgeInsets(top: -60, left: 20, bottom: -40, right: 20)
        quitButton.titleEdgeInsets = UIEdgeInsets(top: 26, left: -65, bottom: 0, right: 0)
        self.addSubview(quitButton)
        

        
        // Magic code to force a rounded rectangle mask on the layer...
        /*
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
        // Add border with 1.0 pixel width
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.shadowColor = UIColor.lightText.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 2.0
        
        self.backgroundColor = MFBlueStart()
        */
        
        // Create backing view
        let window :UIWindow = UIApplication.shared.keyWindow!
        self.backView = UIView(frame: window.frame)
        self.backView.isUserInteractionEnabled = true
        if showGradientBlur {
            let gradient = CAGradientLayer()
            gradient.bounds = self.backView.bounds
            gradient.position = self.backView.center
            let gray1 = UIColor(r:11,g:11,b:11,a:0.8).cgColor
            let gray2 = UIColor(r:33,g:33,b:33,a:0.8).cgColor
            gradient.colors = [gray1,gray2]
            gradient.locations = [0.0,1.0]
            self.backView.layer.insertSublayer(gradient, at: 0)
        }
        else {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = backView.frame
            self.backView.addSubview(blurView)
        }
        
        
    }
    
    // MARK: Display methods
    
    func show() {
        // Method to display a previously initialized view
        if let window :UIWindow = UIApplication.shared.keyWindow {
            let center = window.center
            
            window.addSubview(self.backView)
            self.center = CGPoint(x: center.x, y: center.y-20)
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.alpha = 0.5
            window.addSubview(self)
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                // Step 1.
                self.backView.alpha = 1.0
            }, completion: { (finished) -> Void in
                // Step 2.
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    // Step 3.
                    self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.center = center
                    self.alpha = 1.0
                }, completion: { (finished) -> Void in
                    // Step 4.
                    UIView.animate(withDuration: 0.10, animations: { () -> Void in
                        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    })
                })
                
            })
        }
    }
    
    @objc func doNextButton(_ sender :AnyObject) {
        // User selected an option
        self.dismissView(1)
    }
    
    @objc func doRepeatButton(_ sender :AnyObject) {
        // User selected an option
        self.dismissView(2)
    }
    
    @objc func doCancelButton(_ sender :AnyObject) {
        // User opted-out of the view
        self.dismissView(0)
    }
    
    func dismissView(_ buttonIndex :Int) {
        // Method to hide the view and background
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.backView.alpha = 0.5
            self.alpha = 0.2
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        }, completion: { (completed) -> Void in
            self.backView.removeFromSuperview()
            self.removeFromSuperview()
            
            // Remove subviews
            self.backView = nil
            
            if self.completionHandler != nil {
                self.completionHandler(buttonIndex)
            }
        })
    }
    
    
    
}

// MARK: - MFAlertView

class MFAlertTitleLabel : UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.awakeFromNib()
    }
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor(hex: 0x0d3743, alpha: 1.0)
        self.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        self.textColor = UIColor(hex: 0xe6e6e6, alpha: 1.0)
        
    }
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        super.drawText(in: rect.inset(by: insets))
    }
    
}

class MFAlertView : UIView {
    // Custom alert view globals
    var completionHandler :((_ buttonIndex :Int) -> ())?
    var titleString :String!
    var messageString :String!
    var cancelString :String!
    var defaultString :String!
    var backView :UIView!
    var buttonCount :Int = 0
    var cancelButton :MFRoundedButton!
    var defaultButton :MFRoundedButton!
    var showGradientBlur = true
    
    // Custom alert view methods
    
    convenience init(title: String, message: String, cancelPrompt: String, completionHandler: ((_ buttonIndex :Int) -> ())? ) {
        self.init(frame: CGRect.zero)
        
        self.titleString = title
        self.messageString = message
        self.cancelString = cancelPrompt
        
        self.completionHandler = completionHandler
        
        self.configure(1)
        
    }
    
    convenience init(title: String, message: String, defaultPrompt: String, cancelPrompt: String, completionHandler: @escaping (_ buttonIndex :Int) -> () ) {
        self.init(frame: CGRect.zero)
        
        self.titleString = title
        self.messageString = message
        self.defaultString = defaultPrompt
        self.cancelString = cancelPrompt
        
        self.completionHandler = completionHandler
        
        self.configure(2)
        
    }
    
    func configure(_ buttonCount :Int) {
        // Configure view depending on button count / alert style
        self.buttonCount = buttonCount
        
        // Create & size the alert UIView based on the button & text settings
        var viewHeight :CGFloat = 0.0
        let viewWidth :CGFloat = 250.0
        let vSpace :CGFloat = 20.0
        
        // Set up the title label
        let titleHeight :CGFloat = 50.0
        let title = MFAlertTitleLabel(frame: CGRect(x: 0.0,y: 0.0,width: viewWidth, height: titleHeight))
        title.text = self.titleString
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        title.adjustsFontSizeToFitWidth = true
        title.baselineAdjustment = UIBaselineAdjustment.alignCenters
        title.textAlignment = NSTextAlignment.left
        title.textColor = UIColor.white
        //        title.shadowColor = UIColor.lightGrayColor()
        //        title.shadowOffset = CGSize(width: 0.0, height: 1.0)
        title.backgroundColor = UIColor(hex: 0x3C434E, alpha: 1.0)
        
        viewHeight += titleHeight + vSpace
        
        
        // Set up the body text label
        let bodyInset :CGFloat = 20.0
        let bodyFrame = CGRect(x: bodyInset, y: 0.0,width: viewWidth-2*bodyInset, height: 44.0)
        let body = MFAlertBodyLabel(frame: bodyFrame)
        body.setAttText(self.messageString)
        body.font = UIFont(name: "TradeGothicLTStd", size: 14)
        body.numberOfLines = 0
        body.adjustsFontSizeToFitWidth = true
        body.baselineAdjustment = UIBaselineAdjustment.alignCenters
        body.textAlignment = NSTextAlignment.left
        body.textColor = UIColor(hex: 0x627388, alpha: 1.0)
        body.shadowColor = UIColor.lightGray
        body.shadowOffset = CGSize(width: 0.0, height: 0.0)
        body.backgroundColor = UIColor.clear
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.0
        
        let attributes = [NSAttributedString.Key.font : body.font, NSAttributedString.Key.paragraphStyle: paragraphStyle] as [NSAttributedString.Key : Any] //as! [String : Any]
        let rect = body.text?.boundingRect(with: CGSize(width: body.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        let bodyTextHeight = rect?.height
        
        body.frame = CGRect(x: bodyInset, y: viewHeight, width: viewWidth-2*bodyInset, height: bodyTextHeight!)
        
        viewHeight += bodyTextHeight! + vSpace
        let buttonTop = viewHeight      // Save for later
        let buttonHeight :CGFloat = 66.0
        
        // Calculate total view height
        viewHeight += buttonHeight * CGFloat(buttonCount)
        
        if buttonCount == 2 { viewHeight -= buttonHeight * 0.20 }
        
        self.frame = CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewHeight)
        self.addSubview(title)
        self.addSubview(body)
        
        // Set up buttons
        let buttonInset :CGFloat = 20.0
        let buttonFrame = CGRect(x: buttonInset, y: buttonTop, width: viewWidth-2*buttonInset, height: 44.0)
        
        let cancel = MFRoundedButton(frame: buttonFrame)
        cancel.tag = 100  // Blue
        if buttonCount == 2 { cancel.tag = 101 } // Gray
        
        // Set up button text
        cancel.setTitle(self.cancelString, for: UIControl.State())
        cancel.setTitle(self.cancelString, for: .selected)
        
        // Set up callback
        cancel.addTarget(self, action: #selector(MFAlertView.doButton(_:)), for: .touchUpInside)
        self.cancelButton = cancel
        
        // Add the button
        self.addSubview(cancel)
        
        
        // Add default button
        if buttonCount == 2 {
            // Push cancel button down
            let cancelFrame = buttonFrame.offsetBy(dx: 0.0, dy: buttonHeight * 0.80)
            self.cancelButton.frame = cancelFrame
            
            let dButton = MFRoundedButton(frame: buttonFrame)
            dButton.tag = 102  // Orange
            
            // Set up button text
            dButton.setTitle(self.defaultString, for: UIControl.State())
            dButton.setTitle(self.defaultString, for: .selected)
            
            // Set up callback
            dButton.addTarget(self, action: #selector(MFAlertView.doButton(_:)), for: .touchUpInside)
            self.defaultButton = dButton
            
            // Add the button
            self.addSubview(dButton)
            
        }
        
        // Magic code to force a rounded rectangle mask on the layer...
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
        // Add border with 1.0 pixel width
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.lightText.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 2.0
        
        self.backgroundColor = UIColor.white
        
        
        // Create backing view
        let window :UIWindow = UIApplication.shared.keyWindow!
        self.backView = UIView(frame: window.frame)
        if showGradientBlur {
            let gradient = CAGradientLayer()
            gradient.bounds = self.backView.bounds
            gradient.position = self.backView.center
            // R: 103 G: 115 B: 134 A:0.65
            let gray1 = UIColor(r:103,g:115,b:134,a:0.8).cgColor
            let gray2 = UIColor(r:103,g:115,b:134,a:0.8).cgColor
            gradient.colors = [gray1,gray2]
            gradient.locations = [0.0,1.0]
            self.backView.layer.insertSublayer(gradient, at: 99)
        }
        else {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = backView.frame
            self.backView.addSubview(blurView)
        }
        
    }
    
    func show() {
        // Method to display a previously initialized view
        if let window :UIWindow = UIApplication.shared.keyWindow {
            let center = window.center
            
            window.addSubview(self.backView)
            self.center = CGPoint(x: center.x, y: center.y-20)
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.alpha = 0.5
            window.addSubview(self)
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                // Step 1.
                self.backView.alpha = 1.0
            }, completion: { (finished) -> Void in
                // Step 2.
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    // Step 3.
                    self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.center = center
                    self.alpha = 1.0
                }, completion: { (finished) -> Void in
                    // Step 4.
                    UIView.animate(withDuration: 0.10, animations: { () -> Void in
                        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    })
                })
                
            })
        }
    }
    
    @objc func doButton(_ sender :AnyObject) {
        // Check the value of the tag, send this to the completion handler
        if let sender :MFRoundedButton = sender as? MFRoundedButton {
            var index = 0
            if sender == self.cancelButton { index = 0 }
            if self.defaultButton != nil {
                if sender == self.defaultButton { index = 1 }
            }
            if self.completionHandler != nil {
                completionHandler?(index)
            }
            self.dismissView()
        }
    }
    
    func dismissView() {
        // Method to hide the view and background
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.backView.alpha = 0.5
            self.alpha = 0.2
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        }, completion: { (completed) -> Void in
            self.backView.removeFromSuperview()
            self.removeFromSuperview()
            
            // Remove subviews
            self.backView = nil
            self.cancelButton = nil
            self.defaultButton = nil
        })
    }
}


// MARK: - MFProgressHUD

class MFProgressHUD : UIView {
    static let sharedView = MFProgressHUD()
    
    var labelText :String = "Loading…"
    var detailsLabelText :String = "Please wait"
    var progress :Float = 0.0
    
    var backView :UIView!
    let showGradientBlur :Bool = true
    
    var title :MFAlertTitleLabel!
    var body :MFAlertBodyLabel!
    var activity :UIActivityIndicatorView!
    
    func show(_ status: String, detail:String) -> Void {
        if(MFProgressHUD.sharedView.superview == nil) {
            UIApplication.shared.keyWindow?.addSubview(MFProgressHUD.sharedView)
        }
        configure()

        MFProgressHUD.sharedView.progress = 0.0
        MFProgressHUD.sharedView.labelText = status
        MFProgressHUD.sharedView.detailsLabelText = detail
        MFProgressHUD.sharedView.show()
        
    }
    
    func wait(_ status: String, detail:String) -> Void {
        self.show(status, detail: detail)
//        MFProgressHUD.sharedView.mode = MBProgressHUDMode(rawValue:0)!
//        MFProgressHUD.sharedView.activityIndicatorColor = MFOrangeActive()
        
    }
    
    func splash(_ status: String, detail:String) -> Void {
        self.show(status, detail: detail)
//        MFProgressHUD.sharedView.mode = MBProgressHUDMode(rawValue:4)!
//        MFProgressHUD.sharedView.dimBackground = false
        MFProgressHUD.sharedView.hide(true, afterDelay:1.5)
    }
    
    func update(_ progress: Float) {
        MFProgressHUD.sharedView.progress = progress
    }
    
    func hide() {
        MFProgressHUD.sharedView.hide(true, afterDelay:0.5)
    }
    
    func hide (_ delay :Double?) {
        let seconds :Double = delay != nil ? delay! : 0.5
        MFProgressHUD.sharedView.hide(true, afterDelay:seconds)
    }
    
    // Hide
    func hide(_ animate: Bool, afterDelay: Double) {
        self.dismissView()
    }
    
    
    // Subviews
    func configure() {
        let buttonCount :Int = 1
        
        // Create & size the alert UIView based on the button & text settings
        var viewHeight :CGFloat = 0.0
        let viewWidth :CGFloat = 250.0
        let vSpace :CGFloat = 20.0
        
        // Set up the title label
        let titleHeight :CGFloat = 50.0
        if title == nil {
            title = MFAlertTitleLabel(frame: CGRect(x: 0.0,y: 0.0,width: viewWidth, height: titleHeight))
            title.text = self.labelText
            title.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            title.adjustsFontSizeToFitWidth = true
            title.baselineAdjustment = UIBaselineAdjustment.alignCenters
            title.textAlignment = NSTextAlignment.left
            title.textColor = UIColor.white
            //        title.shadowColor = UIColor.lightGrayColor()
            //        title.shadowOffset = CGSize(width: 0.0, height: 1.0)
            title.backgroundColor = UIColor(hex: 0x3C434E, alpha: 1.0)
            self.addSubview(title)
        }
        
        viewHeight += titleHeight + vSpace
        
        
        // Set up the body text label
        var bodyTextHeight :CGFloat? = 22.0
        if body == nil {
            let bodyInset :CGFloat = 20.0
            let bodyFrame = CGRect(x: bodyInset, y: 0.0,width: viewWidth-2*bodyInset, height: 44.0)
            body = MFAlertBodyLabel(frame: bodyFrame)
            body.setAttText(self.detailsLabelText)
            body.font = UIFont(name: "TradeGothicLTStd", size: 14)
            body.numberOfLines = 0
            body.adjustsFontSizeToFitWidth = true
            body.baselineAdjustment = UIBaselineAdjustment.alignCenters
            body.textAlignment = NSTextAlignment.left
            body.textColor = UIColor(hex: 0x627388, alpha: 1.0)
            body.shadowColor = UIColor.lightGray
            body.shadowOffset = CGSize(width: 0.0, height: 0.0)
            body.backgroundColor = UIColor.clear
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6.0
            
            let attributes = [NSAttributedString.Key.font : body.font, NSAttributedString.Key.paragraphStyle: paragraphStyle] as [NSAttributedString.Key : Any] //as! [String : Any]
            let rect = body.text?.boundingRect(with: CGSize(width: body.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
            bodyTextHeight = rect?.height
            
            body.frame = CGRect(x: bodyInset, y: viewHeight, width: viewWidth-2*bodyInset, height: bodyTextHeight!)
            self.addSubview(body)
        }
        
        viewHeight += bodyTextHeight! + vSpace
        
        let buttonTop = viewHeight      // Save for later
        let buttonHeight :CGFloat = 66.0
        
        // Calculate total view height
        viewHeight += buttonHeight * CGFloat(buttonCount)
        
        
        
        // Set up buttons
        if activity == nil {
            let buttonInset :CGFloat = (viewWidth-44.0)*0.5
            let buttonFrame = CGRect(x: buttonInset, y: buttonTop, width: 44.0, height: 44.0)
            
            activity = UIActivityIndicatorView(frame: buttonFrame)
            activity.style = .whiteLarge
            activity.color = .black
            activity.startAnimating()
            
            // Add the spinner
            self.addSubview(activity)
        }

        self.frame = CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewHeight)

        
        // Magic code to force a rounded rectangle mask on the layer...
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
        // Add border with 1.0 pixel width
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.lightText.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 2.0
        
        self.backgroundColor = UIColor.white
        
        
        // Create backing view
        let window :UIWindow = UIApplication.shared.keyWindow!
        self.backView = UIView(frame: window.frame)
        if showGradientBlur {
            let gradient = CAGradientLayer()
            gradient.bounds = self.backView.bounds
            gradient.position = self.backView.center
            // R: 103 G: 115 B: 134 A:0.65
            let gray1 = UIColor(r:103,g:115,b:134,a:0.8).cgColor
            let gray2 = UIColor(r:103,g:115,b:134,a:0.8).cgColor
            gradient.colors = [gray1,gray2]
            gradient.locations = [0.0,1.0]
            self.backView.layer.insertSublayer(gradient, at: 99)
        }
        else {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = backView.frame
            self.backView.addSubview(blurView)
        }
        
    }

    func show() {
        // Method to display a previously initialized view
        if let window :UIWindow = UIApplication.shared.keyWindow {
            let center = window.center
            
            window.addSubview(self.backView)
            self.center = CGPoint(x: center.x, y: center.y-20)
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.alpha = 0.5
            window.addSubview(self)
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                // Step 1.
                self.backView.alpha = 1.0
            }, completion: { (finished) -> Void in
                // Step 2.
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    // Step 3.
                    self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.center = center
                    self.alpha = 1.0
                }, completion: { (finished) -> Void in
                    // Step 4.
                    UIView.animate(withDuration: 0.10, animations: { () -> Void in
                        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    })
                })
                
            })
        }
    }

    func dismissView() {
        // Method to hide the view and background
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.backView.alpha = 0.5
            self.alpha = 0.2
            self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        }, completion: { (completed) -> Void in
            self.backView.removeFromSuperview()
            self.title.removeFromSuperview()
            self.body.removeFromSuperview()
            self.activity.removeFromSuperview()
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.removeFromSuperview()
            
            // Remove subviews
            self.backView = nil
            self.title = nil
            self.body = nil
            self.activity = nil
        })
    }

    
}
