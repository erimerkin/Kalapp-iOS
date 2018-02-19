//
//  Shadow.swift
//  Kalapp
//
//  Created by Arkhin & Barziş on 15.02.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    func setupShadow() {
        self.layer.cornerRadius = 12
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.15
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 12, height: 12)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func lowShadow() {
        self.layer.cornerRadius = 12
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}


class ErrorLabel: UILabel {
    
        
    func initializeLabel(content: String) {
        
            self.bounds = CGRect(x: 0, y: 0, width: 200, height: 21)
            self.center = CGPoint(x: 160, y: 285)
            self.text = content
            self.textAlignment = .center
            self.textColor = UIColor.flatForestGreenColorDark()
            
        }
        
    }

