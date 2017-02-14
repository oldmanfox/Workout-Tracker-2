//
//  MeasurementNavigationController.swift
//  90 DWT 1
//
//  Created by Grant, Jared on 10/4/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class MeasurementNavigationController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        
        let parentTBC = self.tabBarController as! MainTBC
        
        if parentTBC.sessionChangedForMeasurementNC {
            
            parentTBC.sessionChangedForMeasurementNC = false
            self.popToRootViewController(animated: true)
        }
    }
}
