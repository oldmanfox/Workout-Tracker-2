//
//  TutorialViewController.swift
//  90 DWT 1
//
//  Created by Grant, Jared on 12/20/16.
//  Copyright © 2016 Jared Grant. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var tutorialView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "http://www.grantdevelopers.com/tutorials.html")
        
        let request = URLRequest(url: url!)
        
        self.tutorialView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
