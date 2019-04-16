//
//  MFButtons.swift
//  feedthebot
//
//  Created by d. nye on 4/11/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation
import UIKit


// MARK: - MFRoundedButton

class MFRoundedButton : UIButton {
    
    var borderWidth : CGFloat! = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var insetWidth : CGFloat! = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    
    override func awakeFromNib()
    {
        self.setTitleColor(UIColor.black, for: UIControl.State())
        self.setTitleColor(UIColor.black, for: .highlighted)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.borderWidth = 2
        self.insetWidth = self.borderWidth! * 2.5
        self.layer.contentsScale = UIScreen.main.scale
    }
    
    override func draw(_ rect :CGRect) {
        let ctx = UIGraphicsGetCurrentContext() //as CGContextRef
        
        var strokeColor = UIColor.black.cgColor
        var fillColor = UIColor.black.cgColor
        
        if (self.tag == 0) {
            // Default behavior
            
            switch self.state {
            case UIControl.State():
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.selected:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.disabled:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            default:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = UIColor.clear.cgColor
                
            }
        }
        
        if (self.tag == 100) {
            // Green button, no border
            self.insetWidth = 0.0
            self.setTitleColor(.black, for: UIControl.State())
            self.setTitleColor(.black, for: .highlighted)
            self.setTitleColor(.black, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.selected:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.disabled:
                strokeColor = MFGreen().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
                
            default:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
            }
            
            
        }
        
        if (self.tag == 101) {
            // Black button, no border
            self.insetWidth = 0.0
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.black, for: .highlighted)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.selected:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.disabled:
                strokeColor = MFBlue().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            }
            
        }
        
        if (self.tag == 102) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.white, for: .highlighted)
            self.setTitleColor(MFRed(), for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.selected:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.disabled:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            }
            
            
        }
        
        if (self.tag == 103) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(.white, for: UIControl.State())
            self.setTitleColor(.white, for: .highlighted)
            self.setTitleColor(.white, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.selected:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.disabled:
                strokeColor = UIColor.lightGray.cgColor
                fillColor = UIColor.black.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = UIColor.white.cgColor
                fillColor = UIColor.white.cgColor
            }
            
            
        }
        
        
        ctx?.setFillColor(fillColor)
        ctx?.setStrokeColor(strokeColor)
        ctx?.saveGState()
        
        ctx?.setLineWidth(self.borderWidth)
        
        if (self.tag == 0 || self.tag == 103) {
            // Default style is to draw an outline, highlight is filled rounded rect
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: (self.bounds.height-2)/2)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (self.isHighlighted || self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:self.bounds.height/2)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if (self.tag == 100 || self.tag == 101 || self.tag == 102) {
            // Draw filled rounded rect, outline when highlighted
            
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: (self.bounds.height-2)/2)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (!self.isHighlighted && !self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:self.bounds.height/2)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if(self.isHighlighted) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.highlighted)
        }
        else if(self.isSelected) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.selected)
        }
        else {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State())
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
}

// MARK: - MFRectIconButton

class MFRectIconButton : UIButton {
    
    var borderWidth : CGFloat! = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var insetWidth : CGFloat! = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var cornerRadius : CGFloat! = 16.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var fontSize : CGFloat! = 22.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    func configure(_ title:String, icon:String, tag:Int) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setImage(UIImage(named: icon), for: .normal)
        self.setImage(UIImage(named: icon), for: .highlighted)
        self.tag = tag
        self.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.awakeFromNib()
    }
    
    
    override func awakeFromNib()
    {
        self.setTitleColor(UIColor.black, for: UIControl.State())
        self.setTitleColor(UIColor.black, for: .highlighted)
        
        self.imageView?.contentMode = .scaleAspectFit
        self.contentMode = .center
        
        self.borderWidth = 2
        self.insetWidth = self.borderWidth! * 2.5
        self.layer.contentsScale = UIScreen.main.scale
        
        // Arrange icon & text
        
    }
    
    override func draw(_ rect :CGRect) {
        let ctx = UIGraphicsGetCurrentContext() //as CGContextRef
        
        var strokeColor = UIColor.black.cgColor
        var fillColor = UIColor.black.cgColor
        
        if (self.tag == 0) {
            // Default behavior
            
            switch self.state {
            case UIControl.State():
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.selected:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            case UIControl.State.disabled:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                
            default:
                strokeColor = (self.titleColor(for: UIControl.State()) != nil) ? self.titleColor(for: UIControl.State())!.cgColor : UIColor.blue.cgColor
                fillColor = UIColor.clear.cgColor
                
            }
        }
        
        if (self.tag == 100) {
            // Green button, no border
            self.insetWidth = 0.0
            self.setTitleColor(.black, for: UIControl.State())
            self.setTitleColor(.black, for: .highlighted)
            self.setTitleColor(.black, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.selected:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
                
            case UIControl.State.disabled:
                strokeColor = MFGreen().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
                
            default:
                strokeColor = MFGreen().cgColor
                fillColor = MFGreen().cgColor
            }
            
            
        }
        
        if (self.tag == 101) {
            // Black button, no border
            self.insetWidth = 0.0
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.black, for: .highlighted)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.selected:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            case UIControl.State.disabled:
                strokeColor = MFBlue().cgColor
                fillColor = UIColor.clear.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFBlue().cgColor
                fillColor = MFBlue().cgColor
            }
            
        }
        
        if (self.tag == 102) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.setTitleColor(UIColor.white, for: .highlighted)
            self.setTitleColor(MFRed(), for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.selected:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            case UIControl.State.disabled:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = MFRed().cgColor
                fillColor = MFRed().cgColor
            }
            
            
        }
        
        if (self.tag == 103) {
            // Orange button, no border, smaller text, green text when selected
            self.setTitleColor(.white, for: UIControl.State())
            self.setTitleColor(.white, for: .highlighted)
            self.setTitleColor(.white, for: .disabled)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            
            switch (self.state) {
            case UIControl.State.highlighted:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.selected:
                strokeColor = UIColor.gray.cgColor
                fillColor = UIColor.gray.cgColor
            case UIControl.State.disabled:
                strokeColor = UIColor.lightGray.cgColor
                fillColor = UIColor.black.cgColor
                self.insetWidth = self.borderWidth * 2.5
            default:
                strokeColor = UIColor.white.cgColor
                fillColor = UIColor.white.cgColor
            }
            
            
        }
        
        
        ctx?.setFillColor(fillColor)
        ctx?.setStrokeColor(strokeColor)
        ctx?.saveGState()
        
        ctx?.setLineWidth(self.borderWidth)
        
        if (self.tag == 0 || self.tag == 103) {
            // Default style is to draw an outline, highlight is filled rounded rect
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: cornerRadius)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (self.isHighlighted || self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:cornerRadius)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if (self.tag == 100 || self.tag == 101 || self.tag == 102) {
            // Draw filled rounded rect, outline when highlighted
            
            let outlinePath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: self.borderWidth, dy: self.borderWidth), cornerRadius: cornerRadius)
            
            ctx?.addPath(outlinePath.cgPath)
            ctx?.strokePath()
            
            ctx?.restoreGState()
            
            if (!self.isHighlighted && !self.isSelected) {
                ctx?.saveGState()
                let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:cornerRadius)
                
                ctx?.addPath(fillPath.cgPath)
                ctx?.fillPath()
                
                ctx?.restoreGState()
            }
        }
        
        if(self.isHighlighted) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.highlighted)
        }
        else if(self.isSelected) {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State.selected)
        }
        else {
            self.imageView?.tintColor = self.titleColor(for: UIControl.State())
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
}

// MARK: - MFAlertButton

class MFAlertButton : UIButton {
    // UIButton subclass to mimic the UIAlert button
    
    var borderWidth : CGFloat! = 0.5
    var insetWidth : CGFloat! = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize()
    {
        self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15.0)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.darkGray, for: .highlighted)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.layer.contentsScale = UIScreen.main.scale
        self.backgroundColor = MFGreen()
    }
    
    fileprivate var borderLayer: CAShapeLayer?
    fileprivate func layoutOutlineLayer() {
        if let existingLayer = borderLayer {
            existingLayer.removeFromSuperlayer()
        }
        let outlineShape = CAShapeLayer()
        let w = self.frame.size.width
        let h = CGFloat(0.1)
        let frame = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        outlineShape.frame = frame
        outlineShape.path = UIBezierPath(roundedRect: frame, cornerRadius: 0.0).cgPath
        outlineShape.fillColor = MFGreen().cgColor
        outlineShape.strokeColor = UIColor.lightGray.cgColor
        outlineShape.lineWidth = 0.5
        self.layer.insertSublayer(outlineShape, at: 0)
        self.borderLayer = outlineShape
    }
    
    override func draw(_ rect :CGRect) {
        let ctx = UIGraphicsGetCurrentContext() //as CGContextRef
        
        let strokeColor = UIColor.clear.cgColor
        let fillColor = MFGreen().cgColor
        
        
        ctx?.setFillColor(fillColor)
        ctx?.setStrokeColor(strokeColor)
        ctx?.saveGState()
        
        //        CGContextSetLineWidth(ctx, self.borderWidth)
        //
        ////        let outlinePath = UIBezierPath(roundedRect: CGRectInset(self.bounds, self.borderWidth, self.borderWidth), cornerRadius: 0.0)
        //
        //        CGContextAddPath(ctx, outlinePath.CGPath)
        //        CGContextStrokePath(ctx)
        //
        //        CGContextRestoreGState(ctx)
        
        if (self.isHighlighted || self.isSelected) {
            ctx?.saveGState()
            let fillPath = UIBezierPath(roundedRect:self.bounds.insetBy(dx: self.insetWidth, dy: self.insetWidth), cornerRadius:0.0)
            
            ctx?.addPath(fillPath.cgPath)
            ctx?.fillPath()
            
            ctx?.restoreGState()
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutOutlineLayer()
        self.setNeedsDisplay()
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
}

// MARK: - Device Types

enum UIUserInterfaceIdiom : Int
{
    case unspecified
    case phone
    case pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}
