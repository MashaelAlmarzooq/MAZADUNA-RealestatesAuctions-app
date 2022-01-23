//
//  priceTagView.swift
//  MAZADUNA
//
//  Created by Meshael Hamad on 02/11/21.
//

import UIKit
import MapKit

class priceTagView: MKAnnotationView {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var tapButton: UIButton!
    var post: Post?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.layer.shadowColor = UIColor.lightGray.cgColor
        self.viewContainer.layer.shadowOffset = .zero
        self.viewContainer.layer.shadowRadius = 3
        self.viewContainer.layer.shadowOpacity = 0.5
        self.priceLabel.sizeToFit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.drawPointingView()
        }
    }

    private func drawPointingView() {
        let arrowWidth: CGFloat = 8
        let centerX = (self.viewContainer.frame.width) / 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: self.viewContainer.frame.width - 16, y: 0))
        path.addLine(to: CGPoint(x: self.viewContainer.frame.width - 16, y: self.viewContainer.frame.height))
        path.addLine(to: CGPoint(x: centerX + arrowWidth, y: self.viewContainer.frame.height))
        //draw an arrow pointing out to the center cordinate of the label.

        path.addLine(to: CGPoint(x: centerX, y: self.viewContainer.frame.height+arrowWidth))
        path.addLine(to: CGPoint(x: centerX - arrowWidth, y: self.viewContainer.frame.height))
        path.addLine(to: CGPoint(x: 8, y: self.viewContainer.frame.height))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.close()
        
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.white.cgColor
        shape.path = path.cgPath
        self.viewContainer.layer.insertSublayer(shape, at: 0)
    }
}
