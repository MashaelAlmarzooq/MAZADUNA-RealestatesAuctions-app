//
//  CardView.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 9/17/21.
//

import Foundation
import UIKit
@IBDesignable class CardView : UIView {
    
    @IBInspectable let cornerRadius : CGFloat = 0
    @IBInspectable let shadowColor : UIColor? = UIColor.black
    @IBInspectable let shadowOffSetwidth : Int = 0
    @IBInspectable let shadowOffSetHight : Int = 1
    
    @IBInspectable let shadowObacity : Float = 0.2
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffSetwidth, height: shadowOffSetHight)
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = shadowObacity
    }
    
    
    
    
}
