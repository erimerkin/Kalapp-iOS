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
import SDWebImage

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var duyuruTableView: UITableView!
    
    var duyuruArray = [Duyuru]()
    let frbToken = 1
    let keychain = KeychainSwift(keyPrefix: "user_")
    var userHash = ""
    var isDataFinished = false
    var hashHash = ""
    var failure = false
    var autoLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        retrieveData(index: duyuruArray.count)
        print("view did appear")
        duyuruTableView.delegate = self
        duyuruTableView.dataSource = self


        
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    ///////////////////////////////////////////////////////////////////////////
    //MARK: - Network

   
    //TODO: - Retrieve Duyuru Page
    func retrieveData(index: Int){
        
        
        var params : [String : Any] = [:]
        params["s"] = index
        params["f"] = index + 5
        var count = 0
        
        if autoLoggedIn == false && hashHash != "" {
            params["hash"] = hashHash
        }
        else if let loginHash = UserDefaults.standard.string(forKey: "hash") {
        params["hash"] = loginHash
        }
        else {
            goToLogin()
        }


        Alamofire.request("http://kalapp.kalfest.com/?action=duyuru", method: .get, parameters: params).responseJSON
            { response in
                        if response.result.isSuccess {
                            let responseJSON : JSON = JSON(response.result.value!)
                            print(responseJSON)
                            
                         for i in 0...(responseJSON.arrayValue.count - 1) {
                                let duyuru = Duyuru()
                            
                            if responseJSON[i]["id"].intValue != 0 {
                                duyuru.postText = responseJSON[i]["content"].stringValue
                                duyuru.postDate = responseJSON[i]["date"].stringValue
                                duyuru.postTitle = responseJSON[i]["title"].stringValue
                                duyuru.userName = responseJSON[i]["yazar"].stringValue
                                duyuru.userImgURL = responseJSON[i]["img_url"].stringValue
                                duyuru.postId = responseJSON[i]["id"].intValue
                                
                                
                                if responseJSON[i]["content_img"].stringValue.isEmpty == true {
                                    duyuru.contentImg = "nil"
                                    print(duyuru.contentImg)
                                }
                                else {
                                    duyuru.contentImg = responseJSON[i]["content_img"].stringValue
                                    print("image link got")
                                }
                                self.duyuruArray.append(duyuru)
                                self.duyuruTableView.reloadData()
                                
                            }
                            else {
                                self.isDataFinished = true
                            }
                           
                            }
                    }
                        else {
                            Alamofire.request("http://kalapp.kalfest.com/?action=duyuru", method: .get, parameters: params).responseString  { stringResponse in
                                if stringResponse.result.isSuccess {
                                    print(stringResponse.result.value!)
                                    while count <= 3 && self.failure == true {
                                        count += 1
                                        self.failure = true
                                        self.retrieveData(index: self.duyuruArray.count)
                                        print(count)
                                        if count == 3 {
                                            self.goToLogin()
                                        }
                                    }

                                }
                                else {
                                    print(stringResponse.result.error!)
                                }
                            }
                    }
                }
            }
    
    /////////////////////////////////////////////////
    //MARK: - TableView
    
    
    //TODO: - numbersOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return duyuruArray.count
    }
    
    
    //TODO: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == duyuruArray.count - 1 { retrieveData(index: duyuruArray.count)}
        
        if duyuruArray[indexPath.row].contentImg == "nil"  {
            let cell = duyuruTableView.dequeueReusableCell(withIdentifier: "customDuyuruTableViewCell", for: indexPath) as! DuyuruTableViewCell
        //        cell.userImageView.sd_setImage(with: URL(string: duyuruArray[number].userImgURL))
        //        cell.userImageView.layer.cornerRadius = 24
        //        cell.userImageView.layer.masksToBounds = true
            cell.userName.text = duyuruArray[indexPath.row].userName
            cell.contentDate.text = duyuruArray[indexPath.row].postDate
            cell.contentTitle.text = duyuruArray[indexPath.row].postTitle
            cell.contentContext.text = duyuruArray[indexPath.row].postTitle
            
            configureTableView()
            return cell
        }
        else {
            let imagedCell = duyuruTableView.dequeueReusableCell(withIdentifier: "customImagedDuyuruTableViewCell", for: indexPath) as! ImagedDuyuruTableViewCell
            print("resimli cell yükleniyor")
            imagedCell.contentImage.sd_setImage(with: URL(string: duyuruArray[indexPath.row].contentImgURL))
            imagedCell.userName.text = duyuruArray[indexPath.row].userName
            imagedCell.contentDate.text = duyuruArray[indexPath.row].postDate
            imagedCell.contentTitle.text = duyuruArray[indexPath.row].postTitle
            imagedCell.contentContext.text = duyuruArray[indexPath.row].postTitle

            configureTableView()
            return imagedCell
        }
        

        
    }
    
    //TODO: - AUTO-RESIZE
    func configureTableView() {
        
        //        cell.boxView.layer.cornerRadius = 25
        //        cell.boxView.layer.masksToBounds = true
        
        duyuruTableView.rowHeight = UITableViewAutomaticDimension
        duyuruTableView.estimatedRowHeight = 300
    }
    
    //MARK: - goToLogin
    
    func goToLogin(){
        performSegue(withIdentifier: "goToLogin", sender: self)
    }

   
  
}
    
    
    
 class DuyuruTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var contentContext: UILabel!
    @IBOutlet weak var contentDate: UILabel!

    
    
}

class ImagedDuyuruTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var contentDate: UILabel!
    @IBOutlet weak var contentContext: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    
    
    
}

