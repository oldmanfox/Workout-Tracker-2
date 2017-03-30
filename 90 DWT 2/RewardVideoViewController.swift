//
//  RewardVideoViewController.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 1/11/17.
//  Copyright © 2017 Jared Grant. All rights reserved.
//

import UIKit

class RewardVideoViewController: UIViewController {

    var shouldShowAd = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if shouldShowAd {
            
            // Fetch the rewarded video ad.
            // Rewarded Ad Unit
            MPRewardedVideo.presentAd(forAdUnitID: "c9130834e2324aa281a4b59dbcc41301", from: self, with: nil)
            
            shouldShowAd = false
        }
        else {
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
