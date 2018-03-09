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
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.15
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 12, height: 12)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func lowShadow() {
        self.layer.cornerRadius = 12
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}


class ErrorLabel: UILabel {
    
        
    func initializeLabel(content: String) {
        
            self.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 24, height: 48)
            self.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 80)
            self.text = content
            self.font = UIFont(name: "Helvetica", size: 17.0)
            self.textAlignment = .center
            self.textColor = UIColor.flatForestGreenColorDark()
            
        }
        
    }

class AlertCreation {
    
    var showing = false
    var view = ErrorPopup()
    var timer = Timer()
    
    func createView() -> ErrorPopup {
        
        let annen = ErrorPopup()

        annen.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0)
        annen.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 0.7543075771)
        
        view = annen
        
        return view
    }
    
    func animate() {

        showing = true
        view.frame.size.height = 40
        view.reloadInputViews()
        
        timer = Timer.scheduledTimer(timeInterval: showMore(), target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: false)
    }
    
   @objc func updateTimer() {
    UIView.animate(withDuration: 0.5, animations: { self.view.frame.size.height = 0  }, completion: {
        (finished: Bool) in
        self.view.removeFromSuperview()
        self.showing = false
    })
    
    
    }
    
    func isShowing() -> Bool {
        if showing == true {
            return true
        } else {
            return false
        }
    }
    
    func showMore() -> Double {
        
        let seconds = 3.0
        return seconds
    }
    
    func animateAlert(errorMessage: String, VC: UIViewController) {
        
        let alertView = createView()
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.animate()
            VC.view.addSubview(alertView)
            alertView.createLabel(content: errorMessage)
            
        })
        
    }
    
    //BACKGROUND ERROR
    
    func backgroundError(errorMessage: String, VC: UIViewController) -> ErrorLabel {
        
        let errorLabel = ErrorLabel()
        errorLabel.removeFromSuperview()
        errorLabel.initializeLabel(content: errorMessage)
        VC.view.addSubview(errorLabel)
        
        return errorLabel
    }
    
    //MARK: - ALERTCONTROLLER CREATION
    func popupAlert(errorMessage: String, button: String, VC: UIViewController, completion: Any?) {
        
        let errorAlert = UIAlertController(title: "Hata", message: errorMessage, preferredStyle: .alert)
        
        let action = UIAlertAction(title: button, style: .default, handler: nil)
        
        errorAlert.addAction(action)
        
        VC.present(errorAlert, animated: true) {
            completion
        }
        
        
    }
    
    
    
}

class ErrorPopup: UIView {
    
    func createLabel(content: String) {
        print(content)
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - 24, height: 21 )
        label.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = content
        self.addSubview(label)
    }
    
}
