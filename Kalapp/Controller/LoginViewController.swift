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
        self.navigationController?.isNavigationBarHidden = false
        view.endEditing(true)
    }
}


class LoginViewController: UIViewController{

    let keychain = KeychainSwift(keyPrefix: "user_")
    let defaults = UserDefaults.standard
    var loginHash = ""
    var errorAlert = UIAlertController()
    var action = UIAlertAction()
    var loading = UIView()

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
        
    }


    //TODO: - Login
    
    func login(okulNo: String, password: String) {
        
        loading = LoadingView().showActivityIndicatory(uiView: self.view)
        
        self.view.addSubview(loading)
        
        var loginCred : [String: String] = [:]
        loginCred["okul_no"] = "\(okulNo)"
        loginCred["pass"] = password
        loginCred["fcms_token"] = "1"
        
        Alamofire.request("https://kadikoyanadoluapp.com/?action=login", method: .get, parameters: loginCred).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success")
                let loginJSON : JSON = JSON(response.result.value!)
                let error = loginJSON["error"].stringValue
                
                
                if error == "true" {
                   
                    self.alert(baslik: "Hata", message: loginJSON["message"].stringValue)
                    
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
                        
                        self.loading.removeFromSuperview()
                        self.goToMainPage()
                    
                    } else {

                        self.alert(baslik: "Hata", message: "Sunucudan alınan verilerde sıkıntı yaşandı, lütfen tekrar giriş yapınız")
                        
                        }
                    
                  
                }
            
            }
            else {
                print("Error: \(String(describing: response.result.error))")
                
                self.alert(baslik: "Hata", message: "Sunuculara olan bağlantıda sıkıntı yaşandı, lütfen bağlantınızı kontrol edin.")
                
                }
        }
    }
    
    //TODO: - BUTON
    
    @IBAction func buttonPressed(_ sender: UIButton) {

        next()
        
    }
    
    @IBAction func userPressedGo(_ sender: UITextField) {
        next()
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

    //MARK: - Go
    
    func next() {
        if okulNoTextField.text != "" && sifreTextField.text != ""{
            login(okulNo: "\(okulNoTextField.text!)", password: sifreTextField.text!)
        }
        else {
            alert(baslik: "Hata", message: "Lütfen okul numaranız ve şifrenizi eksiksiz doldurunuz.")
        }
    }
    
    //MARK: - Error
    
    func alert(baslik: String, message: String) {
        
        loading.removeFromSuperview()
        
        errorAlert = UIAlertController(title: baslik, message: message, preferredStyle: .alert)
        
        action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        
        errorAlert.addAction(self.action)
        
        present(self.errorAlert, animated: true, completion: nil)
    }
    

    // MARK: - Navigation
 
    @IBAction func unwindToLogin(segue: UIStoryboardSegue){ }


}
