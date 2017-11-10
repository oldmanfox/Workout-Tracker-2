//
//  MeasurementsRecordViewController.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 8/2/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import CoreData
import Social

class MeasurementsRecordViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate {

    // **********
    let debug = 0
    // **********
    
    // Text Fields
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var chest: UITextField!
    @IBOutlet weak var leftArm: UITextField!
    @IBOutlet weak var rightArm: UITextField!
    @IBOutlet weak var waist: UITextField!
    @IBOutlet weak var hips: UITextField!
    @IBOutlet weak var leftThigh: UITextField!
    @IBOutlet weak var rightThigh: UITextField!
    
    // Labels
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var chestLabel: UILabel!
    @IBOutlet weak var leftArmLabel: UILabel!
    @IBOutlet weak var rightArmLabel: UILabel!
    @IBOutlet weak var waistLabel: UILabel!
    @IBOutlet weak var hipsLabel: UILabel!
    @IBOutlet weak var leftThightLabel: UILabel!
    @IBOutlet weak var rightThighLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    var session = ""
    var monthString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weight.delegate = self
        chest.delegate = self
        leftArm.delegate = self
        rightArm.delegate = self
        waist.delegate = self
        hips.delegate = self
        leftThigh.delegate = self
        rightThigh.delegate = self
        
        loadMeasurements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force fetch when notified of significant data changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.doNothing), name: NSNotification.Name(rawValue: "SomethingChanged"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
    }
    
    @objc func doNothing() {
        
        // Do nothing
        loadMeasurements()
    }

    func loadMeasurements() {
        
        if let measurementObjects = CDOperation.getMeasurementObjects(session as NSString, month: monthString as NSString) as? [Measurement] {
            
            if debug == 1 {
                
                print("Objects in array: \(measurementObjects.count)")
            }
            
            if measurementObjects.count >= 1 {
                
                let object = measurementObjects.last
                
                weight.text = object?.weight
                chest.text = object?.chest
                waist.text = object?.waist
                hips.text = object?.hips
                leftArm.text = object?.leftArm
                rightArm.text = object?.rightArm
                leftThigh.text = object?.leftThigh
                rightThigh.text = object?.rightThigh
            }
        }
    }
    
    // MARK: - UITextFieldDelegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        weight.resignFirstResponder()
        chest.resignFirstResponder()
        leftArm.resignFirstResponder()
        rightArm.resignFirstResponder()
        waist.resignFirstResponder()
        hips.resignFirstResponder()
        leftThigh.resignFirstResponder()
        rightThigh.resignFirstResponder()
        
        return true
    }
    
    @IBAction func hideKeyboard(_ sender: UIButton) {
        
        weight.resignFirstResponder()
        chest.resignFirstResponder()
        leftArm.resignFirstResponder()
        rightArm.resignFirstResponder()
        waist.resignFirstResponder()
        hips.resignFirstResponder()
        leftThigh.resignFirstResponder()
        rightThigh.resignFirstResponder()
    }
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        
        saveMeasurements()
        
        let alertController = UIAlertController(title: "Share", message: "", preferredStyle: .actionSheet)
        
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
    
    func emailResults() {
        
        // Create MailComposerViewController object.
        let mailcomposer = MFMailComposeViewController()
        mailcomposer.mailComposeDelegate = self
        mailcomposer.navigationBar.tintColor = UIColor.white
        
        // Check to see if the device has at least 1 email account configured
        if MFMailComposeViewController.canSendMail() {
            
            if let measurementObjects = CDOperation.getMeasurementObjects(session as NSString, month: monthString as NSString) as? [Measurement] {
                
                let writeString = NSMutableString()
                
                if measurementObjects.count >= 1 {
                    
                     writeString.append("Session,Month,Weight,Chest,Left Arm,Right Arm,Waist,Hips,Left Thigh,Right Thigh\n")
                    
                    let object = measurementObjects.last
                    
                    let db_Session = object?.session
                    
                    var db_Weight = "0"
                    var db_Chest = "0"
                    var db_LeftArm = "0"
                    var db_RightArm = "0"
                    var db_Waist = "0"
                    var db_Hips = "0"
                    var db_LeftThigh = "0"
                    var db_RightThigh = "0"
                    
                    if object?.weight != "" && object?.weight != nil {
                        db_Weight = (object?.weight)!
                    }
                    
                    if object?.chest != "" && object?.chest != nil {
                        db_Chest = (object?.chest)!
                    }

                    if object?.leftArm != "" && object?.leftArm != nil {
                        db_LeftArm = (object?.leftArm)!
                    }

                    if object?.rightArm != "" && object?.rightArm != nil {
                        db_RightArm = (object?.rightArm)!
                    }

                    if object?.waist != "" && object?.waist != nil {
                        db_Waist = (object?.waist)!
                    }

                    if object?.hips != "" && object?.hips != nil {
                        db_Hips = (object?.hips)!
                    }
                    
                    if object?.leftThigh != "" && object?.leftThigh != nil {
                        db_LeftThigh = (object?.leftThigh)!
                    }
                    
                    if object?.rightThigh != "" && object?.rightThigh != nil {
                        db_RightThigh = (object?.rightThigh)!
                    }
                    
                    writeString.append("\(db_Session!),\(self.navigationItem.title!),\(db_Weight),\(db_Chest),\(db_LeftArm),\(db_RightArm),\(db_Waist),\(db_Hips),\(db_LeftThigh),\(db_RightThigh)\n")
                
                }
                
                // Send email
                
                let csvData = writeString.data(using: String.Encoding.ascii.rawValue)
                let subject = NSString .localizedStringWithFormat("90 DWT 2 %@ Measurements - Session %@", self.navigationItem.title!, session)
                let fileName = NSString .localizedStringWithFormat("90 DWT 2 %@ Measurements - Session %@.csv", self.navigationItem.title!, session)
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
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        saveMeasurements()
        self.hideKeyboard(sender)
    }
    
    func saveMeasurements() {
        
        CDOperation.saveMeasurements(session, month: monthString, weight: weight.text!, chest: chest.text!, waist: waist.text!, hips: hips.text!, leftArm: leftArm.text!, rightArm: rightArm.text!, leftThigh: leftThigh.text!, rightThigh: rightThigh.text!)
    }
}
