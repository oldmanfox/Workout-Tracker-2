//
//  SettingsTVC.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 9/21/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import CoreData

class SettingsTVC: UITableViewController, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // **********
    let debug = 0
    // **********
    
    // MARK: Variables
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var autoLockCell: UITableViewCell!
    @IBOutlet weak var currentSessionCell: UITableViewCell!
    @IBOutlet weak var importPreviousSessionDataCell: UITableViewCell!
    @IBOutlet weak var exportCell: UITableViewCell!
    @IBOutlet weak var resetCell: UITableViewCell!
    @IBOutlet weak var iCloudDriveCell: UITableViewCell!
    @IBOutlet weak var appUsingiCloudCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var websiteCell: UITableViewCell!
    
    @IBOutlet weak var emailDetail: UILabel! // Default is youremail@abc.com.
    @IBOutlet weak var autoLockSwitch: UISwitch! // Disable autolock while using the app.
    @IBOutlet weak var currentSessionLabel: UILabel!
    @IBOutlet weak var decreaseSessionButton: UIButton!
    @IBOutlet weak var increaseSessionButton: UIButton!
    @IBOutlet weak var importPreviusSessionDataSwitch: UISwitch!
    @IBOutlet weak var exportAllDataButton: UIButton!
    @IBOutlet weak var exportCurrentSessionDataButton: UIButton!
    @IBOutlet weak var resetAllDataButton: UIButton!
    @IBOutlet weak var resetCurrentSessionDataButton: UIButton!
    @IBOutlet weak var iCloudDriveStatusLabel: UILabel!
    @IBOutlet weak var iCloudAppStatusLabel: UILabel!
    
    
    var session = ""
    
    // MARK: Functions
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.configureButtonBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Get the current session
        session = CDOperation.getCurrentSession()
        self.currentSessionLabel.text = self.session
        
        self.findUseAutoLockSetting()
        self.findEmailSetting()
        self.findAppUsingiCloudStatus()
        self.setImportPreviousSessionDataSwitch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force fetch when notified of significant data changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.doNothing), name: NSNotification.Name(rawValue: "SomethingChanged"), object: nil)
        
        self.findiCloudStatus()
        self.findAppUsingiCloudStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
    }
    
    @objc func doNothing() {
        
        // Do nothing
        
        // Get the current session
        session = CDOperation.getCurrentSession()
        self.currentSessionLabel.text = self.session
        
        self.findUseAutoLockSetting()
        self.findEmailSetting()
        
        self.findiCloudStatus()
        self.findAppUsingiCloudStatus()
        self.setImportPreviousSessionDataSwitch()
    }

    func configureButtonBorder() {
        
        let red = UIColor(red: 204/255, green: 70/255, blue: 20/255, alpha: 1)
        //let lightRed = UIColor(red: 175/255, green: 89/255, blue: 8/255, alpha: 0.75)
        
        // decreaseSession Button
        self.decreaseSessionButton.tintColor = UIColor.white
        self.decreaseSessionButton.backgroundColor = red
        self.decreaseSessionButton.layer.borderWidth = 1
        self.decreaseSessionButton.layer.borderColor = red.cgColor
        self.decreaseSessionButton.layer.cornerRadius = 5
        self.decreaseSessionButton.clipsToBounds = true
        
        // increaseSession Button
        self.increaseSessionButton.tintColor = UIColor.white
        self.increaseSessionButton.backgroundColor = red
        self.increaseSessionButton.layer.borderWidth = 1
        self.increaseSessionButton.layer.borderColor = red.cgColor
        self.increaseSessionButton.layer.cornerRadius = 5
        self.increaseSessionButton.clipsToBounds = true
        
        // ResetAllData Button
        self.resetAllDataButton.tintColor = UIColor.white
        self.resetAllDataButton.backgroundColor = red
        self.resetAllDataButton.layer.borderWidth = 1
        self.resetAllDataButton.layer.borderColor = red.cgColor
        self.resetAllDataButton.layer.cornerRadius = 5
        self.resetAllDataButton.clipsToBounds = true
        
        // ResetCurrentSessionData Button
        self.resetCurrentSessionDataButton.tintColor = UIColor.white
        self.resetCurrentSessionDataButton.backgroundColor = red
        self.resetCurrentSessionDataButton.layer.borderWidth = 1
        self.resetCurrentSessionDataButton.layer.borderColor = red.cgColor
        self.resetCurrentSessionDataButton.layer.cornerRadius = 5
        self.resetCurrentSessionDataButton.clipsToBounds = true
        
        // ExportAllData Button
        self.exportAllDataButton.tintColor = UIColor.white
        self.exportAllDataButton.backgroundColor = red
        self.exportAllDataButton.layer.borderWidth = 1
        self.exportAllDataButton.layer.borderColor = red.cgColor
        self.exportAllDataButton.layer.cornerRadius = 5
        self.exportAllDataButton.clipsToBounds = true
        
        // ExportCurrentSessionData Button
        self.exportCurrentSessionDataButton.tintColor = UIColor.white
        self.exportCurrentSessionDataButton.backgroundColor = red
        self.exportCurrentSessionDataButton.layer.borderWidth = 1
        self.exportCurrentSessionDataButton.layer.borderColor = red.cgColor
        self.exportCurrentSessionDataButton.layer.cornerRadius = 5
        self.exportCurrentSessionDataButton.clipsToBounds = true
    }
    
    @IBAction func toggleAutoLock(_ sender: UISwitch) {
        
        var newAutoLockSetting = "OFF"
        
        if sender.isOn {
            
            // User wants to disable the autolock timer.
            newAutoLockSetting = "ON"
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else {
            
            // User doesn't want to disable the autolock timer.
            newAutoLockSetting = "OFF"
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
        // Fetch AutoLock data.
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "AutoLock")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let autoLockObjects = try CoreDataHelper.shared().context.fetch(request) as? [AutoLock] {
                
                if debug == 1 {
                    
                    print("autoLockObjects.count = \(autoLockObjects.count)")
                }

                if autoLockObjects.count != 0 {
                    
                    // Match Found.  Update existing record.
                    autoLockObjects.last?.useAutoLock = newAutoLockSetting
                }
                else {
                    
                    // No Matches Found.  Create new record and save.
                    let insertAutoLockInfo = NSEntityDescription.insertNewObject(forEntityName: "AutoLock", into: CoreDataHelper.shared().context) as! AutoLock
                    
                    insertAutoLockInfo.useAutoLock = newAutoLockSetting
                    insertAutoLockInfo.date = Date() as NSDate?
                }
                
                CoreDataHelper.shared().backgroundSaveContext()
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    @IBAction func decreaseSession(_ sender: UIButton) {
        
        let currentSession = CDOperation.getCurrentSession()
        
        var alertController = UIAlertController()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if currentSession == "1" {
            
            alertController = UIAlertController(title: "ERROR", message: "Session cannot = 0.", preferredStyle: .alert)
        }
        else {
            
            alertController = UIAlertController(title: "WARNING - Start Previous Session", message: "Starting a previous session means you will only be able to edit the previous session.  To get to a different session click the \"+\" or \"-\" button after selecting Proceed.", preferredStyle: .alert)
            
            let proceed = UIAlertAction(title: "Proceed", style: .default, handler: {
                action in
                
                // Fetch Session data.
                let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Session")
                let sortDate = NSSortDescriptor( key: "date", ascending: true)
                request.sortDescriptors = [sortDate]
                
                do {
                    if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                        
                        if self.debug == 1 {
                            
                            print("sessionObjects.count = \(sessionObjects.count)")
                        }

                        if sessionObjects.count != 0 {
                            
                            // Match Found.  Update existing record.
                            let newSessionNumber = Int(self.session)! - 1
                            sessionObjects.last?.currentSession = String(newSessionNumber)
                            sessionObjects.last?.date = Date() as NSDate?
                            
                            CoreDataHelper.shared().backgroundSaveContext()
                            
                            // Update currentSessionLabel
                            self.currentSessionLabel.text = String(newSessionNumber)
                            self.session = String(newSessionNumber)
                            
                            // Session changed
                            let parentTBC = self.tabBarController as! MainTBC
                            parentTBC.sessionChangedForWorkoutNC = true
                            parentTBC.sessionChangedForPhotoNC = true
                            parentTBC.sessionChangedForMeasurementNC = true
                        }
                    }
                    
                } catch { print(" ERROR executing a fetch request: \( error)") }
            })
            
            alertController.addAction(proceed)
        }
        
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func increaseSession(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "WARNING - Start New Session", message: "Starting a new session means you will only be able to edit the new session.  To get to a different session click the \"+\" or \"-\" button after selecting Proceed.", preferredStyle: .alert)
        
        let proceed = UIAlertAction(title: "Proceed", style: .default, handler: {
            action in
            
            // Fetch Session data.
            let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Session")
            let sortDate = NSSortDescriptor( key: "date", ascending: true)
            request.sortDescriptors = [sortDate]
            
            do {
                if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                    
                    if self.debug == 1 {
                        
                        print("sessionObjects.count = \(sessionObjects.count)")
                    }
                    
                    if sessionObjects.count != 0 {
                        
                        // Match Found.  Update existing record.
                        let newSessionNumber = Int(self.session)! + 1
                        sessionObjects.last?.currentSession = String(newSessionNumber)
                        sessionObjects.last?.date = Date() as NSDate?
                        
                        CoreDataHelper.shared().backgroundSaveContext()
                        
                        // Update currentSessionLabel
                        self.currentSessionLabel.text = String(newSessionNumber)
                        self.session = String(newSessionNumber)
                        
                        // Session changed
                        let parentTBC = self.tabBarController as! MainTBC
                        parentTBC.sessionChangedForWorkoutNC = true
                        parentTBC.sessionChangedForPhotoNC = true
                        parentTBC.sessionChangedForMeasurementNC = true
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
        })
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(proceed)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.delegate = self
            popover.permittedArrowDirections = .any
    }
    
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func importPreviousSessionData(_ sender: UISwitch) {
        
        var newImportPreviousSessionDataSetting = false
        
        if sender.isOn {
            
            // User wants to import the previous session data into the new session.
            newImportPreviousSessionDataSetting = true
        }
        else {
            
            // User doesn't want to import the previous session data into the new session.
            newImportPreviousSessionDataSetting = false
        }
        
        // Fetch Session data.
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Session")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                
                if self.debug == 1 {
                    
                    print("sessionObjects.count = \(sessionObjects.count)")
                }
                
                if sessionObjects.count != 0 {
                    
                    // Match Found.  Update existing record.
                    // Datatbase needs Boolean to be an NSNumber in order to store it.
                    
                    sessionObjects.last?.importPreviousSessionData = newImportPreviousSessionDataSetting as NSNumber
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }

    @IBAction func exportAllData(_ sender: UIButton) {
        
        //  Get the ALL SESSIONS csvstring and then send the email
        self.sendEmail("All", cvsString: CDOperation.allSessionStringForEmail())
    }

    @IBAction func exportCurrentSessionData(_ sender: UIButton) {
        
        //  Get the CURRENT SESSION csvstring and then send the email
        self.sendEmail("Current", cvsString: CDOperation.currentSessionStringForEmail())
    }

    @IBAction func resetAllData(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "WARNING - Delete All Data", message: "You are about to delete ALL data in the app and start fresh.  If you are signed into iCloud this will delete the data there as well.", preferredStyle: .alert)
        
        let proceed = UIAlertAction(title: "Proceed", style: .default, handler: {
            action in
            
            // Fetch Workout data.
            var request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
            let sortDate = NSSortDescriptor( key: "date", ascending: true)
            request.sortDescriptors = [sortDate]
            
            do {
                if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                    
                    if self.debug == 1 {
                        
                        print("workoutObjects.count = \(workoutObjects.count)")
                    }
                    
                    for object in workoutObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
           
            // DELETE all from entity - WorkoutCompleteDate
            request = NSFetchRequest(entityName: "WorkoutCompleteDate")
            
            do {
                if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                    
                    if self.debug == 1 {
                        
                        print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                    }
                    
                    for object in workoutCompleteDateObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // DELETE all from entity - Session
            request = NSFetchRequest(entityName: "Session")
            
            do {
                if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                    
                    if self.debug == 1 {
                        
                        print("sessionObjects.count = \(sessionObjects.count)")
                    }
                    
                    for object in sessionObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // Set session to default - 1
            do {
                if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                    
                    if self.debug == 1 {
                        
                        print("sessionObjects.count = \(sessionObjects.count)")
                    }
                    
                    if sessionObjects.count == 0 {
                        
                        self.session = CDOperation.getCurrentSession()
                        self.currentSessionLabel.text = self.session
                        
                        // Session changed
                        let parentTBC = self.tabBarController as! MainTBC
                        parentTBC.sessionChangedForWorkoutNC = true
                        parentTBC.sessionChangedForPhotoNC = true
                        parentTBC.sessionChangedForMeasurementNC = true
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // DELETE all from entity - Photo
            request = NSFetchRequest(entityName: "Photo")
            
            do {
                if let photoObjects = try CoreDataHelper.shared().context.fetch(request) as? [Photo] {
                    
                    if self.debug == 1 {
                        
                        print("photoObjects.count = \(photoObjects.count)")
                    }
                    
                    for object in photoObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // DELETE all from entity - Measurement
            request = NSFetchRequest(entityName: "Measurement")
            
            do {
                if let measurementObjects = try CoreDataHelper.shared().context.fetch(request) as? [Measurement] {
                    
                    if self.debug == 1 {
                        
                        print("measurementObjects.count = \(measurementObjects.count)")
                    }
                    
                    for object in measurementObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }

            // DELETE all from entity - Email
            request = NSFetchRequest(entityName: "Email")
            
            do {
                if let emailObjects = try CoreDataHelper.shared().context.fetch(request) as? [Email] {
                    
                    if self.debug == 1 {
                        
                        print("emailObjects.count = \(emailObjects.count)")
                    }
                    
                    for object in emailObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // Set email to default
            do {
                if let emailObjects = try CoreDataHelper.shared().context.fetch(request) as? [Email] {
                    
                    if self.debug == 1 {
                        
                        print("emailObjects.count = \(emailObjects.count)")
                    }
                    
                    if emailObjects.count == 0 {
                        
                        // No Matches.  Create new record and save.
                        let insertEmailInfo = NSEntityDescription.insertNewObject(forEntityName: "Email", into: CoreDataHelper.shared().context) as! Email
                        
                        insertEmailInfo.defaultEmail = "youremail@abc.com"
                        insertEmailInfo.date = Date() as NSDate?
                        
                        self.emailDetail.text = "youremail@abc.com"
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }

            // DELETE all from entity - AutoLock
            request = NSFetchRequest(entityName: "AutoLock")
            
            do {
                if let autoLockObjects = try CoreDataHelper.shared().context.fetch(request) as? [AutoLock] {
                    
                    if self.debug == 1 {
                        
                        print("autoLockObjects.count = \(autoLockObjects.count)")
                    }
                    
                    for object in autoLockObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // Set disable autolock to default - OFF
            self.autoLockSwitch.setOn(false, animated: true)
            UIApplication.shared.isIdleTimerDisabled = false
            
            // Save data to database
            CoreDataHelper.shared().backgroundSaveContext()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(proceed)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func resetCurrentSessionData(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "WARNING - Delete Current Session Data", message: "You are about to delete the data for the current session and start fresh for that session.  If you are signed into iCloud this will delete the data there as well.", preferredStyle: .alert)
        
        let proceed = UIAlertAction(title: "Proceed", style: .default, handler: {
            action in
            
            // DELETE current session from entity - Workout
            var request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
            let sortDate = NSSortDescriptor( key: "date", ascending: true)
            request.sortDescriptors = [sortDate]

            let filter = NSPredicate(format: "session == %@",
                self.session)
            
            request.predicate = filter

            do {
                if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                    
                    if self.debug == 1 {
                        
                        print("workoutObjects.count = \(workoutObjects.count)")
                    }
                    
                    for object in workoutObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }

            
            // DELETE current session from entity - WorkoutCompleteDate
            request = NSFetchRequest(entityName: "WorkoutCompleteDate")
            
            do {
                if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                    
                    if self.debug == 1 {
                        
                        print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                    }
                    
                    for object in workoutCompleteDateObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // DELETE current session from entity - Photo
            request = NSFetchRequest(entityName: "Photo")
            
            do {
                if let photoObjects = try CoreDataHelper.shared().context.fetch(request) as? [Photo] {
                    
                    if self.debug == 1 {
                        
                        print("photoObjects.count = \(photoObjects.count)")
                    }
                    
                    for object in photoObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // DELETE current session from entity - Measurement
            request = NSFetchRequest(entityName: "Measurement")
            
            do {
                if let measurementObjects = try CoreDataHelper.shared().context.fetch(request) as? [Measurement] {
                    
                    if self.debug == 1 {
                        
                        print("measurementObjects.count = \(measurementObjects.count)")
                    }
                    
                    for object in measurementObjects {
                        
                        // Delete duplicate records.
                        CoreDataHelper.shared().context.delete(object)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
            
            // Save data to database
            CoreDataHelper.shared().backgroundSaveContext()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(proceed)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func findEmailSetting() {
        
        // Fetch defaultEmail data.
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Email")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let emailObjects = try CoreDataHelper.shared().context.fetch(request) as? [Email] {
        
                if debug == 1 {
                    
                    print("emailObjects.count = \(emailObjects.count)")
                }
                
                if emailObjects.count != 0 {
                    
                    // There is a default email address.
                    self.emailDetail.text = emailObjects.last?.defaultEmail
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    func findUseAutoLockSetting() {
        
        // Fetch defaultEmail data.
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "AutoLock")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let autoLockObjects = try CoreDataHelper.shared().context.fetch(request) as? [AutoLock] {
                
                if debug == 1 {
                    
                    print("autoLockObjects.count = \(autoLockObjects.count)")
                }
                
                if autoLockObjects.count != 0 {
                    
                    // Match Found
                    if autoLockObjects.last?.useAutoLock == "ON" {
                        
                        self.autoLockSwitch.setOn(true, animated: true)
                    }
                    else {
                        
                        self.autoLockSwitch.setOn(false, animated: true)
                    }
                }
                else {
                    
                    // No Matches Found
                    self.autoLockSwitch.setOn(false, animated: true)
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    func setImportPreviousSessionDataSwitch() {
        
        if CDOperation.getImportPreviousSessionData() == true {
            
            self.importPreviusSessionDataSwitch.setOn(true, animated: true)
        }
        else {
            
            self.importPreviusSessionDataSwitch.setOn(false, animated: true)
        }
    }

    func sendEmail(_ sessionType: String, cvsString: String) {
        
        // Create MailComposerViewController object.
        let mailcomposer = MFMailComposeViewController()
        mailcomposer.mailComposeDelegate = self
        mailcomposer.navigationBar.tintColor = UIColor.white
        
        // Check to see if the device has at least 1 email account configured
        if MFMailComposeViewController.canSendMail() {
            
            let csvData = cvsString.data(using: String.Encoding.ascii)
            var fileName = ""
            var subject = ""
            
            switch sessionType {
            case "All":
                fileName = "AllSessionsData.csv"
                subject = "90 DWT 2 All Sessions Workout Data"
                
            default:
                // "Current"
                fileName = "Session\(self.session)Data.csv"
                subject = "90 DWT 2 Session \(self.session) Workout Data"
            }
            
            
            var emailAddress = [""]
            
            // Fetch defaultEmail data.
            let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Email")
            let sortDate = NSSortDescriptor( key: "date", ascending: true)
            request.sortDescriptors = [sortDate]
            
            do {
                if let emailObjects = try CoreDataHelper.shared().context.fetch(request) as? [Email] {
                    
                    if debug == 1 {
                        
                        print("emailObjects.count = \(emailObjects.count)")
                    }
                    
                    if emailObjects.count != 0 {
                        
                        // There is a default email address.
                        emailAddress = [(emailObjects.last?.defaultEmail)!]
                    }
                    else {
                        
                        // There is NOT a default email address.  Put an empty email address in the arrary.
                        emailAddress = [""]
                    }
                }
                
            } catch { print(" ERROR executing a fetch request: \( error)") }

            mailcomposer.setToRecipients(emailAddress)
            mailcomposer.setSubject(subject)
            mailcomposer.addAttachmentData(csvData!, mimeType: "text/csv", fileName: fileName)
            
            present(mailcomposer, animated: true, completion: {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func findiCloudStatus() {
        
        // Check if the user is signed into an iCloud account on the device.
        if CoreDataHelper.shared().iCloudAccountIsSignedIn() {
            
            self.iCloudDriveStatusLabel.text = "ON"
        }
        else {
            
            self.iCloudDriveStatusLabel.text = "OFF.  Change in Device Settings -> iCloud"
        }
    }
    
    func findAppUsingiCloudStatus() {
        
        if UserDefaults.standard.bool(forKey: "iCloudEnabled") {
            
            self.iCloudAppStatusLabel.text = "ON"
        }
        else {
            
            self.iCloudAppStatusLabel.text = "OFF.  Change in Device Settings -> 90DWT2"
        }
    }
}
