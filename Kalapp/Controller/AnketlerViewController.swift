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
import SDWebImage
import ChameleonFramework

class AnketlerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var anketArray : [Anket] = [Anket]()
    var params : [String : String] = ["hash" : UserDefaults.standard.string(forKey: "hash")!]
    var currentAnketId = ""
    var currentAnketTitle = ""
    
    @IBOutlet weak var anketTableView: UITableView!
    
    //MARK: - Pull-to-Refresh
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action:
            #selector(MainPageViewController.handleRefresh(_:)),
                          for: UIControlEvents.valueChanged)
        refresh.tintColor = UIColor.red
        
        
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        Alamofire.request("http://kalapp.kalfest.com/?action=anket&do=anketleri_getir", method: .get, parameters: params).responseJSON { response in
            
            if response.result.isSuccess {
                let anketJSON : JSON = JSON(response.result.value!)
                print(anketJSON)
                
                if anketJSON["valid"].isEmpty {
                for i in 0...(anketJSON.arrayValue.count - 1) {
                    
                    let anket = Anket()
                    
                    if anketJSON[i]["id"].intValue != 0 {
                    anket.anketDate = anketJSON[i]["date"].stringValue
                    anket.anketId = anketJSON[i]["id"].stringValue
                    anket.anketImg = anketJSON[i]["img_url"].stringValue
                    anket.anketIsVoted = anketJSON[i]["voted"].intValue
                    anket.anketTitle = anketJSON[i]["title"].stringValue
                    anket.anketYazar = anketJSON[i]["yazar"].stringValue
                    
                    if self.refresh.isRefreshing == true {
                            self.refresh.endRefreshing()
                    }
                        
                    self.anketArray.append(anket)
                    self.anketTableView.reloadData()
                       

                    }
                }
            }
                else {
                    print("request is not valid")
                }
            }
            else {
                print("anket get error: \(response.result.error!)")
                self.refresh.endRefreshing()
                
            }
        }
    }
    
    

    //*****************************************************
    //MARK: - TableView
    //*****************************************************
    
    //TODO: - Row sayısı
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    //TODO: - Cell respawn
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == anketArray.count - 1 { anketGetir(index: anketArray.count)}
        
        let cell = anketTableView.dequeueReusableCell(withIdentifier: "customAnketTableViewCell", for: indexPath) as! AnketTableViewCell
        
        if anketArray.count != 0 {
        
        cell.titleLabel.text = anketArray[indexPath.section].anketTitle
//        cell.timeLabel.text = anketArray[indexPath.section].anketDate
        cell.userLabel.text = anketArray[indexPath.section].anketYazar
        cell.anketImageView.sd_setImage(with: URL(string: anketArray[indexPath.section].anketImg), placeholderImage: UIImage(named: "profileDefault.png"))
        

        
//        if anketArray[indexPath.section].anketIsVoted == 1 {
//            cell.accessoryType = .checkmark
//            cell.indicatorLabel.text = "SONUÇ"
//
//        }
//        else {
//            cell.accessoryType = .disclosureIndicator
//            cell.indicatorLabel.text = "KATIL"
//        }
        }
        
        else {
            self.anketGetir(index: anketArray.count)
        }
        
        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return anketArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 4))
        view.backgroundColor = .flatWhite()
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("test")
        
        currentAnketId = anketArray[indexPath.section].anketId
        currentAnketTitle = anketArray[indexPath.section].anketTitle

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
        anketGetir(index: anketArray.count)
        
    }
    
    
    //MARK: - STOP REFRESH
    func stopRefresh() {
    if self.refresh.isRefreshing == true {
    self.refresh.endRefreshing()
    }
    }
}

class AnketTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var anketContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var anketImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var indicatorLabel: UILabel!
    
    
}
