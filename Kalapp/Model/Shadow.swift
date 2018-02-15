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
    
    private func setupShadow() {
        self.layer.cornerRadius = 12
        self.layer.shadowOffset = CGSize(width: 3, height: 0)
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.15
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 12, height: 12)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
