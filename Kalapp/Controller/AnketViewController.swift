//
//  AnketViewController.swift
//  Kalapp
//
//  Created by Arkhin on 31.01.2018.
//  Copyright © 2018 KalÖM. All rights reserved.
//

import UIKit
import WebKit

var myContext = 0


class AnketViewController: UIViewController, WKUIDelegate {

    let loginHash = UserDefaults.standard.string(forKey: "hash")
    var postId = ""
    var postTitle = ""
    var posterName = ""
    var anketImage = ""
    
    var webView: WKWebView!
    var progressView: UIProgressView!

    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var anketTitle: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        progressView.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        navigationController?.navigationBar.addSubview(progressView)
        let navigationBarBounds = self.navigationController?.navigationBar.bounds
        progressView.frame = CGRect(x: 0, y: navigationBarBounds!.size.height - 2, width: navigationBarBounds!.size.width, height: 2)
    }
    
    deinit {
        //remove all observers
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        //remove progress bar from navigation bar
        progressView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = postTitle
                
        let myURL = URL(string: "http://207.154.249.115/?action=anket&do=anket_getir&hash=\(loginHash!)&id=\(postId)")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &myContext)
    }


    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let change = change else { return }
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        

        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.progress = progress;
            }
            return
        }
    }

}
