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
import AlamofireImage
import CropViewController
import Photos

protocol SettingsDelegate {
    func reloadPage(result: Bool)
}


enum inputType {
    case email
    case phone
    case password
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var params = ["hash" : UserDefaults.standard.string(forKey: "hash")!]
    var delegate : SettingsDelegate?
    
    var i = 0
    var isThereImage = false
    let WEBURL = "https://kadikoyanadoluapp.com"
    
    var errorAlert = UIAlertController()
    var action = UIAlertAction()
    let details = UserDetails()
    let loading = LoadingView()
    var loader = UIView()
    var detailCell = ChangeDetailCell()
    
    //MARK: - Image Cropper Variables
    
    var imageView = UIImageView()
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.circular
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    
    //MARK:- Storyboard Outlets
    
    @IBOutlet weak var settingsTableView: UITableView!
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .flatWhite()
        getDetails()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
    }

    ///////////////////////////////////////////////////////////////////////////
    // MARK: - TABLEVIEW FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let hedefPath = indexPath.section
        
        if hedefPath == 0 {
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "userDetails") as! UserDetailCell
            let imageFilter = ScaledToSizeCircleFilter(size: cell.userImageView.frame.size)
            let name = "\(details.name) \(details.surname)"
            
            imageView = cell.userImageView
            
            
            
            if isThereImage == true {
            cell.userImageView.af_setImage(withURL: URL(string: details.imgURL)!, placeholderImage: nil, filter: imageFilter, imageTransition:UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: false, completion: nil)
            }

            cell.userNameLabel.text = name
            
            return cell
            
        } else if hedefPath ==  1 {
            detailCell = settingsTableView.dequeueReusableCell(withIdentifier: "details") as! ChangeDetailCell
            return detailCell
        
        } else {
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "buttons")!
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
 

    //MARK: - Change Button Activation
    
    func sendRequest() {
        
        let email = detailCell.emailTextField.text
        let phone = detailCell.phoneTextField.text
        let oldPass = detailCell.oldPassTextField.text
        let newPass = detailCell.newPassTextField.text
        
        if email != ""  {
            print("dolu")

            if validate(content:email!, key: .email) == true {
                
                params = ["value" : email!]
                params = ["key" : "email"]
                print("true ver")
                changeUserDetails(details: params)
                
            } else {
            //some error type?
                print("false ver")
            }
            
        } else {
            print("empty")
        }
        
        if phone != "" {
//            changeUserDetails(details: ["telefon" : detailCell.phoneTextField.text!])
            print("wuttafak")
        }
        
    

    }
    
    //MARK: - Verification
    
    func validate(content:String, key: inputType) -> Bool {
        
        switch key {
            
        case .email:
            let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
            return emailPredicate.evaluate(with: content)
            
        case .phone:
            return false
            
        case .password:
            if content.count >= 6 {
                return true
            } else {
                return false
            }
            
        default:
            return false
        }
        
        
    }
    
    //MARK: - Getting User Details
    
    func getDetails() {
        
        Alamofire.request("\(WEBURL)/?action=user_info", method: .get, parameters: params).responseJSON { response in
            
            if response.result.isSuccess {
                let resultJSON = JSON(response.result.value!)
                
                if resultJSON["valid"] == true {
                    
                    self.details.name = resultJSON["ad"].stringValue
                    self.details.surname = resultJSON["soyad"].stringValue
                    
                    if resultJSON["img_url"].stringValue.isEmpty == true {
                        self.isThereImage = false
                    } else {
                        self.isThereImage = true
                        self.details.imgURL = resultJSON["img_url"].stringValue
                    }
                    
                    self.settingsTableView.reloadData()
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
     
      
        Alamofire.request("\(WEBURL)/?action=update_user", method: .get, parameters: details).responseString {
            response in
                
                if response.result.isSuccess {
                    print("success for now")
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                        print(response.result.error!)
                    
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
    
    //MARK: - Update Profile Pic
    
    func updatePic(code: String) {
        
        addLoading()

        Alamofire.request("\(WEBURL)/?action=", method: .get, parameters: params).responseJSON {
            response in
            
            if response.result.isSuccess {
                
            } else {
                
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
//        navigationController?.popViewController(animated: true)
//        self.delegate?.reloadPage(result: true)
//        self.view.addSubview(LoadingView().load())
        
        addLoading()
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout()
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    @IBAction func changePhotoButtonPressed(_ sender: UIButton) {
        
        let profileAction = UIAlertAction(title: "Kütüphaneden Seç", style: .default) { (action) in
            self.croppingStyle = .circular
            let imagePicker = UIImagePickerController()
            imagePicker.modalPresentationStyle = .popover
            imagePicker.preferredContentSize = CGSize(width: 320, height: 568)
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let alertController = UIAlertController()
        
        alertController.addAction(profileAction)
        alertController.modalPresentationStyle = .popover
        
        present(alertController, animated: true, completion: nil)
     
    }
    

    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        cropController.doneButtonTitle = "Kaydet"
        cropController.cancelButtonTitle = "İptal"
        
        self.image = image
        
        picker.pushViewController(cropController, animated: true)
        
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        
        let imageData : Data =  UIImagePNGRepresentation(image)!
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        addLoading()
        imageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
    
    
    func addLoading() {
        
        loader = loading.showActivityIndicatory(uiView: self.view)
        self.view.addSubview(loader)
        
    }
    
    

    
}

class UserDetailCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
}

class ChangeDetailCell: UITableViewCell {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var oldPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var repeatPassTextField: UITextField!
    
}

