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
        
        let action = UIAlertAction(title: button, style: .default) { action in
            completion
        }
        
        
        errorAlert.addAction(action)
        
        VC.present(errorAlert, animated: true, completion: nil)
        
    }
    
}

class LoadingView {
    
    let screenSize = UIScreen.main.bounds.size
    
    
    //EKRANA DOKUNULMASINI ENGELLE
//    func load() -> UIView{
//
//        let backView = UIView()
//        backView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
//        backView.backgroundColor = .none
//
//    //LOADING INDICATORU YOLLA GELSİN LOL
//
//        let sex = UIView()
//        sex.frame = CGRect(x: 0, y: 0, width: screenSize.width / 2, height: 100)
//        sex.layer.cornerRadius = 15
//        sex.layer.masksToBounds = true
//        sex.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.6963827055)
//        sex.center = CGPoint(x: screenSize.width / 2 , y: screenSize.height / 2)
//
//        let indicator = activity(view: sex)
//
//        sex.addSubview(indicator)
//        backView.addSubview(sex)
//        indicator.startAnimating()
//
//        return backView
//    }
//
//    func activity(view: UIView) -> UIActivityIndicatorView {
//        let activity = UIActivityIndicatorView()
//        activity.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
//        activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        activity.activityIndicatorViewStyle = .whiteLarge
//
//        return activity
//
//    }
    
    func showActivityIndicatory(uiView: UIView) -> UIView {
        let container: UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        container.backgroundColor = .none
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 - 100)
        loadingView.backgroundColor = #colorLiteral(red: 0.1861208975, green: 0.3144840002, blue: 0.1993199885, alpha: 0.7030447346)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.activityIndicatorViewStyle = .whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
    
        
        actInd.startAnimating()
        
        return container

    }
    
}

class ImageResize {
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        
       
        let newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)

        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeProfilePhoto(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heigthRatio = targetSize.height / size.height
        
        var newSize : CGSize
        
        if widthRatio > heigthRatio {
            newSize = CGSize(width: size.width * heigthRatio, height: size.height * heigthRatio)
        }
        else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x:0, y:0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
}
