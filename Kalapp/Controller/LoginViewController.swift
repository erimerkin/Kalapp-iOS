//
//  LoginViewController.swift
//  Kalapp
//
//  Created by Arkhin on 2.02.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit
import Alamofire
import ChameleonFramework
import SwiftyJSON
import KeychainSwift
import NVActivityIndicatorView

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}


class LoginViewController: UIViewController, NVActivityIndicatorViewable{

    let keychain = KeychainSwift(keyPrefix: "user_")
    let defaults = UserDefaults.standard
    var loginHash = ""
    var errorAlert = UIAlertController()
    var action = UIAlertAction()
    let borderBir = CALayer()
    var borderIki = CALayer()

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var okulNoTextField: UITextField!
    @IBOutlet weak var sifreTextField: UITextField!
    @IBOutlet weak var kalappLogoImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.backgroundView.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: self.backgroundView.frame, andColors:[UIColor.flatLimeColorDark(), UIColor.flatForestGreen()])
        loginButton.backgroundColor = .flatYellow()
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
//        okulNoTextField.layer.addSublayer(borderBir)
//        sifreTextField.layer.addSublayer(borderIki)
//    
//        updateBorder(border: borderBir, textField: okulNoTextField, color: UIColor.white, width: 2.0)
//        updateBorder(border: borderIki, textField: sifreTextField, color: UIColor.white, width: 2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateBorder(border: CALayer, textField: UITextField, color: UIColor, width: CGFloat){
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0.0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: width);
    }

    
    //TODO: - Login
    
    func login(okulNo: String, password: String) {
        
        startAnimating(CGSize(width: 200, height: 40), message: "Yükleniyor", type: NVActivityIndicatorType.ballRotateChase, color: UIColor.flatGreenColorDark())
        
        var loginCred : [String: String] = [:]
        loginCred["okul_no"] = "\(okulNo)"
        loginCred["pass"] = password
        loginCred["fcms_token"] = "1"
        
        Alamofire.request("http://207.154.249.115/?action=login", method: .get, parameters: loginCred).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success")
                let loginJSON : JSON = JSON(response.result.value!)
                let error = loginJSON["error"].stringValue
                
                
                if error == "true" {
                   
                    self.errorAlert = UIAlertController(title: "Hata", message: loginJSON["message"].stringValue, preferredStyle: .alert)
                    
                    self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    
                    self.errorAlert.addAction(self.action)
                    
                    self.stopAnimating()
                    
                    self.present(self.errorAlert, animated: true, completion: nil)
                }
                    
                else {
                   // Keychain set etme
                    self.loginHash = loginJSON["hash"].stringValue
                    self.defaults.set(true, forKey: "isLoggedIn")
                    self.defaults.set(self.loginHash, forKey: "hash")
                    self.keychain.set(password, forKey: "password")
                    self.keychain.set(okulNo, forKey: "id")
                    UserDefaults.standard.synchronize()
                    
                    self.okulNoTextField.text = ""
                    self.sifreTextField.text = ""
                    

                    
                    if self.defaults.string(forKey: "hash") == self.loginHash {
                        
                        self.stopAnimating()
                        self.goToMainPage()
                    
                        }
                        
                        
                    else {
                        print("error")
                        self.errorAlert = UIAlertController(title: "Hata", message: "verilerde sıkıntı yaşandı lütfen tekrar deneyin", preferredStyle: .alert)
                        
                        self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        
                        self.errorAlert.addAction(self.action)
                        
                        
                        self.stopAnimating()

                        self.present(self.errorAlert, animated: true, completion: nil)
                        
                        }
                    
                    

                    
                }
            
            }
            else {
                print("Error: \(String(describing: response.result.error))")
                self.errorAlert = UIAlertController(title: "Hata", message: "connection problems", preferredStyle: .alert)
                
                self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                
                self.errorAlert.addAction(self.action)

                self.stopAnimating()
                
                self.present(self.errorAlert, animated: true, completion: nil)
                }
        }
    }
    
    //TODO: - BUTON
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if okulNoTextField.text != "" && sifreTextField.text != ""{
            login(okulNo: "\(okulNoTextField.text!)", password: sifreTextField.text!)
        }
        else {
            print("error")
            self.errorAlert = UIAlertController(title: "Hata", message: "Lütfen bütün alanları doldurunuz", preferredStyle: .alert)
            
            self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            
            self.errorAlert.addAction(self.action)
            
            self.present(self.errorAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func userPressedGo(_ sender: UITextField) {
        if okulNoTextField.text != "" && sifreTextField.text != ""{
            login(okulNo: "\(okulNoTextField.text!)", password: sifreTextField.text!)
        }
        else {
            print("error")
        }
    }
    
    
    //TODO:- MainPage Segue
    
    func goToMainPage() {
        performSegue(withIdentifier: "goToMainPage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue , sender: Any?) {
        if segue.identifier == "goToMainPage" {
            let navC = segue.destination as! UINavigationController
            let mainVC = navC.topViewController as! MainPageViewController
            mainVC.autoLoggedIn = false
            mainVC.hashHash = loginHash
        }
    }

    //MARK: - CallLogin
    
    
    

    // MARK: - Navigation
 
    @IBAction func unwindToLogin(segue: UIStoryboardSegue){ }


}
