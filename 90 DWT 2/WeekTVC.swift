//
//  WeekTVC.swift
//  90 DWT 1
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
    
    var workoutRoutine = ""
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
        static let one = "1"
        static let two = "2"
        static let three = "3"
        static let four = "4"
        static let five = "5"
        static let six = "6"
        static let seven = "7"
        static let light = "Light"
        static let dark = "Dark"
        static let red = "Red"
        static let purple = "Purple"
        static let tan = "Tan"
        static let white = "White"
    }
    
    fileprivate struct WorkoutName {
        
        static let Chest_Back = "Chest + Back & Ab Workout"
        static let Plyometrics = "Plyometrics"
        static let Shoulders_Arms = "Shoulders + Arms & Ab Workout"
        static let Yoga = "Yoga"
        static let Legs_Back = "Legs + Back & Ab Workout"
        static let Judo_Chop = "Judo Chop"
        static let Chest_Shoulders_Tri = "Chest + Shoulders + Tri & Ab Workout"
        static let Back_Bi = "Back + Biceps & Ab Workout"
        static let Core_Fitness = "Core Fitness"
        static let Full_On_Cardio = "Full on Cardio"
        
        static let Ab_Workout = "Ab Workout"
        static let Stretch = "Stretch or Rest"
        static let Rest = "Rest"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Workout"
        
        loadArraysForCell()
        
        // Add rightBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(WeekTVC.editButtonPressed(_:)))
        
        if Products.store.isProductPurchased("com.grantsoftware.90DWT1.removeads1") {
            
            // User purchased the Remove Ads in-app purchase so don't show any ads.
        }
        else {
            
            // Show the Banner Ad
            self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 0)
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
                
                // iPhone
                // Month Ad Unit
                self.adView = MPAdView(adUnitId: "4bed96fcb70a4371b972bf19d149e433", size: MOPUB_BANNER_SIZE)
                self.bannerSize = MOPUB_BANNER_SIZE
            }
            else {
                
                // iPad
                // Month Ad Unit
                self.adView = MPAdView(adUnitId: "7c80f30698634a22b77778b084e3087e", size: MOPUB_LEADERBOARD_SIZE)
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
        if Products.store.isProductPurchased("com.grantsoftware.90DWT1.removeads1") {
            
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
        
        // Show or Hide Ads
        if Products.store.isProductPurchased("com.grantsoftware.90DWT1.removeads1") {
            
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
    
    func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func editButtonPressed(_ sender: UIBarButtonItem) {
        
        let tempMessage = "Set the status for all workouts of:\n\n\(workoutRoutine) - \(workoutWeek)"
        
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
                    
                    let tempMessage = ("Set the status for:\n\n\(workoutRoutine) - \(workoutWeek) - \(cell.titleLabel.text!)")
                    
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
        
        let tempMessage = ("You are about to set the status for\n\n\(CDOperation.getCurrentRoutine()) - \(workoutWeek) - \(cell.titleLabel.text!)\n\nto:\n\n\(self.request)\n\nDo you want to proceed?")
        
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
        
        let tempMessage = "You are about to set the status for all workouts of:\n\n\(workoutRoutine) - \(workoutWeek)\n\nto:\n\n\(self.request)\n\nDo you want to proceed?"
        
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
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
                }
                
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
                }

            default:
                
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber)
                }
            }

            // Update TableViewCell Accessory Icon - Arrow
            let cell = self.tableView.cellForRow(at: self.indexPath) as! WeekTVC_TableViewCell
            
            let tempAccessoryView:UIImageView = UIImageView (image: UIImage (named: "next_arrow"))
            cell.accessoryView = tempAccessoryView
            
        default:
            
            // Completed
            
            // ***ADD***
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
                }
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
                }

            default:
                
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for _ in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[position] as NSString, index: indexArray[position] as NSNumber, useDate: Date())
                }
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
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
                }
                
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
                }

            default:
                
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber)
                }
            }
            
        default:
            
            // Completed
            
            // ***ADD***
            
            switch workoutRoutine {
            case "Normal":
                
                // Normal
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
                
            case "Tone":
                
                // Tone
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
                
            default:
                
                // 2-A-Days
                let nameArray = CDOperation.loadWorkoutNameArray()[getIntValueforWeekString() - 1]
                let indexArray = CDOperation.loadWorkoutIndexArray()[getIntValueforWeekString() - 1]
                
                for i in 0..<nameArray.count {
                    
                    CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: nameArray[i] as NSString, index: indexArray[i] as NSNumber, useDate: Date())
                }
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
        
        let workoutCompletedObjects = CDOperation.getWorkoutCompletedObjects(session as NSString, routine: workoutRoutine as NSString, workout: currentWeekWorkoutList[indexPath.section][indexPath.row] as! NSString, index: workoutIndexList[indexPath.section][indexPath.row] as! NSNumber)
        
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
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 86/255, green: 145/255, blue: 254/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Dark":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 43/255, green: 72/255, blue: 127/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Red":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 203/255, green: 116/255, blue: 49/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Purple":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 119/255, green: 112/255, blue: 152/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "Tan":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 254/255, green: 211/255, blue: 150/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.black
            
        case "White":
            cell.dayOfWeekTextField.backgroundColor = UIColor.white
            cell.dayOfWeekTextField.textColor = UIColor.black
            
        case "1":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 86/255, green: 145/255, blue: 254/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "2":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 79/255, green: 133/255, blue: 233/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "3":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 72/255, green: 121/255, blue: 212/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "4":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 65/255, green: 109/255, blue: 191/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "5":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 57/255, green: 96/255, blue: 169/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "6":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 50/255, green: 84/255, blue: 148/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        case "7":
            cell.dayOfWeekTextField.backgroundColor = UIColor(red: 43/255, green: 72/255, blue: 127/255, alpha: 1.0)
            cell.dayOfWeekTextField.textColor = UIColor.white
            
        default: break

        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "\(workoutRoutine) - \(workoutWeek)"
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
                cell.titleLabel.text == "Full on Cardio" ||
                cell.titleLabel.text == "Judo Chop" {
                
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
            destinationVC!.workoutRoutine = self.workoutRoutine
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
            destinationVC!.workoutRoutine = self.workoutRoutine
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
        
        if workoutRoutine == "Normal" {
            
            // Normal Routine
            switch workoutWeek {
            case "Week 1":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[1, 1], [1], [1, 2], [1], [1, 3], [1], [1, 1]]
                
            case "Week 2":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[2, 4], [2], [2, 5], [2], [2, 6], [2], [2, 2]]
                
                case "Week 3":
                    currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                              [WorkoutName.Plyometrics],
                                              [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                              [WorkoutName.Yoga],
                                              [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                              [WorkoutName.Judo_Chop],
                                              [WorkoutName.Stretch, WorkoutName.Rest]]
                    
                    daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                    
                    daysOfWeekColorList = [[Color.one, Color.red],
                                           [Color.one],
                                           [Color.one, Color.red],
                                           [Color.one],
                                           [Color.one, Color.red],
                                           [Color.one],
                                           [Color.one, Color.white]]
                    
                    optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                    
                    workoutIndexList = [[3, 7], [3], [3, 8], [3], [3, 9], [3], [3, 3]]
                
                case "Week 4":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Core_Fitness, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[4, 1, 4, 4, 2, 5], [5, 4]]
                
            case "Week 5":
                currentWeekWorkoutList = [[WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[1, 10], [4], [1, 11], [6], [4, 12], [5], [6, 5]]
                
            case "Week 6":
                currentWeekWorkoutList = [[WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[2, 13], [5], [2, 14], [7], [5, 15], [6], [7, 6]]
                
                case "Week 7":
                    currentWeekWorkoutList = [[WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                              [WorkoutName.Plyometrics],
                                              [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                              [WorkoutName.Yoga],
                                              [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                              [WorkoutName.Judo_Chop],
                                              [WorkoutName.Stretch, WorkoutName.Rest]]
                    
                    daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                    
                    daysOfWeekColorList = [[Color.seven, Color.red],
                                           [Color.seven],
                                           [Color.seven, Color.red],
                                           [Color.seven],
                                           [Color.seven, Color.red],
                                           [Color.seven],
                                           [Color.seven, Color.white]]
                    
                    optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                    
                    workoutIndexList = [[3, 16], [6], [3, 17], [8], [6, 18], [7], [8, 7]]
                
                case "Week 8":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Core_Fitness, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[9, 3, 8, 9, 4, 10], [10, 8]]
                
            case "Week 9":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[4, 19], [7], [4, 20], [11], [7, 21], [9], [11, 9]]
                
            case "Week 10":
                currentWeekWorkoutList = [[WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[4, 22], [8], [4, 23], [12], [8, 24], [10], [12, 10]]
                
            case "Week 11":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.red],
                                       [Color.one],
                                       [Color.one, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[5, 25], [9], [5, 26], [13], [9, 27], [11], [13, 11]]
                
            case "Week 12":
                currentWeekWorkoutList = [[WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.red],
                                       [Color.seven],
                                       [Color.seven, Color.white]]
                                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[5, 28], [10], [5, 29], [14], [10, 30], [12], [14, 12]]
                
            case "Week 13":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Core_Fitness, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[15, 5, 13, 15, 6, 16], [16, 13]]
                
                default:
                currentWeekWorkoutList = [[],[]]
            }
        }
        else if workoutRoutine == "Tone" {
            
            // Tone Routine
            switch workoutWeek {
            case "Week 1":
                currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light, Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.white]]
                
                optionalWorkoutList = [[false, false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[1, 1], [1, 1], [1], [1, 2], [1], [1, 1]]
                
            case "Week 2":
                currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light, Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.white]]
                
                optionalWorkoutList = [[false, false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[2, 2], [2, 3], [2], [2, 4], [2], [2, 2]]
                
            case "Week 3":
                currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light, Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.white]]
                
                optionalWorkoutList = [[false, false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[3, 3], [3, 5], [3], [3, 6], [3], [3, 3]]
                
            case "Week 4":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Core_Fitness, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[4, 4, 4, 4, 5, 5], [5, 4]]
                
            case "Week 5":
                currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.dark, Color.dark],
                                       [Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.white]]
                
                optionalWorkoutList = [[false, false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[6, 4], [1, 7], [6], [4, 8], [5], [6, 5]]
                
            case "Week 6":
                currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.dark, Color.dark],
                                       [Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.white]]
                
                optionalWorkoutList = [[false, false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[7, 5], [2, 9], [7], [5, 10], [6], [7, 6]]
                
            case "Week 7":
                currentWeekWorkoutList = [[WorkoutName.Core_Fitness, WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.dark, Color.dark],
                                       [Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.white]]
                
                optionalWorkoutList = [[false, false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[8, 6], [3, 11], [8], [6, 12], [7], [8, 7]]
                
            case "Week 8":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Full_On_Cardio, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[9, 9, 8, 9, 7, 10], [10, 8]]
                
            case "Week 9":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.purple, Color.red],
                                       [Color.purple],
                                       [Color.purple, Color.red],
                                       [Color.purple, Color.purple, Color.purple],
                                       [Color.purple, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false, false, false], [true, true]]
                
                workoutIndexList = [[1, 13], [8], [4, 14], [11, 10, 9], [11, 9]]
                
            case "Week 10":
                currentWeekWorkoutList = [[WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.tan, Color.red],
                                       [Color.tan],
                                       [Color.tan, Color.red],
                                       [Color.tan, Color.tan, Color.tan],
                                       [Color.tan, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false, false, false], [true, true]]
                
                workoutIndexList = [[4, 15], [9], [1, 16], [12, 11, 10], [12, 10]]
                
            case "Week 11":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.purple, Color.red],
                                       [Color.purple],
                                       [Color.purple, Color.red],
                                       [Color.purple, Color.purple, Color.purple],
                                       [Color.purple, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false, false, false], [true, true]]
                
                workoutIndexList = [[2, 17], [10], [5, 18], [13, 12, 11], [13, 11]]
                
            case "Week 12":
                currentWeekWorkoutList = [[WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.tan, Color.red],
                                       [Color.tan],
                                       [Color.tan, Color.red],
                                       [Color.tan, Color.tan, Color.tan],
                                       [Color.tan, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false, false, false], [true, true]]
                
                workoutIndexList = [[5, 19], [11], [2, 20], [14, 13, 12], [14, 12]]
                
            case "Week 13":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Full_On_Cardio, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[15, 14, 13, 15, 12, 16], [16, 13]]
                
            default:
                currentWeekWorkoutList = [[], []]
            }
        }
        else {
            
            // 2-A-Days Routine
            switch workoutWeek {
            case "Week 1":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[1, 1], [1], [1, 2], [1], [1, 3], [1], [1, 1]]
                
            case "Week 2":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[2, 4], [2], [2, 5], [2], [2, 6], [2], [2, 2]]
                
            case "Week 3":
                currentWeekWorkoutList = [[WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B"], ["2"], ["3A", "3B"], ["4"], ["5A", "5B"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.red],
                                       [Color.light],
                                       [Color.light, Color.white]]
                
                optionalWorkoutList = [[false, false], [false], [false, false], [false], [false, false], [false], [true, true]]
                
                workoutIndexList = [[3, 7], [3], [3, 8], [3], [3, 9], [3], [3, 3]]
                
            case "Week 4":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Core_Fitness, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[4, 1, 4, 4, 2, 5], [5, 4]]
                
            case "Week 5":
                currentWeekWorkoutList = [[WorkoutName.Full_On_Cardio, WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"], ["2"], ["3A", "3B", "3C"], ["4"], ["5A", "5B", "5C"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.white]]
                
                optionalWorkoutList = [[false, false, false], [false], [false, false, false], [false], [false, false, false], [false], [true, true]]
                
                workoutIndexList = [[1, 1, 10], [4], [2, 1, 11], [6], [3, 4, 12], [5], [6, 5]]
                
            case "Week 6":
                currentWeekWorkoutList = [[WorkoutName.Full_On_Cardio, WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"], ["2"], ["3A", "3B", "3C"], ["4"], ["5A", "5B", "5C"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.white]]
                
                optionalWorkoutList = [[false, false, false], [false], [false, false, false], [false], [false, false, false], [false], [true, true]]
                
                workoutIndexList = [[4, 2, 13], [5], [5, 2, 14], [7], [6, 5, 15], [6], [7, 6]]
                
            case "Week 7":
                currentWeekWorkoutList = [[WorkoutName.Full_On_Cardio, WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Plyometrics],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Yoga],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"], ["2"], ["3A", "3B", "3C"], ["4"], ["5A", "5B", "5C"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.dark, Color.red],
                                       [Color.dark],
                                       [Color.dark, Color.white]]
                
                optionalWorkoutList = [[false, false, false], [false], [false, false, false], [false], [false, false, false], [false], [true, true]]
                
                workoutIndexList = [[7, 3, 16], [6], [8, 3, 17], [8], [9, 6, 18], [7], [8, 7]]
                
            case "Week 8":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Core_Fitness, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[9, 3, 8, 9, 4, 10], [10, 8]]
                
            case "Week 9":
                currentWeekWorkoutList = [[WorkoutName.Full_On_Cardio, WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Yoga],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"], ["2A", "2B"], ["3A", "3B"], ["4A", "4B"], ["5A", "5B", "5C"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.purple, Color.purple, Color.red],
                                       [Color.purple, Color.purple],
                                       [Color.purple, Color.red],
                                       [Color.purple, Color.purple],
                                       [Color.purple, Color.purple, Color.red],
                                       [Color.purple],
                                       [Color.purple, Color.white]]
                
                optionalWorkoutList = [[false, false, false], [false, false], [false, false], [false, false], [false, false, false], [false], [true, true]]
                
                workoutIndexList = [[10, 4, 19], [11, 7], [4, 20], [12, 11], [13, 7, 21], [9], [11, 9]]
                
            case "Week 10":
                currentWeekWorkoutList = [[WorkoutName.Full_On_Cardio, WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Plyometrics],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Yoga],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"], ["2A", "2B"], ["3A", "3B"], ["4A", "4B"], ["5A", "5B", "5C"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.tan, Color.tan, Color.red],
                                       [Color.tan, Color.tan],
                                       [Color.tan, Color.red],
                                       [Color.tan, Color.tan],
                                       [Color.tan, Color.tan, Color.red],
                                       [Color.tan],
                                       [Color.tan, Color.white]]
                
                optionalWorkoutList = [[false, false, false], [false, false], [false, false], [false, false], [false, false, false], [false], [true, true]]
                
                workoutIndexList = [[14, 4, 22], [15, 8], [4, 23], [16, 12], [17, 8, 24], [10], [12, 10]]
                
            case "Week 11":
                currentWeekWorkoutList = [[WorkoutName.Full_On_Cardio, WorkoutName.Chest_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Plyometrics],
                                          [WorkoutName.Shoulders_Arms, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Yoga],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"], ["2A", "2B"], ["3A", "3B"], ["4A", "4B"], ["5A", "5B", "5C"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.purple, Color.purple, Color.red],
                                       [Color.purple, Color.purple],
                                       [Color.purple, Color.red],
                                       [Color.purple, Color.purple],
                                       [Color.purple, Color.purple, Color.red],
                                       [Color.purple],
                                       [Color.purple, Color.white]]
                
                optionalWorkoutList = [[false, false, false], [false, false], [false, false], [false, false], [false, false, false], [false], [true, true]]
                
                workoutIndexList = [[18, 5, 25], [19, 9], [5, 26], [20, 13], [21, 9, 27], [11], [13, 11]]
                
            case "Week 12":
                currentWeekWorkoutList = [[WorkoutName.Full_On_Cardio, WorkoutName.Chest_Shoulders_Tri, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Plyometrics],
                                          [WorkoutName.Back_Bi, WorkoutName.Ab_Workout],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Yoga],
                                          [WorkoutName.Full_On_Cardio, WorkoutName.Legs_Back, WorkoutName.Ab_Workout],
                                          [WorkoutName.Judo_Chop],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1A", "1B", "1C"], ["2A", "2B"], ["3A", "3B"], ["4A", "4B"], ["5A", "5B", "5C"], ["6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.tan, Color.tan, Color.red],
                                       [Color.tan, Color.tan],
                                       [Color.tan, Color.red],
                                       [Color.tan, Color.tan],
                                       [Color.tan, Color.tan, Color.red],
                                       [Color.tan],
                                       [Color.tan, Color.white]]
                
                optionalWorkoutList = [[false, false, false], [false, false], [false, false], [false, false], [false, false, false], [false], [true, true]]
                
                workoutIndexList = [[22, 5, 28], [23, 10], [5, 29], [24, 14], [25, 10, 30], [12], [14, 12]]
                
            case "Week 13":
                currentWeekWorkoutList = [[WorkoutName.Yoga, WorkoutName.Core_Fitness, WorkoutName.Judo_Chop, WorkoutName.Stretch, WorkoutName.Core_Fitness, WorkoutName.Yoga],
                                          [WorkoutName.Stretch, WorkoutName.Rest]]
                
                daysOfWeekNumberList = [["1", "2", "3", "4", "5", "6"], ["7", "7"]]
                
                daysOfWeekColorList = [[Color.one, Color.two, Color.three, Color.four, Color.five, Color.six],
                                       [Color.seven, Color.white]]
                
                optionalWorkoutList = [[false, false, false, false, false, false], [true, true]]
                
                workoutIndexList = [[15, 5, 13, 15, 6, 16], [16, 13]]
                
            default:
                currentWeekWorkoutList = [[], []]
            }
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
