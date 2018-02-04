//
//  ProfileViewController.swift
//  Kalapp
//
//  Created by Arkhin on 31.01.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework

class ProfileViewController: UIViewController {

    @IBOutlet weak var coloredView: UIView!
    
    let userHash = UserDefaults.standard.string(forKey: "hash")
    
    @IBOutlet weak var userProfileImage: UIImageView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coloredView.backgroundColor = UIColor.randomFlat()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Getting User Details
    
    func getDetails() {
        
        let params : [String: String] = ["hash" : userHash!]
        
        Alamofire.request("http://kalapp.kalfest.com/?action=user_info", method: .get, parameters: params).responseJSON { response in
            
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
                }
            }
            else {
                print("Alamofire error \(response.result.error!)")
            }
            
        }
        
        
    }


}
