//
//  WebsiteViewController.swift
//  90 DWT 1
//
//  Created by Grant, Jared on 9/21/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class WebsiteViewController: UIViewController {

    @IBOutlet weak var websiteView: UIWebView!
    
    override func viewDidLoad() {
        
        let url = URL(string: "http://www.grantdevelopers.com/fitness.html")
        
        let request = URLRequest(url: url!)
        
        self.websiteView.loadRequest(request)
    }
}
