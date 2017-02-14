//
//  DatePickerViewController.swift
//  90 DWT 1
//
//  Created by Grant, Jared on 7/15/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    // **********
    let debug = 0
    // **********
    
    var session = ""
    var selectedWorkout = ""
    var workoutIndex = 0
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let chosen = datePicker.date
        
        if debug == 1 {
            
            print("Date: \(chosen)")
        }
        
        CDOperation.saveWorkoutCompleteDate(session as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber, useDate: chosen)

    }
}
