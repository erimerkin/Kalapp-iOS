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
    var errorAlert = UIAlertController()
    var action = UIAlertAction()
    
    //MARK: - Pull-to-Refresh
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action:
            #selector(MainPageViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refresh.tintColor = UIColor.red
        
        return refresh
    }()
    
    //MARK: - Load Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        retrieveData(index: duyuruArray.count)
        print("view did appear")
        
        
        duyuruTableView.delegate = self
        duyuruTableView.dataSource = self
        self.duyuruTableView.addSubview(self.refresh)
        refresh.beginRefreshing()
       
}

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    ///////////////////////////////////////////////////////////////////////////
    //MARK: - Network

   
    //TODO: - Retrieve Duyuru Page
    func retrieveData(index: Int){
        
        if Connectivity.isConnectedToInternet {
        
        
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
                                
                                if self.refresh.isRefreshing == true {
                                    self.refresh.endRefreshing()
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
                                    while count <= 4 && self.failure == true {
                                        count += 1
                                        self.failure = true
                                        self.retrieveData(index: self.duyuruArray.count)
                                        print(count)
                                        if count == 4 {
                                            self.goToLogin()
                                        }
                                    }

                                }
                                else {
                                    print(stringResponse.result.error!)
                                    while count <= 4 && self.failure == true {
                                        count += 1
                                        self.failure = true
                                        self.retrieveData(index: self.duyuruArray.count)
                                        print(count)
                                        if count == 4 {
                                            
                                        self.refresh.endRefreshing()
                                        }
                                }
                            }
                    }
                }
            }
        }
            else {
                print("no connection")
            
            if refresh.isRefreshing == true {
                
                refresh.endRefreshing()
                
            }
            
                self.errorAlert = UIAlertController(title: "Hata", message: "connection error", preferredStyle: .alert)
                
                self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                
                self.errorAlert.addAction(self.action)
                
                self.present(self.errorAlert, animated: true, completion: nil)

                
            }
    }
    
    /////////////////////////////////////////////////
    //MARK: - TableView
    
    
    //TODO: - numbersOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    //TODO: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == duyuruArray.count - 1 { retrieveData(index: duyuruArray.count)} else { print("out of stock")}
        
        let cell = duyuruTableView.dequeueReusableCell(withIdentifier: "customDuyuruTableViewCell", for: indexPath) as! DuyuruTableViewCell
        
        if duyuruArray.count != 0 {
        
        cell.userNameLabel.text = duyuruArray[indexPath.section].userName
        // cell.contentDate.text = duyuruArray[indexPath.section].postDate
        cell.titleLabel.text = duyuruArray[indexPath.section].postTitle
        cell.contentLabel.text = duyuruArray[indexPath.section].postTitle
        
        cell.userImageView.layer.cornerRadius = 24
        cell.userImageView.layer.masksToBounds = true
        
        cell.cellView.layer.cornerRadius = 12
        cell.userImageView.layer.masksToBounds = true 
            
        if duyuruArray[indexPath.section].contentImg == "nil" {

           cell.contentImageView.isHidden = true
        
        }
        else {
        
            print("resimli cell yükleniyor")
            cell.contentImageView.sd_setImage(with: URL(string: duyuruArray[indexPath.section].contentImgURL))
            
        }
        }
        else {
                self.retrieveData(index: duyuruArray.count)
        }
            configureTableView()

            return cell
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return duyuruArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 4))
        view.backgroundColor = .flatWhite()
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    
    //TODO: - AUTO-RESIZE
    func configureTableView() {
        
        //        cell.boxView.layer.cornerRadius = 25
        //        cell.boxView.layer.masksToBounds = true
        
        duyuruTableView.rowHeight = UITableViewAutomaticDimension
        duyuruTableView.estimatedRowHeight = 300
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////
    
    
    
    //MARK: - goToLogin
    
    func goToLogin(){
        performSegue(withIdentifier: "goToLogin", sender: self)
    }

    //MARK: - HandleRefresh
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        duyuruArray.removeAll()
        retrieveData(index: 0)
        
    }



}



    
class DuyuruTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    
    
}

