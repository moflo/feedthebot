//
//  MFAlerts.swift
//  feedthebot
//
//  Created by d. nye on 4/15/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit

class MFAlertTrainView: UIView, UIScrollViewDelegate {
    
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
    
    // MARK: - Display methods
    
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
