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

class AnketlerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var anketArray : [Anket] = [Anket]()
    var params : [String : String] = ["hash" : MainPageViewController().userHash!]
    
    
    @IBOutlet weak var anketTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        anketTableView.delegate = self
        anketTableView.dataSource = self
        
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
                
                for i in 0...(anketJSON.arrayValue.count - 1) {
                    
                    let anket = Anket()
                    
                    anket.anketDate = anketJSON[i]["date"].stringValue
                    anket.anketId = anketJSON[i]["id"].stringValue
                    anket.anketImg = anketJSON[i]["img_url"].stringValue
                    anket.anketIsVoted = anketJSON[i]["voted"].intValue
                    anket.anketTitle = anketJSON[i]["title"].stringValue
                    anket.anketYazar = anketJSON[i]["yazar"].stringValue
                    
                    self.anketArray.append(anket)
                    self.anketTableView.reloadData()
                }
            }
            else {
                print("anket get error: \(response.result.error!)")
            }
        }
    }
    
        

    
    
    //MARK: - TableView
    
    //TODO: - Row sayısı
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anketArray.count
    }
    
    
    //TODO: - Cell respawn
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = anketTableView.dequeueReusableCell(withIdentifier: "customAnketTableViewCell", for: indexPath) as! AnketTableViewCell
        
        cell.titleLabel.text = anketArray[indexPath.row].anketTitle
//        cell.timeLabel.text = anketArray[indexPath.row].anketDate
        cell.userLabel.text = anketArray[indexPath.row].anketYazar
        cell.anketImageView.sd_setImage(with: URL(string: anketArray[indexPath.row].anketImg), placeholderImage: UIImage(named: "profileDefault.png"))
        
        if anketArray[indexPath.row].anketIsVoted == 1 {
            cell.accessoryType = .checkmark
            
        }
        else {
            cell.accessoryType = .disclosureIndicator
        }
            
        
        return cell
    }

}

class AnketTableViewCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var anketImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
    }
    
}
