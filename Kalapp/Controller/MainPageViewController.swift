//
//  ViewController.swift
//  Kalapp
//
//  Created by Arkhin on 30.01.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var duyuruTableView: UITableView!
    
    var duyuruArray = [Duyuru]()
    let frbToken = 1
    let keychain = KeychainSwift(keyPrefix: "user_")
    var userHash = UserDefaults.standard.string(forKey: "hash")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        duyuruTableView.delegate = self
        duyuruTableView.dataSource = self
        
        duyuruTableView.register(UINib(nibName: "DuyuruTableViewCell", bundle: nil), forCellReuseIdentifier: "customDuyuruTableViewCell")
        
        retrieveData(loginHash: userHash!, index: 0)
        configureTableView()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 /////////////////////////////////////////////////
    //MARK: - TableView
    
    
    //TODO: - numbersOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return duyuruArray.count
    }
    
    
    //TODO: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = duyuruTableView.dequeueReusableCell(withIdentifier: "customDuyuruTableViewCell", for: indexPath) as! DuyuruTableViewCell
        
//        cell.senderUsername.text = duyuruArray.userName[indexPath.row]
//        cell.messageBody.text = duyuruArray.content[indexPath.row]
        

        
        updateTableViewCell(param: duyuruArray, cell: cell, number: indexPath.row)
        configureTableView()
        return cell

    }
    
    //TODO: - Seperator
    
   
    //TODO: - AUTO-RESIZE
    func configureTableView() {
        
        duyuruTableView.rowHeight = UITableViewAutomaticDimension
        duyuruTableView.estimatedRowHeight = 300
    }
    
    //TODO: - updateTableViewCell
    
    func updateTableViewCell(param: [Duyuru], cell : DuyuruTableViewCell, number: Int) {
//        cell.boxView.layer.cornerRadius = 25
//        cell.boxView.layer.masksToBounds = true
        
        let image = UIImage(named: "profileDefault.png")
        cell.avatarImageView.image = image
        cell.avatarImageView.layer.cornerRadius = 24
        cell.avatarImageView.layer.masksToBounds = true
        
    }

    ///////////////////////////////////////////////////////////////////////////
    //MARK: - Network

   
    //TODO: - Retrieve Duyuru Page
    func retrieveData(loginHash: String, index: Int){
        
        var params : [String : Any] = [:]
        params["hash"] = loginHash
        params["s"] = index
        params["f"] = index + 5
        
        Alamofire.request("http://kalapp.kalfest.com/?action=duyuru", method: .get, parameters: params).responseJSON
            { response in
                        if response.result.isSuccess {
                            let responseJSON : JSON = JSON(response.result.value!)
                            print(responseJSON)
                            
                         for i in 0...(responseJSON.arrayValue.count - 1) {
                                let duyuru = Duyuru()
                                duyuru.postText = responseJSON[i]["content"].stringValue
                                duyuru.postDate = responseJSON[i]["date"].stringValue
                                duyuru.contentImg = responseJSON[i]["content_img"].stringValue
                                duyuru.postTitle = responseJSON[i]["title"].stringValue
                                duyuru.userName = responseJSON[i]["yazar"].stringValue
                                duyuru.userImgURL = responseJSON[i]["img_url"].stringValue
                                duyuru.postId = responseJSON[i]["id"].intValue
                                self.duyuruArray.append(duyuru)

                            }
                    }
                        else {
                            Alamofire.request("http://kalapp.kalfest.com/?action=duyuru", method: .get, parameters: params).responseString  { stringResponse in
                                if stringResponse.result.isSuccess {
                                    print(stringResponse.result.value!)
                                    self.goToLogin()
                                }
                                else {
                                    print(stringResponse.result.error!)
                                }
                            }
                    }
                }
            }
    
    
    //MARK: - Update View
    

    //TODO: - Keychain Get
    
    func getDetails() {
        if (keychain.get("id") != nil) && (keychain.get("password") != nil) && (keychain.get("hash") != nil) {
            let userId = keychain.get("id")!
            let userPass = keychain.get("password")!
            LoginViewController().login(okulNo: userId, password: userPass, token: "1")
        }
        else {
            print("keychain couldnt get")
            goToLogin()
        }
    }
    
    
    
    //MARK: - goToLogin
    
    func goToLogin(){
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    


 
    
    
}




