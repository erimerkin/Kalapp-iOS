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

class LoginViewController: UIViewController {

    let keychain = KeychainSwift(keyPrefix: "user_")
    let defaults = UserDefaults.standard
    var loginHash = ""
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var okulNoTextField: UITextField!
    @IBOutlet weak var sifreTextField: UITextField!
    @IBOutlet weak var kalappLogoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    //TODO: - Login
    
    func login(okulNo: String, password: String, token: String) {
        var loginCred : [String: String] = [:]
        
        loginCred["okul_no"] = "\(okulNo)"
        loginCred["pass"] = password
        loginCred["fcms_token"] = "\(token)"
        
        Alamofire.request("http://kalapp.kalfest.com/?action=login", method: .get, parameters: loginCred).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success")
                let loginJSON : JSON = JSON(response.result.value!)
                let error = loginJSON["error"].stringValue
                
                if error == "true" {
                   print(loginJSON["message"])
               
                }
                else {
                   // Keychain set etme
                    self.loginHash = loginJSON["hash"].stringValue
                    
                    self.defaults.set(self.loginHash, forKey: "hash")
                    self.defaults.set(true, forKey: "isLoggedIn")
                    self.keychain.set(password, forKey: "password")
                    self.keychain.set(okulNo, forKey: "id")
                    UserDefaults.standard.synchronize()
                    
                    if (self.defaults.string(forKey: "hash") == self.loginHash) &&  (self.defaults.bool(forKey: "isLoggedIn") == true) {
                      
                        self.goToMainPage()
                    
                    }
                    
                else {
                       
                    print("error")
                    
                    }
                }
            }
            else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    //TODO: - BUTON
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if okulNoTextField.text != "" && sifreTextField.text != ""{
            login(okulNo: "\(okulNoTextField.text!)", password: sifreTextField.text!, token: "1")
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
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
