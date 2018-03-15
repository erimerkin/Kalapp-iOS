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
    @IBOutlet weak var refresher: UIRefreshControl!
    
    //DETAILS FOR CONNECTION
    var duyuruArray = [Duyuru]()
    let frbToken = 1
    let keychain = KeychainSwift(keyPrefix: "user_")
    var userHash = ""
    var hashHash = ""
	let adress = "http://kadikoyanadoluapp.com"
    
    
    //CHECKING VALUES
    var isDataFinished = false
    var failure = false
    var autoLoggedIn = false
    var isRefreshing = false
    var isShowingError = false
    
    //INIT
    var errorAlert = UIAlertController()
    var action = UIAlertAction()
    var alert = AlertCreation()
    var alertView = ErrorPopup()
    var errorLabel = ErrorLabel()
    let activity = UIActivityIndicatorView()
        
    //MARK: - Pull-to-Refresh


    
    //MARK: - Load Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        retrieveData(index: duyuruArray.count)
        print("view did appear")
        
        refresher.tintColor = UIColor.flatWhite()
        duyuruTableView.addSubview(refresher)
        
        
        activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activity.activityIndicatorViewStyle = .gray
        activity.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2 - 100)
        self.view.addSubview(activity)
        activity.startAnimating()
       
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
            
            alertView.removeFromSuperview()
            

            Alamofire.request("\(adress)/?action=duyuru", method: .get, parameters: params).responseJSON
                { response in
                        if response.result.isSuccess {
                            let responseJSON : JSON = JSON(response.result.value!)

							var count = responseJSON.arrayValue.count
                            
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
                                    
                                    self.duyuruTableView.reloadData()
									self.endRefreshing()

								
                            }
                                
                        //DATA IS FINISHED
                            else {
                                self.isDataFinished = true
                                print("data is finished")
								self.endRefreshing()

								
                            }
                            }
							
							
                    }
                        //ERROR ALINDIĞINDA SORUNUN HASHTE OLUP OLMADIĞI
                        else {
							Alamofire.request("\(self.adress)/?action=duyuru", method: .get, parameters: params).responseString  { stringResponse in
                                if stringResponse.result.isSuccess {
                                    if stringResponse.result.value! == "You are not allowed to access this page!" {
										
										print("hash")
										self.endRefreshing()
										
                                        self.alert.popupAlert(errorMessage: "Oturumunuzda bir sorun oluştu, devam etmek için lütfen giriş yapın.", button: "Giriş Yap", VC: self.self, completion: self.goToLogin())
                                        
                                        }
                                    }
                        //ERROR HASHLA ALAKALI DEĞİL(CONNECTION VS.)
                                else {
                                    print(stringResponse.result.error!)

									print("fatih")
									
									self.endRefreshing()
									
                                    self.alertCreate(errorMessage: "Sunuculara bağlanmada sorun yaşandı.")

                                }
                    }
                }
			

			}

        }
            
            // IF THERE IS NO INTERNET CONNECTION:
            
            else {
                print("no connection")
            
				endRefreshing()
			
//                self.errorAlert = UIAlertController(title: "Hata", message: "connection error", preferredStyle: .alert)
//
//                self.action = UIAlertAction(title: "Tamam", style: .default, handler: nil)
//
//                self.errorAlert.addAction(self.action)
//
//                self.present(self.errorAlert, animated: true, completion: nil)
            
            alertCreate(errorMessage: "Bağlantı yok, lütfen internet bağlantınızı açın.")

//            self.popupAlert(errorMessage: "İnternete bağlı değilsiniz.", button: "Tamam", completion: nil)
            
            }
    }
    
    /////////////////////////////////////////////////
    //MARK: - TableView

    
    //TODO: - CELL SPAWN
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //CHECK IF IT IS LAST ROW
        if indexPath.section == duyuruArray.count - 1 && isRefreshing == false { retrieveData(index: duyuruArray.count)}
        
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
				
				imagedCell.contentImageView.af_setImage(withURL: URL(string: duyuruArray[indexPath.section].contentImg)!, placeholderImage: UIImage(named: "profileDefault.png"), filter: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: false){

                        response in
                            // Check if the image isn't already cached
                            if response.response != nil {
                                // Force the cell update
								
								
								imagedCell.contentImageView.image = ImageResize().resizeImage(image: response.value!, targetSize: self.self.view.bounds.size)
						
								self.duyuruTableView.beginUpdates()
								self.duyuruTableView.endUpdates()
								
								let imageHeight = imagedCell.contentImageView.image?.size.height
								
								imagedCell.contentImageView.frame.size.height = imageHeight!
								


                        }
                    }
				
				imagedCell.userImageView.af_setImage(withURL: URL(string: duyuruArray[indexPath.section].userImgURL)!, placeholderImage: UIImage(named: "profileDefault.png"), filter: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: false){
					
					response in
					// Check if the image isn't already cached
					if response.response != nil {
						// Force the cell update
						
						
						imagedCell.contentImageView.image = ImageResize().resizeProfilePhoto(image: response.value!, targetSize: imagedCell.userImageView.frame.size)
						
						imagedCell.userImageView.imageFrame()
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
				
				cell.userImageView.af_setImage(withURL: URL(string: duyuruArray[indexPath.section].userImgURL)!, placeholderImage: UIImage(named: "profileDefault.png"), filter: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: false){
					
					response in
					// Check if the image isn't already cached
					if response.response != nil {
						// Force the cell update
						
						
						cell.contentImageView.image = ImageResize().resizeProfilePhoto(image: response.value!, targetSize: cell.userImageView.frame.size)
						
						cell.userImageView.imageFrame()
						self.duyuruTableView.beginUpdates()
						self.duyuruTableView.endUpdates()
						
					}
				}
                
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
	
	//MARK: - REFRESHING
	
	func endRefreshing() {
		
		refresher.endRefreshing()
		if refreshControl?.isRefreshing == true {
			refreshControl?.endRefreshing()
		}
		isRefreshing = false
		
		if activity.isAnimating {
			activity.stopAnimating()
		}
	}
	
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
//		if imageView.image == nil {
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
//                    self.duyuruArray[path].isThereImage = true
//
//
//
//                    imageView.image = self.resizeImage(image: image, targetSize: self.view.bounds.size)
//                    self.duyuruTableView.beginUpdates()
//                    self.duyuruTableView.endUpdates()
//                }
//            }
//
//            else {
//                print(response.result.error!)
//            }
//            }
//        }
//	}

	
	
    @IBAction func refreshControl(_ sender: UIRefreshControl) {
        
        if isRefreshing == false {

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.refreshSelector()
			}
        } else {
            
            refresher.endRefreshing()
        
        }
        
    }
    
    func refreshSelector() {
        
        errorLabel.removeFromSuperview()
        alertView.removeFromSuperview()
        duyuruArray.removeAll()
		duyuruTableView.reloadData()
        
        if duyuruArray.count == 0 {
            isRefreshing = true
            retrieveData(index: duyuruArray.count)
        }
    }
    
    //MARK: - ERROR LABEL CREATION
    
    func alertCreate(errorMessage: String) {
        
        if alert.isShowing() == false {
        if duyuruArray.isEmpty == true {
            
            errorLabel.removeFromSuperview()
            alert.animateAlert(errorMessage: errorMessage, VC: self)
            errorLabel = alert.backgroundError(errorMessage: errorMessage, VC: self)

        } else {
            
            errorLabel.removeFromSuperview()
            alert.animateAlert(errorMessage: errorMessage, VC: self)
            
            }
        }
            
    }
    

    
//END OF CLASS
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


