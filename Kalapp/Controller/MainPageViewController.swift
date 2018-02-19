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



class MainPageViewController: UITableViewController {

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
    var isRefreshing = false
    
    //MARK: - Pull-to-Refresh


    
    //MARK: - Load Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        retrieveData(index: duyuruArray.count)
        print("view did appear")
        
        refreshControl?.tintColor = UIColor.flatWhite()
        

       
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
                                var duyuru = Duyuru()
                            print(i)
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
                                } else {
                                    duyuru.contentImg =  responseJSON[i]["content_img"].stringValue
                                    print("image link got")
                                    print(duyuru.contentImg)
                                    duyuru.isThereImage = true
                                }
                                
                                

                                
                                self.duyuruArray.append(duyuru)

                                    print("data received successfully")
                                    
                                    

                                    
                                if self.refreshControl?.isRefreshing == true {
                                    self.refreshControl?.endRefreshing()
                                    self.isRefreshing = false
    
                                }
                                self.duyuruTableView.reloadData()
                                
                            }
                                
                        //DATA IS FINISHED
                            else {
                                self.isDataFinished = true
                                print("data is finished")
                            }
                           
                            }
                    }
                        //ERROR ALINDIĞINDA SORUNUN HASHTE OLUP OLMADIĞI
                        else {
                            Alamofire.request("http://kalapp.kalfest.com/?action=duyuru", method: .get, parameters: params).responseString  { stringResponse in
                                if stringResponse.result.isSuccess {
                                    if stringResponse.result.value! == "You are not allowed to access this page!" {
                                        
                                        if self.refreshControl?.isRefreshing == true {
                                            self.refreshControl?.endRefreshing()
                                        }
                                            self.goToLogin()
                                        
                                        }
                                    }
                        //ERROR HASHLA ALAKALI DEĞİL(CONNECTION VS.)
                                else {
                                    print(stringResponse.result.error!)
                                    if self.refreshControl?.isRefreshing == true {
                                        self.refreshControl?.endRefreshing()
                                        
                                        let errorLabel = ErrorLabel()
                                        
                                        errorLabel.initializeLabel(content: "Bağlantı Hatası")
                                        self.view.addSubview(errorLabel)
                                    }
                                }
                    }
                }
            }

        }
            
            // IF THERE IS NO INTERNET CONNECTION:
            
            else {
                print("no connection")
            
            if refreshControl?.isRefreshing == true {
                
                refreshControl?.endRefreshing()
                
                }
            
//                self.errorAlert = UIAlertController(title: "Hata", message: "connection error", preferredStyle: .alert)
//
//                self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
//
//                self.errorAlert.addAction(self.action)
//
//                self.present(self.errorAlert, animated: true, completion: nil)
            
            let errorLabel = ErrorLabel()
            
            errorLabel.initializeLabel(content: "Connection Error")
            view.addSubview(errorLabel)

                
            }
    }
    
    /////////////////////////////////////////////////
    //MARK: - TableView

    
    //TODO: - CELL SPAWN
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //CHECK IF IT IS LAST ROW
        if indexPath.section == duyuruArray.count - 1 { retrieveData(index: duyuruArray.count)}
        
        let titleColor = UIColor.flatForestGreenColorDark()
        let userColor = UIColor.flatForestGreen()

        //CHECK IF WE GOT ENOUGH DATA FROM API TO DISPLAY CELLS
        if duyuruArray.count != 0 {

            
            //CHECK IF THE CELL SHOULD HAVE A IMAGE
            print("test: \(indexPath.section)")
            if duyuruArray[indexPath.section].contentImg != "nil" && duyuruArray[indexPath.section].isThereImage == true {
                
                let imagedCell = duyuruTableView.dequeueReusableCell(withIdentifier: "customDuyuruTableViewCell", for: indexPath) as! DuyuruTableViewCell
                
                imagedCell.userNameLabel.textColor = userColor
                imagedCell.titleLabel.textColor = titleColor
                
                imagedCell.userNameLabel.text = duyuruArray[indexPath.section].userName
                // cell.contentDate.text = duyuruArray[indexPath.section].postDate
                imagedCell.titleLabel.text = duyuruArray[indexPath.section].postTitle
                imagedCell.contentLabel.text = duyuruArray[indexPath.section].postTitle
                
                
                imagedCell.userImageView.layer.cornerRadius = 24
                imagedCell.userImageView.layer.masksToBounds = true
                
                imagedCell.cellView.layer.cornerRadius = 12
                imagedCell.cellView.layer.masksToBounds = true
                
//
//                getImage(url: duyuruArray[indexPath.section].contentImg, imageView: imagedCell.contentImageView, path: indexPath.section)
                
                imagedCell.contentImageView.af_setImage(withURL: URL(string: duyuruArray[indexPath.section].contentImg)!, placeholderImage: UIImage(named: "profileDefault.png"), filter: AspectScaledToFitSizeFilter(size: imagedCell.contentImageView.frame.size), imageTransition: UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: false){

                        response in
                            // Check if the image isn't already cached
                            if response.response != nil {
                                // Force the cell update
                                
                                self.duyuruTableView.beginUpdates()
                                self.duyuruTableView.endUpdates()

                        }
                    }
                

                configureTableView()
                
                return imagedCell
            } else {
                
                let cell = duyuruTableView.dequeueReusableCell(withIdentifier: "customImagedDuyuruTableViewCell", for: indexPath) as! DuyuruTableViewCell
                
                cell.userNameLabel.textColor = userColor
                cell.titleLabel.textColor = titleColor
                
                cell.userNameLabel.text = duyuruArray[indexPath.section].userName
                // cell.contentDate.text = duyuruArray[indexPath.section].postDate
                cell.titleLabel.text = duyuruArray[indexPath.section].postTitle
                cell.contentLabel.text = duyuruArray[indexPath.section].postTitle
            
                
                cell.userImageView.layer.cornerRadius = 24
                cell.userImageView.layer.masksToBounds = true
                
                cell.cellView.layer.cornerRadius = 12
                cell.cellView.layer.masksToBounds = true
                
                cell.cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
                cell.cellView.layer.shadowColor = UIColor.flatBlack().cgColor
                cell.cellView.layer.shadowRadius = 4
                cell.cellView.layer.shadowOpacity = 0.25
                cell.cellView.layer.masksToBounds = true;
                cell.cellView.clipsToBounds = true;
                
                
                configureTableView()
                
                return cell
            
            }
            
            
            }
            
        //IF THERE IS NOT ENOUGH DATA TRY AGAIN
        else {
                let cell = UITableViewCell()
            
                self.retrieveData(index: duyuruArray.count)
            
            
                configureTableView()
            
                return cell
            
        }

    
    }
    
    
    //MARK: - HOW MANY SECTIONS SHOULD TABLEVIEW HAVE(POST SAYISI)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return duyuruArray.count
    }
    
    
    
    //TODO: - HOW MANY ROWS SHOULD BE IN A SECTION
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
//    //MARK: - FOOTER CREATION AND SPECS
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        
//        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 4))
//        view.backgroundColor = .white
//        
//        return view
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 2))
//        view.backgroundColor = .white
//        
//        return view
//    }
    
    
//    //MARK: - FOOTER HEIGHT
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 4
//    }
//
    
    //MARK: - AUTO-RESIZE
    func configureTableView() {
        
        duyuruTableView.rowHeight = UITableViewAutomaticDimension

    }
    
    
    /////////////////////////////////////////////////////////////////////////////////
    
    
    
    //MARK: - LOGIN SEGUE
    
    func goToLogin(){
        performSegue(withIdentifier: "goToLogin", sender: self)
    }

    //MARK: - REFRESH FUNCTION
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {

        if isRefreshing != true {
        duyuruArray.removeAll()
        isDataFinished = false
        isRefreshing = true
        retrieveData(index: duyuruArray.count)
        }
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
//                    let imageHeight = image.size.height
//                    imageView.frame.size.height = imageHeight
//
//                    imageView.image = image
////                    self.duyuruTableView.beginUpdates()
////                    self.duyuruTableView.endUpdates()
//                }
//            }
//
//            else {
//                print(response.result.error!)
//            }
//            }
//        }

    
    
    @IBAction func refreshControl(_ sender: UIRefreshControl) {
        
        if isRefreshing == false {
        duyuruArray.removeAll()
        duyuruTableView.reloadData()
        if duyuruArray.count == 0 {
        isRefreshing = true
        retrieveData(index: duyuruArray.count)
        }
    }
    }
    }


//MARK: - CELL SPECS

class DuyuruTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var shadowLayer: ShadowView!

    
}


