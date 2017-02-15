//
//  PhotoNavigationController.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 10/4/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class PhotoNavigationController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        
        let parentTBC = self.tabBarController as! MainTBC
        
        if parentTBC.sessionChangedForPhotoNC {
            
            parentTBC.sessionChangedForPhotoNC = false
            self.popToRootViewController(animated: true)
        }
    }
}
