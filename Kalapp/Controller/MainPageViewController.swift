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
import AlamofireImage


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
        
        
        //CHECKING IF INTERNET CONNECTION IS ACTIVE:
        if Connectivity.isConnectedToInternet {
        
            var params : [String : Any] = [:]
            params["s"] = index
            params["f"] = index + 5
        
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
                            
                         for i in 0...(responseJSON.arrayValue.count - 1) {
                                let duyuru = Duyuru()
                            
                        // CHECKING IF THE JSON/POST IS VALID
                            if responseJSON[i]["id"].intValue != 0 {
                                
                            //PARSING JSON
                                
                                duyuru.postText = responseJSON[i]["content"].stringValue
                                duyuru.postDate = responseJSON[i]["date"].stringValue
                                duyuru.postTitle = responseJSON[i]["title"].stringValue
                                duyuru.userName = responseJSON[i]["yazar"].stringValue
                                duyuru.userImgURL = responseJSON[i]["img_url"].stringValue
                                duyuru.postId = responseJSON[i]["id"].intValue

                                
                                // CHECKING IF THERE IS ANY IMAGE WITH POST
                                if responseJSON[i]["content_img"].stringValue.isEmpty == true {
                                    duyuru.contentImg = "nil"
                                    print(duyuru.contentImg)
                                    duyuru.isThereImage = false
                                }
                                else {
                                    duyuru.contentImg =  responseJSON[i]["content_img"].stringValue
                                    print("image link got")
                                    print(duyuru.contentImg)
                                    duyuru.isThereImage = true
                                }
                                
                                
                                if self.refresh.isRefreshing {
                                    self.refresh.endRefreshing()
                                }
                                
                                self.duyuruArray.append(duyuru)
                                self.duyuruTableView.reloadData()
                                
                            }
                                
                        //DATA IS FINISHED
                            else {
                                self.isDataFinished = true
                            }
                           
                            }
                    }
                        //ERROR ALINDIĞINDA SORUNUN HASHTE OLUP OLMADIĞI
                        else {
                            Alamofire.request("http://kalapp.kalfest.com/?action=duyuru", method: .get, parameters: params).responseString  { stringResponse in
                                if stringResponse.result.isSuccess {
                                    if stringResponse.result.value! == "You are not allowed to access this page" {
        
                                            self.goToLogin()
                                        
                                        }
                                    }
                        //ERROR HASHLA ALAKALI DEĞİL(CONNECTION VS.)
                                else {
                                    print(stringResponse.result.error!)
                                            
                                        self.refresh.endRefreshing()
                                    
                                }
                    }
                }
            }
        }
            
            // IF THERE IS NO INTERNET CONNECTION:
            
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
    
    
    
    //TODO: - CELL SPAWN
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //CHECK IF IT IS LAST ROW
        if indexPath.section == duyuruArray.count - 1 { retrieveData(index: duyuruArray.count)}
        
        let cell = duyuruTableView.dequeueReusableCell(withIdentifier: "customDuyuruTableViewCell", for: indexPath) as! DuyuruTableViewCell
        
        //CHECK IF WE GOT ENOUGH DATA FROM API TO DISPLAY CELLS
        if duyuruArray.count != 0 {

            
            cell.userNameLabel.text = duyuruArray[indexPath.section].userName
            // cell.contentDate.text = duyuruArray[indexPath.section].postDate
            cell.titleLabel.text = duyuruArray[indexPath.section].postTitle
            cell.contentLabel.text = duyuruArray[indexPath.section].postTitle
        
            
            
            cell.userImageView.layer.cornerRadius = 24
            cell.userImageView.layer.masksToBounds = true
        
            cell.cellView.layer.cornerRadius = 12
            cell.userImageView.layer.masksToBounds = true
            
            //CHECK IF THE CELL SHOULD HAVE A IMAGE
            if duyuruArray[indexPath.section].contentImg != "nil" && duyuruArray[indexPath.section].isThereImage == true {

                cell.contentImageView.isHidden = false
                
//                getImage(url: duyuruArray[indexPath.section].contentImg, imageView: cell.contentImageView, path: indexPath.section)
                
                cell.contentImageView.af_setImage(withURL: URL(string: duyuruArray[indexPath.section].contentImg)!, placeholderImage: UIImage(named: "profiledefault.png"), filter: AspectScaledToFitSizeFilter(size: cell.contentImageView.frame.size), imageTransition: UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: false){
                
                        response in
                            // Check if the image isn't already cached
                            if response.response != nil {
                                // Force the cell update
                                self.duyuruTableView.beginUpdates()
                                self.duyuruTableView.endUpdates()
                
                        }
                    }
            }
            else{
                cell.contentImageView.isHidden = true
            }
            
            
            }
            
        //IF THERE IS NOT ENOUGH DATA TRY AGAIN
        else {
                self.retrieveData(index: duyuruArray.count)
            
        }
        
        
            configureTableView()

            return cell
       
    }
    
    
    //MARK: - HOW MANY SECTIONS SHOULD TABLEVIEW HAVE(POST SAYISI)
    func numberOfSections(in tableView: UITableView) -> Int {
        return duyuruArray.count
    }
    
    
    
    //TODO: - HOW MANY ROWS SHOULD BE IN A SECTION
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //MARK: - FOOTER CREATION AND SPECS
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 4))
        view.backgroundColor = .flatWhite()
        
        return view
    }
    
    
    //MARK: - FOOTER HEIGHT
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    
    //MARK: - AUTO-RESIZE
    func configureTableView() {
        
        duyuruTableView.rowHeight = UITableViewAutomaticDimension
        duyuruTableView.estimatedRowHeight = 300
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////
    
    
    
    //MARK: - LOGIN SEGUE
    
    func goToLogin(){
        performSegue(withIdentifier: "goToLogin", sender: self)
    }

    //MARK: - REFRESH FUNCTION
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        duyuruArray.removeAll()
        retrieveData(index: duyuruArray.count)
        
    }

    
    //MARK: - Image
    
//    func getImage(url: String, imageView: UIImageView, path: Int) {
//
//
//        Alamofire.request(url).responseImage { response in
//            debugPrint(response)
//
//            print(response.request)
//            print(response.response)
//            debugPrint(response.result)
//            if response.result.isSuccess {
//
//                if let image = response.result.value {
//                    print("image downloaded: \(image)")
//                    self.duyuruArray[path].isThereImage = true
//
//                    imageView.image = image
////                    self.duyuruTableView.beginUpdates()
////                    self.duyuruTableView.endUpdates()
////                    self.duyuruTableView.reloadData()
//                }
//            }
//
//            else {
//                print(response.result.error!)
//            }
//            }
//        }
//        else {
//          
//            imageView.frame.size.height = 2
//        }

    
    }


//MARK: - CELL SPECS

class DuyuruTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    
    
}

