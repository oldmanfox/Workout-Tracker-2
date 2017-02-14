///
//  WorkoutTVC.swift
//  90 DWT 1
//
//  Created by Jared Grant on 6/25/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import Social
import CoreData

class WorkoutTVC: UITableViewController, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, MPAdViewDelegate {

    // **********
    let debug = 0
    // **********
    
    var session = ""
    var workoutRoutine = ""
    var selectedWorkout = ""
    var workoutWeek = ""
    var month = ""
    var workoutIndex = 0
    var graphButtonText = "Reward Video = 1hr Graph"
    var segmentedControlTitle = "Round 1"
    
    var graphViewPurchased = false
    var adView = MPAdView()
    var headerView = UIView()
    var bannerSize = CGSize()
    
    var timer = Timer()
    
    var selectedCellIdentifier = ""
    var workoutCompleteCell = WorkoutTVC_CompletionTableViewCell()
    
    var exerciseNameArray = [[], []]
    var exerciseRepsArray = [[], []]
    var cellArray = [[], []]
    
    fileprivate struct CellType {
        static let straight_1 = "WorkoutCell_Straight_1"
        static let straight_2 = "WorkoutCell_Straight_2"
        //static let straight_3 = "WorkoutCell_Straight_3"
        static let shuffle = "ShuffleCell"
        static let completion = "CompletionCell"
    }
    
    fileprivate struct Round {
        static let round1 = "Round 1"
        static let round2 = "Round 2"
        //static let round3 = "Round 3"
        static let empty = ""
    }
    
    fileprivate struct LabelType {
            static let reps = "R"
            static let sec = "Sec"
            static let empty = ""
            static let weight = "W"
    }
    
    fileprivate struct Color {
        static let light = UIColor (red: 86/255, green: 145/255, blue: 254/255, alpha: 1)
        static let medium = UIColor (red: 4/255, green: 142/255, blue: 93/255, alpha: 1)
        static let dark = UIColor (red: 43/255, green: 72/255, blue: 127/255, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if segmentedControlTitle == "Round 1" {
            
            loadExerciseNameArray(selectedWorkout)
        }
        else {
            
            // Will only be "Chest + Back & Ab Workout" so no argument needs to be passed.
            loadShuffledExerciseNameArray()
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
        
        // Add rightBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(WorkoutTVC.actionButtonPressed(_:)))
        
        self.graphViewPurchased = self.wasGraphViewPurchased()
        
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
        
        self.graphViewPurchased = self.wasGraphViewPurchased()
        
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
        
        // Setup timer if reward video was viewed
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.shouldShowRewardGraph {
            
            //  Show the Reward Graph
            let now = Date()
            let calendar = Calendar.current
            
            // Calculate the time left from now til the Reward Graph expiration date
            let diff = calendar.dateComponents([.hour, .minute, .second], from: now, to: appDelegate.endDate as Date)
            let seconds = (diff.minute! * 60) + diff.second!
            
            // Set timer to disalbe access to Graph after the 1 hour is up
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(seconds), target: self, selector: #selector(self.disableRewardedGraph), userInfo: nil, repeats: false)
        }
        
        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
        
        self.adView.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doNothing() {
        
        // Do nothing
        self.tableView.reloadData()
    }
    
    func disableRewardedGraph() {
        
        timer.invalidate()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldShowRewardGraph = false
        
        if !self.graphViewPurchased {
            // Graph not purchased yet
            // Reload data so that the graph button will now be disabled
            self.tableView.reloadData()
        }
    }
    
    func wasGraphViewPurchased() -> Bool {
        
        if Products.store.isProductPurchased("com.grantsoftware.90DWT1.slidergraph") {
            
            return true
        }
        else {
            
            return false
        }
    }

    func actionButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Share", message: "How you want to share your progress?", preferredStyle: .actionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: {
            action in
            
            self.sendEmail(CDOperation.singleWorkoutStringForEmail(self.selectedWorkout, index: self.workoutIndex))
        })
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: {
            action in
            
            if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
                let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                //            socialController.setInitialText("Hello World!")
                //            socialController.addImage(someUIImageInstance)
                //            socialController.addURL(someNSURLInstance)
                
                self.present(socialController!, animated: true, completion: nil)
            }
            else {
                
                let alertControllerError = UIAlertController(title: "Error", message: "Please ensure you are connected to the internet AND signed into the Facebook app on your device before posting to Facebook.", preferredStyle: .alert)
                
                let cancelActionError = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertControllerError.addAction(cancelActionError)
                
                if let popoverError = alertControllerError.popoverPresentationController {
                    
                    popoverError.barButtonItem = sender
                    popoverError.sourceView = self.view
                    popoverError.delegate = self
                    popoverError.permittedArrowDirections = .any
                }
                
                self.present(alertControllerError, animated: true, completion: nil)
            }
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: {
            action in
            
            if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)) {
                let socialController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                //            socialController.setInitialText("Hello World!")
                //            socialController.addImage(someUIImageInstance)
                //            socialController.addURL(someNSURLInstance)
                
                self.present(socialController!, animated: true, completion: nil)
            }
            else {
                
                let alertControllerError = UIAlertController(title: "Error", message: "Please ensure you are connected to the internet AND signed into the Twitter app on your device before posting to Twitter.", preferredStyle: .alert)
                
                let cancelActionError = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertControllerError.addAction(cancelActionError)
                
                if let popoverError = alertControllerError.popoverPresentationController {
                    
                    popoverError.barButtonItem = sender
                    popoverError.sourceView = self.view
                    popoverError.delegate = self
                    popoverError.permittedArrowDirections = .any
                }
                
                self.present(alertControllerError, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(emailAction)
        alertController.addAction(facebookAction)
        alertController.addAction(twitterAction)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            
            popover.barButtonItem = sender
            popover.sourceView = self.view
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func sendEmail(_ cvsString: String) {
        
        // Create MailComposerViewController object.
        let mailcomposer = MFMailComposeViewController()
        mailcomposer.mailComposeDelegate = self
        mailcomposer.navigationBar.tintColor = UIColor.white
        
        // Check to see if the device has at least 1 email account configured
        if MFMailComposeViewController.canSendMail() {
            
            // Send email
            let csvData = cvsString.data(using: String.Encoding.ascii)
            let subject = "90 DWT 1 Workout Data"
            let fileName = NSString .localizedStringWithFormat("%@ - Session %@.csv", self.navigationItem.title!, session)
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
            mailcomposer.setSubject(subject as String)
            mailcomposer.addAttachmentData(csvData!, mimeType: "text/csv", fileName: fileName as String)
            
            present(mailcomposer, animated: true, completion: {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return cellArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        return cellArray[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let workoutObject = cellArray[indexPath.section][indexPath.row] as? NSArray {
            
            if let cellIdentifierArray = workoutObject[5] as? [String] {
                
                let cellIdentifier = cellIdentifierArray[0]
                
                if cellIdentifier == "WorkoutCell_Straight_1" || cellIdentifier == "WorkoutCell_Straight_2" {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTVC_WorkoutTableViewCell
                    
                    let titleArray = workoutObject[0] as? NSArray
                    cell.title.text = (titleArray![0] as AnyObject).uppercased
                    cell.nonUpperCaseExerciseName = titleArray![0] as! String
                    
                    cell.workoutRoutine = workoutRoutine // Bulk or Tone
                    cell.selectedWorkout = selectedWorkout // B1: Chest+Tri etc...
                    cell.workoutIndex = workoutIndex // Index of the workout in the program
                    cell.session = session
                    cell.workoutWeek = workoutWeek
                    cell.month = month

                    if let roundNumbers = workoutObject[1] as? [String] {
                        
                        cell.roundLabel1.text = roundNumbers[0].uppercased()
                        cell.roundLabel2.text = roundNumbers[1].uppercased()
//                        cell.roundLabel3.text = roundNumbers[2]
//                        cell.roundLabel4.text = roundNumbers[3]
//                        cell.roundLabel5.text = roundNumbers[4]
//                        cell.roundLabel6.text = roundNumbers[5]
                    }
                    
                    if let labelTypeTitles = workoutObject[2] as? [String] {
                        
                        // Round 1
                        cell.repLabel1.text = labelTypeTitles[0]
                        cell.weightLabel1.text = labelTypeTitles[1]
                        
                        // Round 2
                        cell.repLabel2.text = labelTypeTitles[2]
                        cell.weightLabel2.text = labelTypeTitles[3]
                        
//                        // Round3
//                        cell.repLabel3.text = labelTypeTitles[4]
//                        cell.weightLabel3.text = labelTypeTitles[5]
                    }
                    
                    if let cellColor = workoutObject[3] as? [UIColor] {
                        
                        // Round 1
                        cell.currentRep1.backgroundColor = cellColor[0]
                        cell.currentWeight1.backgroundColor = cellColor[1]
                        
                        // Round 2
                        cell.currentRep2.backgroundColor = cellColor[2]
                        cell.currentWeight2.backgroundColor = cellColor[3]
                        
//                        // Round 3
//                        cell.currentRep3.backgroundColor = cellColor[4]
//                        cell.currentWeight3.backgroundColor = cellColor[5]
                    }
                    
                    if let textFields = workoutObject[4] as? [Bool] {
                        
                        // PREVIOUS
                        // Round 1
                        cell.repLabel1.isHidden = textFields[0]
                        cell.previousRep1.isHidden = textFields[0]
                        
                        if textFields[1] {
                            cell.weightLabel1.text = ""
                        }
                        cell.previousWeight1.isHidden = textFields[1]
                        
                        // Round 2
                        cell.repLabel2.isHidden = textFields[2]
                        cell.previousRep2.isHidden = textFields[2]
                        
                        if textFields[3] {
                            cell.weightLabel2.text = ""
                        }
                        cell.previousWeight2.isHidden = textFields[3]
                        
//                        // Round 3
//                        cell.repLabel3.isHidden = textFields[4]
//                        cell.previousRep3.isHidden = textFields[4]
//                        
//                        if textFields[5] {
//                            cell.weightLabel3.text = ""
//                        }
//                        cell.previousWeight3.isHidden = textFields[5]
                        
                        // CURRENT
                        // Round 1
                        cell.currentRep1.isHidden = textFields[0]
                        cell.currentWeight1.isHidden = textFields[1]
                        
                        // Round 2
                        cell.currentRep2.isHidden = textFields[2]
                        cell.currentWeight2.isHidden = textFields[3]
                        
//                        // Round 3
//                        cell.currentRep3.isHidden = textFields[4]
//                        cell.currentWeight3.isHidden = textFields[5]
                    }
                    
                    cell.currentRep1.text = "0.0"
                    cell.currentRep2.text = "0.0"
//                    cell.currentRep3.text = "0.0"
                    cell.currentWeight1.text = "0.0"
                    cell.currentWeight2.text = "0.0"
//                    cell.currentWeight3.text = "0.0"
                    cell.currentNotes.text = "CURRENT NOTES"
                    
                    cell.originalCurrentRep1_Text = "0.0"
                    cell.originalCurrentRep2_Text = "0.0"
//                    cell.originalCurrentRep3_Text = "0.0"
                    cell.originalCurrentWeight1_Text = "0.0"
                    cell.originalCurrentWeight2_Text = "0.0"
//                    cell.originalCurrentWeight3_Text = "0.0"
                    cell.originalCurrentNotes_Text = "CURRENT NOTES"
                    
                    cell.previousRep1.text = "0.0"
                    cell.previousRep2.text = "0.0"
//                    cell.previousRep3.text = "0.0"
                    cell.previousWeight1.text = "0.0"
                    cell.previousWeight2.text = "0.0"
//                    cell.previousWeight3.text = "0.0"
                    cell.previousNotes.text = "PREVIOUS NOTES"

                    // Current Weight Fields and Notes
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(session, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: workoutIndex as NSNumber) as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }

                        for object in workoutObjects {
                            
                            // Reps
                            var tempReps = ""
                            
                            if object.reps != nil {
                                
                                tempReps = object.reps!
                            }
                            else {
                                
                                tempReps = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Reps = \(tempReps)")
                            }
                            
                            // Weight
                            var tempWeight = ""
                            
                            if object.weight != nil {
                                
                                tempWeight = object.weight!
                            }
                            else {
                                
                                tempWeight = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Weight = \(tempWeight)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                // Switch on the Round
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    // Reps
                                    if object.reps != nil {
                                        
                                        cell.currentRep1.text = object.reps
                                        cell.originalCurrentRep1_Text = object.reps!
                                    }
                                    else {
                                        cell.currentRep1.text = "0.0"
                                        cell.originalCurrentRep1_Text = "0.0"
                                    }

                                    // Weight
                                    if object.weight != nil {
                                        
                                        cell.currentWeight1.text = object.weight
                                        cell.originalCurrentWeight1_Text = object.weight!
                                    }
                                    else {
                                        cell.currentWeight1.text = "0.0"
                                        cell.originalCurrentWeight1_Text = "0.0"
                                    }
                                    
                                    // Notes
                                    if object.notes != nil {
                                        
                                        cell.currentNotes.text = object.notes?.uppercased()
                                        cell.originalCurrentNotes_Text = object.notes!.uppercased()
                                    }
                                    else {
                                        
                                        cell.currentNotes.text = "CURRENT NOTES"
                                        cell.originalCurrentNotes_Text = "CURRENT NOTES"
                                    }

                                case 1:
                                    // Reps
                                    if object.reps != nil {
                                        
                                        cell.currentRep2.text = object.reps
                                        cell.originalCurrentRep2_Text = object.reps!
                                    }
                                    else {
                                        
                                        cell.currentRep2.text = "0.0"
                                        cell.originalCurrentRep2_Text = "0.0"
                                    }

                                    // Weight
                                    if object.weight != nil {
                                       
                                        cell.currentWeight2.text = object.weight
                                        cell.originalCurrentWeight2_Text = object.weight!
                                    }
                                    else {
                                        
                                        cell.currentWeight2.text = "0.0"
                                        cell.originalCurrentWeight2_Text = "0.0"
                                    }
                                    
//                                case 2:
//                                    if object.weight != nil {
//                                        
//                                        cell.currentWeight3.text = object.weight
//                                        cell.originalCurrentWeight3_Text = object.weight!
//                                    }
//                                    else {
//                                        
//                                        cell.currentWeight3.text = "0.0"
//                                        cell.originalCurrentWeight3_Text = "0.0"
//                                    }
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }

                    // Previous Weight Fields
                    if let workoutObjects = CDOperation.getRepWeightTextForExercise(session, routine: workoutRoutine, workout: selectedWorkout, exercise: titleArray![0] as! String, index: (workoutIndex - 1) as NSNumber) as? [Workout] {
                        
                        if debug == 1 {
                            
                            print("Objects in array: \(workoutObjects.count)")
                        }
                        
                        for object in workoutObjects {
                            
                            // Reps
                            var tempReps = ""
                            
                            if object.reps != nil {
                                
                                tempReps = object.reps!
                            }
                            else {
                                
                                tempReps = "0.0"
                            }
                            
                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Reps = \(tempReps)")
                            }

                            // Weight
                            var tempWeight = ""
                            
                            if object.weight != nil {
                                
                                tempWeight = object.weight!
                            }
                            else {
                                
                                tempWeight = "0.0"
                            }

                            if debug == 1 {
                                
                                print("Round = \(object.round!) - Weight = \(tempWeight)")
                            }
                        }
                        
                        if workoutObjects.count != 0 {
                            
                            for object in workoutObjects {
                                
                                switch CDOperation.renameRoundStringToInt(object.round!) {
                                case 0:
                                    cell.previousRep1.text = object.reps
                                    cell.previousWeight1.text = object.weight
                                    
                                    cell.previousNotes.text = object.notes?.uppercased()
                                    
                                case 1:
                                    cell.previousRep2.text = object.reps
                                    cell.previousWeight2.text = object.weight
                                    
//                                case 2:
//                                    cell.previousRep3.text = object.reps
//                                    cell.previousWeight3.text = object.weight
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                    
                    
                    
                                        
                    
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    if self.graphViewPurchased {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("GraphView was purchased")
                        }
                    }
                    else if appDelegate.shouldShowRewardGraph {
                        
                        cell.graphButton.isHidden = false
                        cell.rewardVideoButton.isHidden = true
                        
                        if debug == 1 {
                            
                            print("Reward GraphView was purchased")
                        }
                    }
                    else {
                        
                        cell.graphButton.isHidden = true
                        cell.rewardVideoButton.isHidden = false
                    }
                    
                    
                    
                    
                    
                    
//                    //  TESTING PURPOSES ONLY!!!  COMMENT OUT WHEN DONE TAKING SCREENSHOTS
//                    cell.graphButton.isHidden = false
                    
                    
                    return cell
                }
                else if cellIdentifier == "ShuffleCell" {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTVC_ShuffleTableViewCell
                    
                    cell.segmentedControlTap = { (WorkoutTVC_ShuffleTableViewCell) in
                        
                        // Add Code here
                        self.segmentedControlTitle = cell.roundSegmentedControl.titleForSegment(at: cell.roundSegmentedControl.selectedSegmentIndex)!
                        
                        if self.segmentedControlTitle == "Round 1" {
                            
                            self.loadExerciseNameArray(self.selectedWorkout)
                        }
                        else {
                            
                            // Round 2
                            self.loadShuffledExerciseNameArray()
                        }
                        
                        //  Reload tableview and scroll to the top.
                        self.tableView.reloadData()
                        
                        var newIndexPath = indexPath
                        newIndexPath.section = 0
                        newIndexPath.row = 0
                        self.tableView.scrollToRow(at: newIndexPath, at: UITableViewScrollPosition.none, animated: true)
                    }
                    
                    return cell
                }
                else {
                    
                    // CompletionCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTVC_CompletionTableViewCell
                    
                    cell.workoutRoutine = workoutRoutine // Bulk or Tone
                    cell.selectedWorkout = selectedWorkout // B1: Chest+Tri etc...
                    cell.workoutIndex = workoutIndex // Index of the workout in the program
                    cell.session = session
                    cell.indexPath = indexPath
                    
                    cell.updateWorkoutCompleteCellUI()
                    
                    cell.previousDateButton.addTarget(self, action: #selector(WorkoutTVC.previousButtonPressed(_:)), for: .touchUpInside)
                    
                    workoutCompleteCell = cell
                    
                    return cell
                }
            }
        }
        
        let emptyCell = UITableViewCell()
        
        return emptyCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section != numberOfSections(in: tableView) - 1 {
            
            return "Set \(section + 1) of \(numberOfSections(in: tableView) - 1)"
        }
        else {
            
            return "Finished"
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // Set the color of the header/footer text
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        
        // Set the background color of the header/footer
        header.contentView.backgroundColor = UIColor (red: 130/255, green: 155/255, blue: 203/255, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        if selectedCellIdentifier == "PreviousButtonPressed" {
            
            workoutCompleteCell.updateWorkoutCompleteCellUI()
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        
        if debug == 1 {
            
            print("Previous Button Pressed")
        }

        selectedCellIdentifier = "PreviousButtonPressed"
        
        let popOverContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
        
        popOverContent.session = session
        popOverContent.workoutRoutine = workoutRoutine
        popOverContent.selectedWorkout = selectedWorkout
        popOverContent.workoutIndex = workoutIndex
        
        popOverContent.modalPresentationStyle = .popover
        
        let popOver = popOverContent.popoverPresentationController
        popOver?.sourceView = sender
        popOver?.sourceRect = sender.bounds
        popOver?.permittedArrowDirections = .any
        popOver?.delegate = self
        
        present(popOverContent, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowShinobiChart" {
            
            let destinationNavController = segue.destination as? UINavigationController
            let destinationVC = destinationNavController?.topViewController as! ExerciseChartViewController
            
            destinationVC.session = self.session
            destinationVC.workoutRoutine = self.workoutRoutine
            destinationVC.selectedWorkout = self.selectedWorkout
            destinationVC.workoutIndex = self.workoutIndex
            
            let button = sender as! UIButton
            let view = button.superview
            let cell = view?.superview as! WorkoutTVC_WorkoutTableViewCell
            
            destinationVC.exerciseName = cell.nonUpperCaseExerciseName
            destinationVC.navigationItem.title = CDOperation.trimStringForWorkoutName(self.selectedWorkout)
            
            // Find the number of series to show on the graph and pass it to ExerciseChartViewController
            // Find the series configuration to layout the graph and pass it to ExerciseChartViewController
            // 0 = OFF
            // 1 = ON
            if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == false &&
                cell.currentWeight1.isHidden == false &&
                cell.currentWeight2.isHidden == false {
                
                //  Both round 1 and round 2 Reps and Weight fields are showing
                destinationVC.numberOfSeriesToShow = 4
                destinationVC.seriesConfiguration = 1111 // ON, ON, ON, ON
            }
            else if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == false &&
                cell.currentWeight1.isHidden == true &&
                cell.currentWeight2.isHidden == true {
                
                //  Only round 1 and round 2 Reps fields are showing
                destinationVC.numberOfSeriesToShow = 2
                destinationVC.seriesConfiguration = 1010 // ON, OFF, ON, OFF
            }
            else if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == true &&
                cell.currentWeight1.isHidden == false &&
                cell.currentWeight2.isHidden == true {
                
                //  Only round 1 Reps and Weight fields are showing
                destinationVC.numberOfSeriesToShow = 2
                destinationVC.seriesConfiguration = 1100 // ON, ON, OFF, OFF
            }
            else if cell.currentRep1.isHidden == false &&
                cell.currentRep2.isHidden == true &&
                cell.currentWeight1.isHidden == true &&
                cell.currentWeight2.isHidden == true {
                
                //  Only round 1 Reps fields are showing
                destinationVC.numberOfSeriesToShow = 1
                destinationVC.seriesConfiguration = 1000 // ON, OFF, OFF, OFF
            }

            let exerciseName = cell.nonUpperCaseExerciseName
            
            if debug == 1 {
                
                print("Exercise Name = \(exerciseName)")
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    func loadExerciseNameArray(_ workout: String) {
        
        switch workout {
        case "Chest + Back & Ab Workout":
            
            let cell1 = [["Push-Ups"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true], // isHidden
                         [CellType.straight_2]]
            
            let cell2 = [["Wide Pull-Ups"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell3 = [["Shoulder Width Push-Ups"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell4 = [["Underhand Pull-Ups"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell5 = [["Wide Push-Ups"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell6 = [["Narrow Pull-Ups"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell7 = [["Decline Push-Ups"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell8 = [["Bent Over Rows"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell9 = [["Diamonds"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell10 = [["Single Arm Bent Over Rows"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.straight_2]]
            
            let cell11 = [["Under The Wall"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, true, false, true, true, true],
                          [CellType.straight_2]]
            
            let cell12 = [["Seated Back Flys"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light,Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.straight_2]]
            
            let cell13 = [["Shuffle The Next Round"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light,Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.shuffle]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4],
                         [cell5, cell6, cell7, cell8],
                         [cell9, cell10, cell11, cell12, cell13],
                         [completeCell]]
            
        case "Shoulders + Arms & Ab Workout":
            
            let cell1 = [["Shoulder Presses"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true], // isHidden
                         [CellType.straight_2]]
            
            let cell2 = [["2-Way Bicep Curls"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell3 = [["Tricep Extensions"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell4 = [["Curl/Shoulder Presses"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell5 = [["Single Concentration Bicep Curls"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell6 = [["Dips"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, true, false, true, true, true],
                         [CellType.straight_2]]
            
            let cell7 = [["Chin Rows"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell8 = [["Parallel Bicep Curls"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell9 = [["Twisting Tricep Extentions"],
                         [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                         [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                         [false, false, false, false, true, true],
                         [CellType.straight_2]]
            
            let cell10 = [["Seated Shoulder Flys"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.straight_2]]
            
            let cell11 = [["Double Concentration Bicep Curls"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.straight_2]]
            
            let cell12 = [["Overhead Tricep Extensions"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.straight_2]]
            
            let cell13 = [["2-Way Shoulder Flys"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.straight_2]]
            
            let cell14 = [["Hammer Bicep Curls"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, false, false, false, true, true],
                          [CellType.straight_2]]
            
            let cell15 = [["Bodyweight Tricep Extensions"],
                          [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                          [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                          [false, true, false, true, true, true],
                          [CellType.straight_2]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3],
                         [cell4, cell5, cell6],
                         [cell7, cell8, cell9],
                         [cell10, cell11, cell12],
                         [cell13, cell14, cell15],
                         [completeCell]]
            
        case "Legs + Back & Ab Workout":
            
            let cell1 = [["Chair Lunges"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell2 = [["Squat to Calf Extensions"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Underhand Pull-Ups 1"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["Single Leg Lunges"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["Hold Parallel Squats"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Wide Pull-Ups 1"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["Reverse Lunges"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["Side Lunges"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["Narrow Pull-Ups 1"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["1 Leg Hold Parallel Squats"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Deadlifts"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["2-Way Pull-Ups 1"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["3-Way Lunges"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell14 = [["Toe Lunges"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell15 = [["Underhand Pull-Ups 2"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell16 = [["Chair Squats"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell17 = [["Lunge Calf Extensions"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell18 = [["Wide Pull-Ups 2"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell19 = [["Crouching Tiger"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell20 = [["Calf Raises"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell21 = [["Narrow Pull-Ups 2"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell22 = [["1 Leg Squats"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell23 = [["2-Way Pull-Ups 2"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9, cell10, cell11, cell12],
                         [cell13, cell14, cell15, cell16, cell17, cell18, cell19, cell20, cell21, cell22, cell23],
                         [completeCell]]
            
        case "Chest + Shoulders + Tri & Ab Workout":
            
            let cell1 = [["3-Way Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell2 = [["2-Way Shoulder Flys"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Dips"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["Upside Down Shoulder Presses"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Bodyweight Tricep Extensions"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["Side Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["Shoulder Rotations"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["Tricep Extensions 1"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["2-Way Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Shoulder Presses"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["Tricep Extensions 2"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["Lateral Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell14 = [["Lateral Shoulder Raises"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell15 = [["Tricep Extensions 3"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell16 = [["1-Arm Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell17 = [["Side Shoulder Circles"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell18 = [["Footballs"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell19 = [["Plyometric Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell20 = [["Front Shoulder Raises"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell21 = [["Tricep Extensions 4"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell22 = [["Side Plank Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell23 = [["3-Way Arms"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell24 = [["Chest Presses"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9, cell10, cell11, cell12],
                         [cell13, cell14, cell15, cell16, cell17, cell18, cell19, cell20, cell21, cell22, cell23, cell24],
                         [completeCell]]
            
        case "Back + Biceps & Ab Workout":
            
            let cell1 = [["Wide Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell2 = [["Single Arm Bent Over Rows 1"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Bicep Curls 1"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["Bicep Curls 2"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["2-Way Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Single Arm Bent Over Rows 2"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["Bicep Curls 3"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["Concentration Curls"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["Side to Side Pull-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["Bent Over Rows"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Wide Arm Curls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["Parallel Bicep Curls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["Uneven Pull-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell14 = [["Alternating Bent Over Rows"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell15 = [["Double Concentration Bicep Curls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell16 = [["Bicep Curls 4"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell17 = [["Underhand Pull-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell18 = [["Seated Back Flys"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell19 = [["Bicep Curls 5"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell20 = [["Hammer Curls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell21 = [["Pull-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell22 = [["Lower Back Raises"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell23 = [["2-Way Hammer Curls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell24 = [["Burnout Bicep Curls 1"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell25 = [["Burnout Bicep Curls 2"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell26 = [["Burnout Bicep Curls 3"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell27 = [["Burnout Bicep Curls 4"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9, cell10, cell11, cell12],
                         [cell13, cell14, cell15, cell16, cell17, cell18, cell19, cell20, cell21, cell22, cell23, cell24, cell25, cell26, cell27],
                         [completeCell]]
            
        case "Core Fitness":
            
            let cell1 = [["Offset Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell2 = [["Back to Stomach 1"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell3 = [["Side Lunges"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell4 = [["Runner Lunges"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell5 = [["Push-Ups"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell6 = [["Back to V"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell7 = [["Deep Side Lunges"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell8 = [["Top Shelf"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, false, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell9 = [["Burpees"],
                         [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                         [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                         [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                         [false, true, true, true, true, true],
                         [CellType.straight_1]]
            
            let cell10 = [["Side Sphinx Raises"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell11 = [["Squat Press"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell12 = [["Plank Crunches"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell13 = [["Plank Crawls"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell14 = [["Back to Stomach 2"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell15 = [["Lunge to 3 Way Arms"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, false, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell16 = [["Line Jumps"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell17 = [["Half Plank Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell18 = [["Standing Crunches"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell19 = [["Squat Jumps"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell20 = [["Plank Push-Ups"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell21 = [["Tractor Tires"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let cell22 = [["Dips"],
                          [Round.round1, Round.empty, Round.empty, Round.empty, Round.empty, Round.empty],
                          [LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty, LabelType.empty, LabelType.empty],
                          [Color.light, Color.dark, UIColor.white, UIColor.white, UIColor.white, UIColor.white],
                          [false, true, true, true, true, true],
                          [CellType.straight_1]]
            
            let completeCell = [[],
                                [],
                                [],
                                [],
                                [],
                                [CellType.completion]]
            
            cellArray = [[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8],
                         [cell9, cell10, cell11, cell12, cell13, cell14, cell15, cell16],
                         [cell17, cell18, cell19, cell20, cell21, cell22],
                         [completeCell]]
            
        default:
            break
        }
    }
    
    func loadShuffledExerciseNameArray() {
        
        // Shuffled cells for "Chest + Back & Ab Workout"
        
        let cell1 = [["Wide Pull-Ups"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, true, false, true, true, true],
                     [CellType.straight_2]]
        
        let cell2 = [["Push-Ups"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, true, false, true, true, true], // isHidden
            [CellType.straight_2]]
                
        let cell3 = [["Underhand Pull-Ups"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, true, false, true, true, true],
                     [CellType.straight_2]]
        
        let cell4 = [["Shoulder Width Push-Ups"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, true, false, true, true, true],
                     [CellType.straight_2]]
        
        let cell5 = [["Narrow Pull-Ups"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, true, false, true, true, true],
                     [CellType.straight_2]]
        
        let cell6 = [["Wide Push-Ups"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, true, false, true, true, true],
                     [CellType.straight_2]]
        
        let cell7 = [["Bent Over Rows"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, false, false, false, true, true],
                     [CellType.straight_2]]
        
        let cell8 = [["Decline Push-Ups"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, true, false, true, true, true],
                     [CellType.straight_2]]
        
        let cell9 = [["Single Arm Bent Over Rows"],
                     [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                     [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                     [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                     [false, false, false, false, true, true],
                     [CellType.straight_2]]
        
        let cell10 = [["Diamonds"],
                      [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                      [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                      [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                      [false, true, false, true, true, true],
                      [CellType.straight_2]]
        
        let cell11 = [["Seated Back Flys"],
                      [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                      [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                      [Color.light,Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                      [false, false, false, false, true, true],
                      [CellType.straight_2]]
        
        let cell12 = [["Under The Wall"],
                      [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                      [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                      [Color.light, Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                      [false, true, false, true, true, true],
                      [CellType.straight_2]]
        
        let cell13 = [["Shuffle The Next Round"],
                      [Round.round1, Round.round2, Round.empty, Round.empty, Round.empty, Round.empty],
                      [LabelType.reps, LabelType.weight, LabelType.reps, LabelType.weight, LabelType.empty, LabelType.empty],
                      [Color.light,Color.light, Color.dark, Color.dark, UIColor.white, UIColor.white],
                      [false, false, false, false, true, true],
                      [CellType.shuffle]]
        
        let completeCell = [[],
                            [],
                            [],
                            [],
                            [],
                            [CellType.completion]]
        
        cellArray = [[cell1, cell2, cell3, cell4],
                     [cell5, cell6, cell7, cell8],
                     [cell9, cell10, cell11, cell12, cell13],
                     [completeCell]]
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
