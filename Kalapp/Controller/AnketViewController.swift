//
//  AnketViewController.swift
//  Kalapp
//
//  Created by Arkhin on 31.01.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit
import WebKit

class AnketViewController: UIViewController, WKUIDelegate {

    let loginHash = UserDefaults.standard.string(forKey: "hash")
    var postId = ""
    var postTitle = ""
    var posterName = ""
    var anketImage = ""
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var anketTitle: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let myURL = URL(string: "http://kalapp.kalfest.com/?action=anket&do=anket_getir&hash=\(loginHash!)&id=\(postId)")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
    }

}
