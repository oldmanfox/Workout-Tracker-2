//
//  NotesViewController.swift
//  90 DWT 1
//
//  Created by Grant, Jared on 8/1/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import Social
import CoreData

class NotesViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, MPAdViewDelegate {
    
    // **********
    let debug = 0
    // **********
    
    var session = ""
    var selectedWorkout = ""
    var workoutIndex = 0
    var originalNoteText = ""
    var workoutWeek = ""
    var month = ""

    var adView = MPAdView()
    var bannerSize = CGSize()
    
    var bottomAlignedY = CGFloat()
    
    @IBOutlet weak var currentNotes: UITextView!
    @IBOutlet weak var previousNotes: UITextView!
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var currentNotesLabel: UILabel!
    @IBOutlet weak var previousNotesLabel: UILabel!
    @IBOutlet weak var shareActionButton: UIBarButtonItem!
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var deleteDateButton: UIButton!
    @IBOutlet weak var todayDateButton: UIButton!
    @IBOutlet weak var previousDateButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        currentNotes.delegate = self
        
        self.roundLabel.isHidden = true
        
        // Apply Border to TextViews
        self.currentNotes.layer.borderWidth = 0.5
        self.currentNotes.layer.borderColor = UIColor.lightGray.cgColor
        //self.currentNotes.layer.cornerRadius = 5
        self.currentNotes.clipsToBounds = true
        
        self.previousNotes.layer.borderWidth = 0.5
        self.previousNotes.layer.borderColor = UIColor.lightGray.cgColor
        //self.previousNotes.layer.cornerRadius = 5
        self.previousNotes.clipsToBounds = true
        
        // Get data to display in the textfields
        // Current textfield
        currentNotes.text = CDOperation.getNotesTextForRound(session, workout: selectedWorkout, round: "Round 1", index: workoutIndex as NSNumber)
        self.originalNoteText = currentNotes.text
        
        // Previous textfield
        previousNotes.text = CDOperation.getNotesTextForRound(session, workout: selectedWorkout, round: "Round 1", index: workoutIndex - 1  as NSNumber)
        
        updateWorkoutCompleteCellUI()
        
        if Products.store.isProductPurchased("com.grantsoftware.90DWT2.removeads1") {
            
            // User purchased the Remove Ads in-app purchase so don't show any ads.
        }
        else {
            
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
            
            self.bottomAlignedY = self.view.bounds.size.height - self.bannerSize.height - (self.tabBarController?.tabBar.bounds.size.height)!
            
            self.adView.frame = CGRect(x: (self.view.bounds.size.width - self.bannerSize.width) / 2,
                                           y: self.bottomAlignedY,
                                           width: self.bannerSize.width, height: self.bannerSize.height)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show or Hide Ads
        if Products.store.isProductPurchased("com.grantsoftware.90DWT2.removeads1") {
            
            // Don't show ads.
            self.adView.delegate = nil
            
        } else {
            
            // Show ads
            self.view.addSubview(self.adView)
            
            self.adView.loadAd()
            
            self.adView.isHidden = true;
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force fetch when notified of significant data changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.doNothing), name: NSNotification.Name(rawValue: "SomethingChanged"), object: nil)
        
        // Show or Hide Ads
        if Products.store.isProductPurchased("com.grantsoftware.90DWT2.removeads1") {
            
            // Don't show ads.
            self.adView.delegate = nil
            
        } else {
            
            // Show ads
            self.adView.frame = CGRect(x: (self.view.bounds.size.width - self.bannerSize.width) / 2,
                                           y: self.view.bounds.size.height - self.bannerSize.height - self.tabBarController!.tabBar.bounds.size.height,
                                           width: self.bannerSize.width, height: self.bannerSize.height)
            self.adView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        saveNote()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
        
        self.adView.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
//        
//        self.adView.removeFromSuperview()
    }
    
    func doNothing() {
        
        // Do nothing
        
        // Get data to display in the textfields
        // Current textfield
        currentNotes.text = CDOperation.getNotesTextForRound(session, workout: selectedWorkout, round: "Round 1", index: workoutIndex as NSNumber)
        self.originalNoteText = currentNotes.text
        
        // Previous textfield
        previousNotes.text = CDOperation.getNotesTextForRound(session, workout: selectedWorkout, round: "Round 1", index: workoutIndex - 1 as NSNumber)
        
        updateWorkoutCompleteCellUI()
    }
    
    func saveNote() {
        
        if currentNotes.text != "" && currentNotes.text != originalNoteText {
            
            CDOperation.saveNoteWithPredicateNoExercise(session, workout: selectedWorkout, month: month, week: workoutWeek, index: workoutIndex as NSNumber, note: currentNotes.text, round: "Round 1")
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        
        saveNote()
        
        let alertController = UIAlertController(title: "Share", message: "How you want to share your progress?", preferredStyle: .actionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: {
            action in
            
            self.emailResults()
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
    
    @IBAction func deleteDateButtonPressed(_ sender: UIButton) {
        
        CDOperation.deleteDate(session as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber)
        
        updateWorkoutCompleteCellUI()
    }
    
    @IBAction func todayDateButtonPressed(_ sender: UIButton) {
        
        CDOperation.saveWorkoutCompleteDate(session as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber, useDate: Date())
        
        updateWorkoutCompleteCellUI()
    }
    
    @IBAction func previousDateButtonPressed(_ sender: UIButton) {
        
        if debug == 1 {
            
            print("Previous Button Pressed")
        }
        
        let popOverContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
        
        popOverContent.session = session
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
    
    func updateWorkoutCompleteCellUI () {
        
        let workoutCompletedObjects = CDOperation.getWorkoutCompletedObjects(session as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber)
        
        switch  workoutCompletedObjects.count {
        case 0:
            // No match
            
            // Cell
            datePickerView.backgroundColor = UIColor.white
            
            // Label
            dateLabel.text = "Workout Completed: __/__/__";
            dateLabel.textColor = UIColor.black
            
        default:
            // Found a match.
            
            let object = workoutCompletedObjects.last
            let completedDate = DateFormatter .localizedString(from: (object?.date)! as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
            
            // Cell
            datePickerView.backgroundColor = UIColor.darkGray
            
            // Label
            dateLabel.text? = "Workout Completed: \(completedDate)"
            dateLabel.textColor = UIColor.white
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        updateWorkoutCompleteCellUI()
    }
    
    func emailResults() {
    
        // Create MailComposerViewController object.
        let mailcomposer = MFMailComposeViewController()
        mailcomposer.mailComposeDelegate = self
        mailcomposer.navigationBar.tintColor = UIColor.white
        
        // Check to see if the device has at least 1 email account configured
        if MFMailComposeViewController.canSendMail() {
            
            // Get the objects for the current session
            let workoutObjects = CDOperation.getNoteObjects(session as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber)
            
            let writeString = NSMutableString()
            
            if workoutObjects.count != 0 {
                
                writeString.append("Session,Month,Week,Workout,Notes,Date\n")
                
                for i in 0..<workoutObjects.count {
                    
                    let session = workoutObjects[i].session
                    let month = workoutObjects[i].month
                    let week  = workoutObjects[i].week
                    let workout = workoutObjects[i].workout
                    let notes = workoutObjects[i].notes
                    let date = workoutObjects[i].date

                    let dateString = DateFormatter.localizedString(from: date! as Date, dateStyle: .short, timeStyle: .none)
                    
                    writeString.append("\(session!),\(month),\(week),\(workout!),\(notes!),\(dateString)\n")
                }
            }
            
            // Send email
            
            let csvData = writeString.data(using: String.Encoding.ascii.rawValue)
            let workoutName = selectedWorkout + ".csv"
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
            mailcomposer.setSubject("90 DWT 1 Workout Data")
            mailcomposer.addAttachmentData(csvData!, mimeType: "text/csv", fileName: workoutName)
            
            present(mailcomposer, animated: true, completion: {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            })
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        currentNotes.resignFirstResponder()
        
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            currentNotes.resignFirstResponder()
            saveNote()
            return false
        }
        
        return true
    }
    
    @IBAction func hideKeyboard(_ sender: UIButton) {
        
        self.currentNotes.resignFirstResponder()
        saveNote()
    }

    // MARK: - <MPAdViewDelegate>
    func viewControllerForPresentingModalView() -> UIViewController! {
        
        return self
    }
    
    func adViewDidLoadAd(_ view: MPAdView!) {
        
        let size = view.adContentViewSize()
        let centeredX = (self.view.bounds.size.width - size.width) / 2
        
        if (self.tabBarController?.tabBar.bounds.size.height) != nil {
            
            self.bottomAlignedY = self.view.bounds.size.height - size.height - (self.tabBarController?.tabBar.bounds.size.height)!
        }
        
        //let bottomAlignedY = self.view.bounds.size.height - size.height - (self.tabBarController!.tabBar.bounds.size.height)
        
        view.frame = CGRect(x: centeredX, y: self.bottomAlignedY, width: size.width, height: size.height)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.adView.isHidden = true
        self.adView.rotate(to: toInterfaceOrientation)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        let size = self.adView.adContentViewSize()
        let centeredX = (self.view.bounds.size.width - size.width) / 2
        let bottomAlignedY = self.view.bounds.size.height - size.height - self.tabBarController!.tabBar.bounds.size.height
        
        self.adView.frame = CGRect(x: centeredX, y: bottomAlignedY, width: size.width, height: size.height)
        
        self.adView.isHidden = false
    }
}
