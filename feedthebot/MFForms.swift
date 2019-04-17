//
//  MFForms.swift
//  feedthebot
//
//  Created by d. nye on 4/11/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation
import UIKit



class MFFormTitle1Label : UILabel {
    
    override func awakeFromNib() {
        self.font = UIFont.boldSystemFont(ofSize: 12)
        self.textColor = UIColor.white
    }
}

class MFFormTextField1 : UITextField {
    // Subclass of UITextField to display a text field in a form
    override func awakeFromNib() {
        let placeholderFont = UIFont(name: "HelveticaNeue-Bold", size: 14)
        self.font = placeholderFont ?? UIFont.systemFont(ofSize: 14)
        self.textColor = MFGreen()
        self.backgroundColor = MFDarkBlue()
        
        self.drawOutlineRect()
        
        // Placeholder styling
        let attrib  = [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14) ]
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: attrib)
        
    }
    
    var outlineLayer :CAShapeLayer!
    func drawOutlineRect() {
        
        if self.outlineLayer != nil {
            self.outlineLayer.removeFromSuperlayer()
        }
        //! Initialize outline, set frame and color
        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.main.scale
        var frame : CGRect = self.frame
        frame.size.width = frame.size.width
        let cornerRadius = CGFloat(3.0)
        let borderInset = CGFloat(-2.0)
        let aPath = UIBezierPath(roundedRect: frame.insetBy(dx: borderInset, dy: borderInset), cornerRadius: cornerRadius)
        
        shapeLayer.path = aPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 0.5
        //        self.layer.insertSublayer(shapeLayer, at: 0)
        self.layer.superlayer?.insertSublayer(shapeLayer, at: 0)
        self.outlineLayer = shapeLayer
        
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawOutlineRect()
        self.setNeedsDisplay()
    }
    
}
