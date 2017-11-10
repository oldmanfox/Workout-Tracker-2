//
//  WeekTVC.swift
//  90 DWT 2
//
//  Created by Jared Grant on 6/25/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class WeekTVC: UITableViewController, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, MPAdViewDelegate {
    
    // **********
    let debug = 0
    // **********
    
    fileprivate var currentWeekWorkoutList = [[], []]
    fileprivate var daysOfWeekNumberList = [[], []]
    fileprivate var daysOfWeekColorList = [[], []]
    fileprivate var optionalWorkoutList = [[], []]
    fileprivate var workoutIndexList = [[], []]
    
    var session = ""
    var workoutWeek = ""
    var month = ""
    
    var adView = MPAdView()
    var headerView = UIView()
    var bannerSize = CGSize()
    
    var longPGR = UILongPressGestureRecognizer()
    var indexPath = IndexPath()
    var position = NSInteger()
    var request = ""
    
    fileprivate struct Color {
        static let light = "Light"
        static let medium = "Medium"
        static let dark = "Dark"
        static let red = "Red"
        static let white = "White"
    }
    
    fileprivate struct WorkoutName {
        
        static let Core_Fitness = "Core Fitness"
        static let Plyometrics = "Plyometrics"
        static let Complete_Fitness = "Complete Fitness & Ab Workout"
        static let Yoga = "Yoga"
        static let Strength_Stability = "Strength + Stability"
        static let Chest_Back_Stability = "Chest + Back + Stability & Ab Workout"
        static let Shoulder_Bi_Tri = "Shoulder + Bi + Tri & Ab Workout"
        static let Legs_Back = "Legs + Back & Ab Workout"
        static let Lower_Agility = "Lower Agility"
        static let Upper_Agility = "Upper Agility"
        
        static let Ab_Workout = "Ab Workout"
        static let Stretch = "Stretch"
        static let Rest = "Rest"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Workout"
        
        loadArraysForCell()
        
        // Add rightBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(WeekTVC.editButtonPressed(_:)))
        
        if Products.store.isProductPurchased("com.grantsoftware.90DWT2.removeads1") {
            
            // User purchased the Remove Ads in-app purchase so don't show any ads.
        }
        else {
            
            // Show the Banner Ad
            self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 0)
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
                
                // iPhone
                // Month Ad Unit
                self.adView = MPAdView(adUnitId: "6232cd4a1e374ecebed0f15440ba2a65", size: MOPUB_BANNER_SIZE)
                self.bannerSize = MOPUB_BANNER_SIZE
            }
            else {
                
                // iPad
                // Month Ad Unit
                self.adView = MPAdView(adUnitId: "05f5a06e1c8e4560ba24068341868285", size: MOPUB_LEADERBOARD_SIZE)
                self.bannerSize = MOPUB_LEADERBOARD_SIZE
            }
            
            self.adView.delegate = self
            self.adView.frame = CGRect(x: (self.view.bounds.size.width - self.bannerSize.width) / 2,
                                           y: self.bannerSize.height - self.bannerSize.height,
                                           width: self.bannerSize.width, height: self.bannerSize.height)
        }

        // Add a long press gesture recognizer
        self.longPGR = UILongPressGestureRecognizer(target: self, action: #selector(MonthTVC.longPressGRAction(_:)))
        self.longPGR.minimumPressDuration = 1.0
        self.longPGR.allowableMovement = 10.0
        self.tableView.addGestureRecognizer(self.longPGR)

        if debug == 1 {
            
            print("SHARED CONTEXT - \(CDOperation.objectCountForEntity("Workout", context: CoreDataHelper.shared().context))")
            
            print("IMPORT CONTEXT - \(CDOperation.objectCountForEntity("Workout", context: CoreDataHelper.shared().importContext))")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        // Show or Hide Ads
        if Products.store.isProductPurchased("com.grantsoftware.90DWT2.removeads1") {
            
            // Don't show ads.
            self.tableView.tableHeaderView = nil
            self.adView.delegate = nil
            
        } else {
            
            // Show ads
            self.headerView.addSubview(self.adView)
            
            self.adView.loadAd()
            
            self.adView.isHidden = true;
        }

        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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

        // Show or Hide Ads
        if Products.store.isProductPurchased("com.grantsoftware.90DWT2.removeads1") {
            
            // Don't show ads.
            self.tableView.tableHeaderView = nil
            self.adView.delegate = nil
            
        } else {
            
            // Show ads
            self.adView.frame = CGRect(x: (self.view.bounds.size.width - self.bannerSize.width) / 2,
                                           y: self.bannerSize.height - self.bannerSize.height,
                                           width: self.bannerSize.width, height: self.bannerSize.height)
            self.adView.isHidden = false
        }

        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
        
        self.adView.removeFromSuperview()
    }
    
    @objc func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func editButtonPressed(_ sender: UIBarButtonItem) {
        
        let tempMessage = "Set the status for all workouts of:\n\n\(workoutWeek)"
        
        let alertController = UIAlertController(title: "Workout Status", message: tempMessage, preferredStyle: .actionSheet)
        
        let notCompletedAction = UIAlertAction(title: "Not Completed", style: .destructive, handler: {
            action in
            
            self.request = "Not Completed"
            self.verifyAddDeleteRequestFromBarButtonItem()
        })
        
        let completedAction = UIAlertAction(title: "Completed", style: .default, handler: {
            action in
            
            self.request = "Completed"
            self.verifyAddDeleteRequestFromBarButtonItem()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(notCompletedAction)
        alertController.addAction(completedAction)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.barButtonItem = sender
            popover.sourceView = self.view
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }

    func longPressGRAction(_ sender: UILongPressGestureRecognizer) {
     
        if (sender.isEqual(self.longPGR)) {
            
            if sender.state == UIGestureRecognizerState.began {
                
                let p = sender.location(in: self.tableView)
                
                if let tempIndexPath = self.tableView.indexPathForRow(at: p) {
                    
                    self.indexPath = tempIndexPath
                    self.position = self.findArrayPosition(self.indexPath)
                    
                    // get affected cell and label
                    let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
                    
                    let tempMessage = ("Set the status for:\n\n\(workoutWeek) - \(cell.titleLabel.text!)")
                    
                    let alertController = UIAlertController(title: "Workout Status", message: tempMessage, preferredStyle: .actionSheet)
                    
                    let notCompletedAction = UIAlertAction(title: "Not Completed", style: .destructive, handler: {
                        action in
                        
                        self.request = "Not Completed"
                        self.verifyAddDeleteRequestFromTableViewCell()
                    })
                    
                    let completedAction = UIAlertAction(title: "Completed", style: .default, handler: {
                        action in
                        
                        self.request = "Completed"
                        self.verifyAddDeleteRequestFromTableViewCell()
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alertController.addAction(notCompletedAction)
                    alertController.addAction(completedAction)
                    alertController.addAction(cancelAction)
                    
                    if let popover = alertController.popoverPresentationController {
                        
                        popover.sourceView = cell
                        popover.delegate = self
                        popover.sourceRect = (cell.bounds)
                        popover.permittedArrowDirections = .any
                    }
                    
                    present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func verifyAddDeleteRequestFromTableViewCell() {
        
        // get affected cell
        let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
        
        self.position = self.findArrayPosition(self.indexPath)
        
        let tempMessage = ("You are about to set the status for\n\n\(workoutWeek) - \(cell.titleLabel.text!)\n\nto:\n\n\(self.request)\n\nDo you want to proceed?")
        
        let alertController = UIAlertController(title: "Warning", message: tempMessage, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            
            self.addDeleteDate()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func verifyAddDeleteRequestFromBarButtonItem() {
        
        let tempMessage = "You are about to set the status for all workouts of:\n\n\(workoutWeek)\n\nto:\n\n\(self.request)\n\nDo you want to proceed?"
        
        let alertController = UIAlertController(title: "Warning", message: tempMessage, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            
            self.AddDeleteDatesFromOneWeek()
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func addDeleteDate() {
        
        switch self.request {
        case "Not Completed":
            
            // ***DELETE***
            // Normal
            let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
            let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
            
            for _ in 0..<nameArray.count {
                
                CDOperation.deleteDate(session as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
            }
            
            // Update TableViewCell Accessory Icon - Arrow
            let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
            
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow"))
            cell.accessoryView = tempAccessoryView
            
        default:
            
            // Completed
            
            // ***ADD***
            // Normal
            let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
            let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
            
            for _ in 0..<nameArray.count {
                
                CDOperation.saveWorkoutCompleteDate(session as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
            }
            
            // Update TableViewCell Accessory Icon - Checkmark
            let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "RED_White_CheckMark"))
            cell.accessoryView = tempAccessoryView
        }
    }

    func AddDeleteDatesFromOneWeek() {
        
        switch self.request {
        case "Not Completed":
            
            // ***DELETE***
            // Normal
            let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
            let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
            
            for i in 0..<nameArray.count {
                
                CDOperation.deleteDate(session as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
            }

        default:
            
            // Completed
            
            // ***ADD***
            // Normal
            let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
            let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
            
            for i in 0..<nameArray.count {
                
                CDOperation.saveWorkoutCompleteDate(session as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
            }
        }
    }
    
    func findArrayPosition(_ indexPath: IndexPath) -> NSInteger {
        
        var position = NSInteger(0)
        
        for i in 0...indexPath.section {
            
            if (i == indexPath.section) {
                
                position = position + (indexPath.row + 1)
            }
            else {
                
                let totalRowsInSection = self.tableView.numberOfRows(inSection: i)
                
                position = position + totalRowsInSection
            }
        }
        
        return position - 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return currentWeekWorkoutList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return currentWeekWorkoutList[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! WeekTVC_TableViewCell

        // Configure the cell...
        cell.titleLabel.text = CDOperation.trimStringForWorkoutName((currentWeekWorkoutList[indexPath.section][indexPath.row] as? String)!)
        cell.dayOfWeekTextField.text = daysOfWeekNumberList[indexPath.section][indexPath.row] as? String
        
        if optionalWorkoutList[indexPath.section][indexPath.row] as! Bool == false {
            
            // Don't show the "Select 1"
            cell.detailLabel.isHidden = true
        }
        else {
            cell.detailLabel.isHidden = false
        }
        
        let workoutCompletedObjects = CDOperation.getWorkoutCompletedObjects(session as NSString, workout: currentWeekWorkoutList[indexPath.section][indexPath.row] as! NSString, index: workoutIndexList[indexPath.section][indexPath.row] as! NSNumber)
        
        if workoutCompletedObjects.count != 0 {
            
            // Workout completed so put a checkmark as the accessoryview icon
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "RED_White_CheckMark"))
            cell.accessoryView = tempAccessoryView
        }
        else {
            
            // Workout was NOT completed so put the arrow as the accessory view icon
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow"))
            cell.accessoryView = tempAccessoryView
        }
        
        switch daysOfWeekColorList[indexPath.section][indexPath.row] as! String {
        case "Light":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 191/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Medium":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 83/255, blue: 127/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Dark":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 0/255, green: 42/255, blue: 64/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Red":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 204/255, green: 70/255, blue: 20/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "White":
            cell.dayOfWeekTextField.backgroundColor = UIColor.white
            cell.dayOfWeekTextField.textColor = UIColor.black
            
        default: break

        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "\(workoutWeek)"
        }
        else {
            return ""
        }
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return 30
        }
        else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? WeekTVC_TableViewCell {
            
            if cell.titleLabel.text == "Rest" ||
                cell.titleLabel.text == "Stretch" ||
                cell.titleLabel.text == "Ab Workout" ||
                cell.titleLabel.text == "Plyometrics" ||
                cell.titleLabel.text == "Yoga" ||
                cell.titleLabel.text == "Lower Agility" ||
                cell.titleLabel.text == "Upper Agility" {
                
                self.performSegue(withIdentifier: "toNotes", sender: indexPath)
            }
            else {
                
                self.performSegue(withIdentifier: "toWorkout", sender: indexPath)
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toWorkout" {
            
            let destinationVC = segue.destination as? WorkoutTVC
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = CDOperation.trimStringForWorkoutName((self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!)
            destinationVC!.selectedWorkout = (self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!
            destinationVC?.workoutIndex = (self.workoutIndexList[(selectedRow?.section)!][(selectedRow?.row)!] as? Int)!
            destinationVC?.session = self.session
            destinationVC?.workoutWeek = self.workoutWeek
            destinationVC?.month = self.month
        }
        else {
            // NotesViewController
            
            let destinationVC = segue.destination as? NotesViewController
            let selectedRow = tableView.indexPathForSelectedRow
            
            destinationVC?.navigationItem.title = (self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!
            destinationVC!.selectedWorkout = (self.currentWeekWorkoutList[(selectedRow?.section)!][(selectedRow?.row)!] as? String)!
            destinationVC?.workoutIndex = (self.workoutIndexList[(selectedRow?.section)!][(selectedRow?.row)!] as? Int)!
            destinationVC?.session = self.session
            destinationVC!.workoutWeek = self.workoutWeek
            destinationVC?.month = self.month
        }
    }
    
    func getIntValueforWeekString() -> Int {
        
        switch workoutWeek {
        case "Week 1":
            
            return 1
          
        case "Week 2":
            
            return 2
            
        case "Week 3":
            
            return 3
            
        case "Week 4":
            
            return 4
            
        case "Week 5":
            
            return 5
            
        case "Week 6":
            
            return 6
            
        case "Week 7":
            
            return 7
            
        case "Week 8":
            
            return 8
            
        case "Week 9":
            
            return 9
            
        case "Week 10":
            
            return 10
            
        case "Week 11":
            
            return 11

        case "Week 12":
            
            return 12
            
        default:
            
            // Week 13
            return 13
        }
    }
    
    fileprivate func loadArraysForCell() {
        
        // Normal
        switch workoutWeek {
        case "Week 1":
            currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Complete_Fitness, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga, WorkoutName.Strength_Stability],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2"], ["3", "3"], ["4A", "4B"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.light, Color .light],
                                   [Color.light, Color.white],
                                   [Color.light, Color.red],
                                   [Color.light, Color.light],
                                   [Color.light, Color.white]]
            
            optionalWorkoutList = [[false, false], [true, true], [false, false], [false, false], [true, true]]
            
            workoutIndexList = [[1, 1], [1, 1], [1, 1], [1, 1], [2, 2]]
            
        case "Week 2":
            currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Complete_Fitness, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga, WorkoutName.Strength_Stability],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2"], ["3", "3"], ["4A", "4B"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.light, Color .light],
                                   [Color.light, Color.white],
                                   [Color.light, Color.red],
                                   [Color.light, Color.light],
                                   [Color.light, Color.white]]
            
            optionalWorkoutList = [[false, false], [true, true], [false, false], [false, false], [true, true]]
            
            workoutIndexList = [[2, 2], [3, 3], [2, 2], [2, 2], [4, 4]]
            
        case "Week 3":
            currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Complete_Fitness, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga, WorkoutName.Strength_Stability],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2"], ["3", "3"], ["4A", "4B"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.light, Color .light],
                                   [Color.light, Color.white],
                                   [Color.light, Color.red],
                                   [Color.light, Color.light],
                                   [Color.light, Color.white]]
            
            optionalWorkoutList = [[false, false], [true, true], [false, false], [false, false], [true, true]]
            
            workoutIndexList = [[3, 3], [5, 5], [3, 3], [3, 3], [6, 6]]
            
        case "Week 4":
            currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Complete_Fitness, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga, WorkoutName.Strength_Stability],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2"], ["3", "3"], ["4A", "4B"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.light, Color .light],
                                   [Color.light, Color.white],
                                   [Color.light, Color.red],
                                   [Color.light, Color.light],
                                   [Color.light, Color.white]]
            
            optionalWorkoutList = [[false, false], [true, true], [false, false], [false, false], [true, true]]
            
            workoutIndexList = [[4, 4], [7, 7], [4, 4], [4, 4], [8, 8]]
            
        case "Week 5":
            currentWeekWorkoutList = [[WorkoutName.Chest_Back_Stability, WorkoutName.Ab_Workout],
                                      [WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Shoulder_Bi_Tri, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga],
                                      [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3", "3"], ["4A", "4B"], ["5"], ["6A", "6B"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.white],
                                   [Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.red],
                                   [Color.medium, Color.white]]
            
            optionalWorkoutList = [[false, false], [false], [true, true], [false, false], [false], [false, false], [true, true]]
            
            workoutIndexList = [[1, 5], [5], [9, 9], [1, 6], [5], [1, 7], [10, 10]]
            
        case "Week 6":
            currentWeekWorkoutList = [[WorkoutName.Chest_Back_Stability, WorkoutName.Ab_Workout],
                                      [WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Shoulder_Bi_Tri, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga],
                                      [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3", "3"], ["4A", "4B"], ["5"], ["6A", "6B"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.white],
                                   [Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.red],
                                   [Color.medium, Color.white]]
            
            optionalWorkoutList = [[false, false], [false], [true, true], [false, false], [false], [false, false], [true, true]]
            
            workoutIndexList = [[2, 8], [6], [11, 11], [2, 9], [6], [2, 10], [12, 12]]
            
        case "Week 7":
            currentWeekWorkoutList = [[WorkoutName.Chest_Back_Stability, WorkoutName.Ab_Workout],
                                      [WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Shoulder_Bi_Tri, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga],
                                      [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3", "3"], ["4A", "4B"], ["5"], ["6A", "6B"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.white],
                                   [Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.red],
                                   [Color.medium, Color.white]]
            
            optionalWorkoutList = [[false, false], [false], [true, true], [false, false], [false], [false, false], [true, true]]
            
            workoutIndexList = [[3, 11], [7], [13, 13], [3, 12], [7], [3, 13], [14, 14]]
            
        case "Week 8":
            currentWeekWorkoutList = [[WorkoutName.Chest_Back_Stability, WorkoutName.Ab_Workout],
                                      [WorkoutName.Plyometrics],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Shoulder_Bi_Tri, WorkoutName.Ab_Workout],
                                      [WorkoutName.Yoga],
                                      [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3", "3"], ["4A", "4B"], ["5"], ["6A", "6B"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.white],
                                   [Color.medium, Color.red],
                                   [Color.medium],
                                   [Color.medium, Color.red],
                                   [Color.medium, Color.white]]
            
            optionalWorkoutList = [[false, false], [false], [true, true], [false, false], [false], [false, false], [true, true]]
            
            workoutIndexList = [[4, 14], [8], [15, 15], [4, 15], [8], [4, 16], [16, 16]]
            
        case "Week 9":
            currentWeekWorkoutList = [[WorkoutName.Lower_Agility, WorkoutName.Upper_Agility, WorkoutName.Yoga],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Lower_Agility, WorkoutName.Upper_Agility],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2", "3"], ["4", "4"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.dark, Color.dark, Color.dark],
                                   [Color.dark, Color.white],
                                   [Color.dark, Color.dark],
                                   [Color.dark, Color.white]]
            
            optionalWorkoutList = [[false, false, false], [true, true], [false, false], [true, true]]
            
            workoutIndexList = [[1, 1, 9], [17, 17], [2, 2], [18, 18]]
            
        case "Week 10":
            currentWeekWorkoutList = [[WorkoutName.Lower_Agility, WorkoutName.Upper_Agility, WorkoutName.Yoga],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Lower_Agility, WorkoutName.Upper_Agility],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2", "3"], ["4", "4"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.dark, Color.dark, Color.dark],
                                   [Color.dark, Color.white],
                                   [Color.dark, Color.dark],
                                   [Color.dark, Color.white]]
            
            optionalWorkoutList = [[false, false, false], [true, true], [false, false], [true, true]]
            
            workoutIndexList = [[3, 3, 10], [19, 19], [4, 4], [20, 20]]
            
        case "Week 11":
            currentWeekWorkoutList = [[WorkoutName.Lower_Agility, WorkoutName.Upper_Agility, WorkoutName.Yoga],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Lower_Agility, WorkoutName.Upper_Agility],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2", "3"], ["4", "4"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.dark, Color.dark, Color.dark],
                                   [Color.dark, Color.white],
                                   [Color.dark, Color.dark],
                                   [Color.dark, Color.white]]
            
            optionalWorkoutList = [[false, false, false], [true, true], [false, false], [true, true]]
            
            workoutIndexList = [[5, 5, 11], [21, 21], [6, 6], [22, 22]]
            
        case "Week 12":
            currentWeekWorkoutList = [[WorkoutName.Lower_Agility, WorkoutName.Upper_Agility, WorkoutName.Yoga],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Lower_Agility, WorkoutName.Upper_Agility],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2", "3"], ["4", "4"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.dark, Color.dark, Color.dark],
                                   [Color.dark, Color.white],
                                   [Color.dark, Color.dark],
                                   [Color.dark, Color.white]]
            
            optionalWorkoutList = [[false, false, false], [true, true], [false, false], [true, true]]
            
            workoutIndexList = [[7, 7, 12], [23, 23], [8, 8], [24, 24]]
            
        case "Week 13":
            currentWeekWorkoutList = [[WorkoutName.Lower_Agility, WorkoutName.Upper_Agility, WorkoutName.Yoga],
                                      [WorkoutName.Stretch, WorkoutName.Rest],
                                      [WorkoutName.Lower_Agility, WorkoutName.Upper_Agility],
                                      [WorkoutName.Stretch, WorkoutName.Rest]]
            
            daysOfWeekNumberList = [["1", "2", "3"], ["4", "4"], ["5", "6"], ["7", "7"]]
            
            daysOfWeekColorList = [[Color.dark, Color.dark, Color.dark],
                                   [Color.dark, Color.white],
                                   [Color.dark, Color.dark],
                                   [Color.dark, Color.white]]
            
            optionalWorkoutList = [[false, false, false], [true, true], [false, false], [true, true]]
            
            workoutIndexList = [[9, 9, 13], [25, 25], [10, 10], [26, 26]]
            
        default:
            currentWeekWorkoutList = [[],[]]
        }
    }
    
    // MARK: - <MPAdViewDelegate>
    func viewControllerForPresentingModalView() -> UIViewController! {
        
        return self
    }
    
    func adViewDidLoadAd(_ view: MPAdView!) {
        
        let size = view.adContentViewSize()
        let centeredX = (self.view.bounds.size.width - size.width) / 2
        let bottomAlignedY = self.bannerSize.height - size.height
        view.frame = CGRect(x: centeredX, y: bottomAlignedY, width: size.width, height: size.height)
        
        if (self.headerView.frame.size.height == 0) {
            
            // No ads shown yet.  Animate showing the ad.
            let headerViewFrame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.bannerSize.height)
            
            UIView.animate(withDuration: 0.25, animations: {self.headerView.frame = headerViewFrame
                self.tableView.tableHeaderView = self.headerView
                self.adView.isHidden = true},
                           completion: {(finished: Bool) in
                            self.adView.isHidden = false
                            
            })
        }
        else {
            
            // Ad is already showing.
            self.tableView.tableHeaderView = self.headerView
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.adView.isHidden = true
        self.adView.rotate(to: toInterfaceOrientation)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        let size = self.adView.adContentViewSize()
        let centeredX = (self.view.bounds.size.width - size.width) / 2
        let bottomAlignedY = self.headerView.bounds.size.height - size.height
        
        self.adView.frame = CGRect(x: centeredX, y: bottomAlignedY, width: size.width, height: size.height)
        
        self.adView.isHidden = false
    }
}
