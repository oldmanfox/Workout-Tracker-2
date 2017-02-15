//
//  MeasurementsTVC.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 8/2/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class MeasurementsTVC: UITableViewController {
    
    let cellTitles = [["Start Month 1", "Start Month 2", "Start Month 3", "Final"],
                      ["All"]]
    
    var session = ""
    var monthString = ""
    
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
        
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
    }
    
    func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 4
        }
        else {
            
            return 1
        }
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
            
            return "Record Your Measurements"
        }
        else {
            
            return "View Your Measurements"
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
            
            self.performSegue(withIdentifier: "toRecordMeasurements", sender: indexPath)
            
        default:
            // Section = 1
            self.performSegue(withIdentifier: "toViewMeasurements", sender: indexPath)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toRecordMeasurements" {
            
            let destinationVC = segue.destination as? MeasurementsRecordViewController
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = cellTitles[(selectedRow?.section)!][(selectedRow?.row)!]
            destinationVC?.session = self.session
            destinationVC?.monthString = self.monthString
        }
        else {
            // MeasurementsReportViewController
            
            let destinationVC = segue.destination as? MeasurementsReportViewController
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = cellTitles[(selectedRow?.section)!][(selectedRow?.row)!]
            destinationVC?.session = self.session
        }
    }

    
    
}
