//
//  PhotoTVC.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 9/15/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class PhotoTVC: UITableViewController {

    let cellTitles = [["Start Month 1", "Start Month 2", "Start Month 3", "Final"],
                      ["All", "Front", "Side", "Back"]]
    
    var session = ""
    var monthString = ""
    
    var photoAngle = [[], []]
    var photoMonth = [[], []]
    var photoTitles = [[], []]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get the current session
        session = CDOperation.getCurrentSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get the current session
        session = CDOperation.getCurrentSession()
        
        // Force fetch when notified of significant data changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.doNothing), name: NSNotification.Name(rawValue: "SomethingChanged"), object: nil)
        
        // Set the AutoLock Setting
        if CDOperation.getAutoLockSetting() == "ON" {
            
            // User wants to disable the autolock timer.
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else {
            
            // User doesn't want to disable the autolock timer.
            UIApplication.shared.isIdleTimerDisabled = false
        }

        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
    }
    
    @objc func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel!.text = cellTitles[indexPath.section][indexPath.row]
        
        let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow"))
        cell.accessoryView = tempAccessoryView
        
//        if let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow")) {
//            
//            cell.accessoryView = tempAccessoryView
//        }
        
        return cell
    }

    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Take Photos"
        }
        else {
            
            return "View Photos"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            // Section = 0
            switch indexPath.row {
            case 0:
                monthString = "1"
                
            case 1:
                monthString = "2"
                
            case 2:
                monthString = "3"
                
            default:
                monthString = "4"
            }
            
            self.performSegue(withIdentifier: "toTakePhotos", sender: indexPath)
            
        default:
            // Section = 1
            switch indexPath.row {
            case 0:
                // ALL
                photoAngle = [["Front", "Side", "Back"],
                              ["Front", "Side", "Back"],
                              ["Front", "Side", "Back"],
                              ["Front", "Side", "Back"]]
                
                photoMonth = [["1", "1", "1"],
                              ["2", "2", "2"],
                              ["3", "3", "3"],
                              ["4", "4", "4"]]
                
                photoTitles = [["Start Month 1 Front", "Start Month 1 Side", "Start Month 1 Back"],
                               ["Start Month 2 Front", "Start Month 2 Side", "Start Month 2 Back"],
                               ["Start Month 3 Front", "Start Month 3 Side", "Start Month 3 Back"],
                               ["Final Front", "Final Side", "Final Back"]]
                
            case 1:
                // FRONT
                photoAngle = [["Front",
                               "Front",
                               "Front",
                               "Front"]]
                
                photoMonth = [["1",
                               "2",
                               "3",
                               "4"]]
                
                photoTitles = [["Start Month 1 Front",
                                "Start Month 2 Front",
                                "Start Month 3 Front",
                                "Final Front"]]
                
            case 2:
                // SIDE
                photoAngle = [["Side",
                               "Side",
                               "Side",
                               "Side"]]
                
                photoMonth = [["1",
                               "2",
                               "3",
                               "4"]]
                
                photoTitles = [["Start Month 1 Side",
                                "Start Month 2 Side",
                                "Start Month 3 Side",
                                "Final Side"]]
                
            default:
                // BACK
                photoAngle = [["Back",
                               "Back",
                               "Back",
                               "Back"]]
                
                photoMonth = [["1",
                               "2",
                               "3",
                               "4"]]
                
                photoTitles = [["Start Month 1 Back",
                                "Start Month 2 Back",
                                "Start Month 3 Back",
                                "Final Back"]]
            }

            self.performSegue(withIdentifier: "toViewPhotos", sender: indexPath)
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toTakePhotos" {
            
            let destinationVC = segue.destination as? TakePhotosViewController
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = cellTitles[(selectedRow?.section)!][(selectedRow?.row)!]
            destinationVC?.session = self.session
            destinationVC?.monthString = self.monthString
        }
        else {
            // ViewPhotosViewController
            
            let destinationVC = segue.destination as? ViewPhotosViewController
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = cellTitles[(selectedRow?.section)!][(selectedRow?.row)!]
            destinationVC?.session = self.session
            destinationVC?.monthString = self.monthString
            
            destinationVC?.photoAngle = self.photoAngle
            destinationVC?.photoMonth = self.photoMonth
            destinationVC?.photoTitles = self.photoTitles
        }
    }
}
