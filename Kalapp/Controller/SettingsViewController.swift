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
    
    let userHash = UserDefaults.standard.string(forKey: "hash")
    var i = 0
    let WEBURL = "http://kadikoyanadoluapp.com"
    
    var errorAlert = UIAlertController()
    var action = UIAlertAction()
    
    //MARK:- Storyboard Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var oldPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var passRepeatTextField: UITextField!
    
    @IBOutlet weak var userDetailView: UIView!
    @IBOutlet weak var changeDetailsView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        view.backgroundColor = .flatWhite()

        corners(view: userDetailView)
        corners(view: changeDetailsView)
        corners(view: logoutView)
        
    }


    //MARK: - Change Button Activation
    
    func sendRequest() {
        
        guard emailTextField.text == "" || emailTextField.text == nil else {
            changeUserDetails(details: ["email" : emailTextField.text!])
            return
        }
        guard phoneTextField.text == "" || phoneTextField.text == nil else {
            changeUserDetails(details: ["telefon" : phoneTextField.text!])
            return
        }
        guard (oldPassTextField.text == "" || oldPassTextField.text == nil) || (newPassTextField.text == "" || newPassTextField.text == nil) || (passRepeatTextField.text == "" || passRepeatTextField.text == nil) else {
            if newPassTextField.text == "" || newPassTextField.text == nil {
                //pass error ver
            } else if passRepeatTextField.text == "" || passRepeatTextField.text == nil {
                //pass error
            } else {
//                changeUserDetails(details: [String : ])
            }
            return
        }
        
    }
    
    //MARK: - Getting User Details
    
    func getDetails() {
        
        let params : [String: String] = ["hash" : userHash!]
        
        Alamofire.request("\(WEBURL)/?action=user_info", method: .get, parameters: params).responseJSON { response in
            
            if response.result.isSuccess {
                let resultJSON = JSON(response.result.value!)
                let details = UserDetails()
                
                if resultJSON["valid"] == true {
                    
                    details.name = resultJSON["ad"].stringValue
                    details.surname = resultJSON["soyad"].stringValue
                    details.email = resultJSON["email"].stringValue
                    details.phone = resultJSON["telefon"].stringValue
                    details.userClass = resultJSON["class"].stringValue
                    details.profilePhoto = resultJSON["img_url"].stringValue
                    
                    print("true to his words ma lord")
                }
            }
            else {
                print("Alamofire error \(response.result.error!)")
                while self.i <= 3 {
                    self.getDetails()
                    self.i = self.i + 1
                }
            }
            
        }
        
    }


    //MARK: - Setting Networking Code
    
    func changeUserDetails(details: [String : String]) {
     
      
        Alamofire.request("\(WEBURL)/?action=update_user", method: .get, parameters: details).responseJSON {
            response in
                
                if response.result.isSuccess {
                    print("success for now")
                }
                else {
                        print("error")
                    
//                    self.errorAlert = UIAlertController(title: "Hata", message: "hata", preferredStyle: .alert)
//
//                    self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
//
//                    self.errorAlert.addAction(self.action)
//
//                    self.present(self.errorAlert, animated: true, completion: nil)
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
    
    //MARK: - Change Corners
    
    func corners(view: UIView) {
        
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
    }
    
    //MARK: - Buttons

    @IBAction func completedButtonPressed(_ sender: UIBarButtonItem) {
//        sendRequest()
//        navigationController?.popViewController(animated: true)
//        self.delegate?.reloadPage(result: true)
//        self.view.addSubview(LoadingView().load())
        self.view.addSubview(LoadingView().showActivityIndicatory(uiView: self.view))
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout()
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    @IBAction func changePhotoButtonPressed(_ sender: UIButton) {
        
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "goToCrop" {
                    
                    let firstVC = segue.destination as! ImageSelectorViewController
                    firstVC.imageView.image = image
                }
            }
            
        }
       performSegue(withIdentifier: "goToCrop", sender: self)

     
    }
    
    
}
