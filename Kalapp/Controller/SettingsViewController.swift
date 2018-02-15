//
//  SettingsViewController.swift
//  Kalapp
//
//  Created by Arkhin on 31.01.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework

protocol SettingsDelegate {
    func reloadPage(result: Bool)
}

class SettingsViewController: UIViewController {
    
    var params : [String : String] = ["hash" : UserDefaults.standard.string(forKey: "hash")!]
    var delegate : SettingsDelegate?
    
    var userName = ""
    var userPhoto = ""
    var userClass = ""
    
    var errorAlert = UIAlertController()
    var action = UIAlertAction()
    
    //MARK:- Storyboard Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var oldPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var passwordRepeatLabel: UILabel!
    @IBOutlet weak var oldPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var passRepeatTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        view.backgroundColor = .flatWhite()
    }


    //MARK: - Change Button Activation
    
    func sendRequest() {
        
        if emailTextField.text != "" {
            params["key"] = "email"
            params["value"] = "\(emailTextField.text!)"
            
            changeUserDetails(details: params)
        }
        else if phoneTextField.text != "" {

            params["key"] = "telefon"
            params["value"] = "\(phoneTextField.text!)"
            
            changeUserDetails(details: params)
        }
        else if oldPassTextField.text! != "" && newPassTextField.text! != "" && passRepeatTextField.text! != "" && newPassTextField.text! == passRepeatTextField.text! && oldPassTextField.text! != newPassTextField.text! {
        
            params["key"] = "password"
            params["value"] = "\(oldPassTextField.text!),\(newPassTextField.text!),\(passRepeatTextField.text!)"
        
            changeUserDetails(details: params)
        }
        else {
            
    }
    }

    //MARK: - Setting Networking Code
    
    func changeUserDetails(details: [String : String]) {
     
      
        Alamofire.request("kalapp.kalfest.com/?action=update_user", method: .get, parameters: details).responseJSON {
            response in
                
                if response.result.isSuccess {
                    print("success for now")
                }
                else {
                        print("error")
                    
                    self.errorAlert = UIAlertController(title: "Hata", message: "hata", preferredStyle: .alert)
                    
                    self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    
                    self.errorAlert.addAction(self.action)
                    
                    self.present(self.errorAlert, animated: true, completion: nil)
                }
               
                
                
            }
        }
    
    //MARK: - Logout
    
    func logout() {
        let defaults = UserDefaults.standard       
        defaults.set(false, forKey: "isLoggedIn")
        defaults.removeObject(forKey: "hash")
        defaults.synchronize()
        
    }
    
    
    //MARK: - Buttons

    @IBAction func completedButtonPressed(_ sender: UIBarButtonItem) {
        sendRequest()
        navigationController?.popViewController(animated: true)
        self.delegate?.reloadPage(result: true)
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout()
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
}
