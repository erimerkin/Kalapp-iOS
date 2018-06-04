//
//  AnketlerViewController.swift
//  Kalapp
//
//  Created by Arkhin on 31.01.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework
import AlamofireImage

class AnketlerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var anketArray : [Anket] = [Anket]()
    var params : [String : String] = ["hash" : UserDefaults.standard.string(forKey: "hash")!]
    var currentAnketId = ""
    var currentAnketTitle = ""
    var activity = UIActivityIndicatorView()
    
    //ALERT THINGY
    
    let alert = AlertCreation()
    var backgroundError = UIView()
    var popupError = UIView()
    
    @IBOutlet weak var anketTableView: UITableView!
    
    //MARK: - Pull-to-Refresh
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action:
            #selector(handleRefresh(_:)),
                          for: UIControlEvents.valueChanged)
        refresh.tintColor = UIColor.gray
        
        
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activity.activityIndicatorViewStyle = .whiteLarge
        activity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activity.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2 - 100)
        activity.tintColor = .gray
        
        self.view.addSubview(activity)
        activity.startAnimating()
        anketTableView.delegate = self
        anketTableView.dataSource = self
        self.anketTableView.addSubview(self.refresh)
        
        anketGetir(index: anketArray.count)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Retrieve Data
    
    func anketGetir(index: Int) {
        params["s"] = String(index)
        params["f"] = String(index + 5)
        
        Alamofire.request("https://kadikoyanadoluapp.com/?action=anket&do=anketleri_getir", method: .get, parameters: params).responseJSON { response in
            
            if response.result.isSuccess {
                let anketJSON : JSON = JSON(response.result.value!)
                print(anketJSON)
                
                if anketJSON["valid"] != false {
                for i in 0...(anketJSON.arrayValue.count - 1) {
                    
                    let anket = Anket()
                    
                    if anketJSON[i]["id"].intValue != 0 {
                    anket.anketDate = anketJSON[i]["date"].stringValue
                    anket.anketId = anketJSON[i]["id"].stringValue
                    anket.anketImg = anketJSON[i]["img_url"].stringValue
                    anket.anketIsVoted = anketJSON[i]["voted"].intValue
                    anket.anketTitle = anketJSON[i]["title"].stringValue
                    anket.anketYazar = anketJSON[i]["yazar"].stringValue
                    
                   self.stopRefresh()
                     
                        if anket.anketIsVoted == 1 {
                            self.anketArray.insert(anket, at: 0)
                            self.anketTableView.reloadData()
                        } else {
                            self.anketArray.append(anket)
                            self.anketTableView.reloadData()
                        }
                    }
                }
            }
                else {                
                    
                    self.stopRefresh()
                    self.error(message: "Verilerin alınmasında bir sıkıntı yaşandı lütfen tekrar deneyin.")
                    
                }
            }
            else {
                print("anket get error: \(response.result.error!)")
                self.stopRefresh()
                self.error(message: "Sunuculara bağlanırken bir sıkıntı oluştu.")
                
            }
        }
    }
    
    

    //*****************************************************
    //MARK: - TableView
    //*****************************************************
    
    //TODO: - Row sayısı
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anketArray.count
        
    }
    
    
    //TODO: - Cell respawn
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == anketArray.count - 1 { anketGetir(index: anketArray.count)}
        
        let cell = anketTableView.dequeueReusableCell(withIdentifier: "customAnketTableViewCell", for: indexPath) as! AnketTableViewCell
        
        if anketArray.count != 0 {
        let path = indexPath.row
        let anket = anketArray[path]
            
        let imageFilter = AspectScaledToFillSizeCircleFilter(size: cell.anketImageView.frame.size)
            
        cell.anketContentView.layer.cornerRadius = 12
        cell.anketContentView.layer.masksToBounds = true
            
        cell.titleLabel.text = anket.anketTitle
        cell.userLabel.text = anket.anketYazar

        cell.anketImageView.layer.cornerRadius = 24
        cell.anketImageView.layer.masksToBounds = true
        cell.anketImageView.af_setImage(withURL: URL(string: anket.anketImg)!, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: false)

        
        if anketArray[path].anketIsVoted == 1 {
            let textColour = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.697128081)
            cell.indicatorLabel.text = "SONUÇLAR"
            cell.titleLabel.textColor = textColour
            cell.userLabel.textColor = textColour
            cell.anketImageView.alpha = 0.7
            cell.shadowView.lowShadow()
        }
        else {
            cell.shadowView.setupShadow()
        }
        }
        
        else {
            self.anketGetir(index: anketArray.count)
        }
        
        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 4))
//        view.backgroundColor = nil
//
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 8
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("test")
        
        currentAnketId = anketArray[indexPath.row].anketId
        currentAnketTitle = anketArray[indexPath.row].anketTitle

        anketTableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "showAnket", sender: self)


    }
   
        /////////////////////////////////////////////////////////////////////////
    
    
    //MARK: - AnketId'si aktarıldı
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnket" {
            
            let firstVC = segue.destination as! AnketViewController
            firstVC.postId = currentAnketId
            firstVC.postTitle = currentAnketTitle
        }
    }

    
    //MARK: - HandleRefresh
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        anketArray.removeAll()
        anketTableView.reloadData()
        anketGetir(index: anketArray.count)
        
    }
    
    
    //MARK: - STOP REFRESH
    func stopRefresh() {
        if refresh.isRefreshing == true {
            refresh.endRefreshing()
        }
        if activity.isAnimating == true {
            activity.stopAnimating()
        }
    }

    //MARK: - GİVE SOME ERROR BEYBE
    
    func error(message: String){
        if alert.isShowing() == false {
            if anketArray.isEmpty == true {
            backgroundError = alert.backgroundError(errorMessage: message, VC: self)
            self.view.addSubview(backgroundError)
            }
            backgroundError.removeFromSuperview()
            alert.animateAlert(errorMessage: message, VC: self)
        }
    }
    
    //END OF CLASS
}

class AnketTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var anketContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var anketImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var indicatorLabel: UILabel!
    
    @IBOutlet weak var shadowView: ShadowView!
    
}
