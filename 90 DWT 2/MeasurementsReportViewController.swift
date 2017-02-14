//
//  MeasurementsReportViewController.swift
//  90 DWT 1
//
//  Created by Grant, Jared on 8/2/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import CoreData
import Social

class MeasurementsReportViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate {
    
    // **********
    let debug = 0
    // **********
    
    @IBOutlet weak var htmlView: UIWebView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var session = ""
    var month1Array = NSMutableArray()
    var month2Array = NSMutableArray()
    var month3Array = NSMutableArray()
    var finalArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadMeasurements()
        self.htmlView.loadHTMLString(self.createHTML() as String, baseURL: nil)
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
    
    func doNothing() {
        
        // Do nothing
        
        self.loadMeasurements()
        self.htmlView.loadHTMLString(self.createHTML() as String, baseURL: nil)
    }

    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Share", message: "", preferredStyle: .actionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: {
            action in
            
            self.emailSummary()
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
    
    func emailSummary() {
        
        // Create MailComposerViewController object.
        let mailcomposer = MFMailComposeViewController()
        mailcomposer.mailComposeDelegate = self
        mailcomposer.navigationBar.tintColor = UIColor.white
        
        let writeString = NSMutableString()
        
        // Check to see if the device has at least 1 email account configured
        if MFMailComposeViewController.canSendMail() {
            
            // Create an array of measurements to iterate thru when building the table rows.
            let measurementsArray = [self.month1Array, self.month2Array, self.month3Array, self.finalArray]
            let measurementsMonth = ["Start Month 1", "Start Month 2", "Start Month 3", "Final"]
            
            writeString.append("Session,Month,Weight,Chest,Left Arm,Right Arm,Waist,Hips,Left Thigh,Right Thigh\n")
            
            for i in 0..<measurementsMonth.count {
                
                writeString.appendFormat("%@,%@", self.session, measurementsMonth[i])
                
                for j in 0..<self.month1Array.count {
                    
                    writeString.appendFormat(",%@", measurementsArray[i][j] as! String)
                }
                
                writeString.append("\n")
            }
        }
        
        // Send email
        let csvData = writeString.data(using: String.Encoding.ascii.rawValue)
        let subject = NSString .localizedStringWithFormat("90 DWT 1 %@ Measurements - Session %@", self.navigationItem.title!, session)
        let fileName = NSString .localizedStringWithFormat("90 DWT 1 %@ Measurements - Session %@.csv", self.navigationItem.title!, session)
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }

    func loadMeasurements() {
        
        let monthArray = ["1",
                          "2",
                          "3",
                          "4"]
        
        // Get workout data with the current session
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Measurement")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        for i in 0..<monthArray.count {
            
            let filter = NSPredicate(format: "session == %@ AND month == %@",
                                     session,
                                     monthArray[i])
            
            request.predicate = filter

            do {
                if let measurementObjects = try CoreDataHelper.shared().context.fetch(request) as? [Measurement] {
                    
                    if debug == 1 {
                        
                        print("measurementObjects.count = \(measurementObjects.count)")
                    }
                    
                    if measurementObjects.count >= 1 {
                        
                        if monthArray[i] == "1" {
                            
                            // Weight
                            if measurementObjects.last?.weight == "" || measurementObjects.last?.weight == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.weight)!)
                            }
                            
                            // Chest
                            if measurementObjects.last?.chest == "" || measurementObjects.last?.chest == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.chest)!)
                            }
                            
                            // Left Arm
                            if measurementObjects.last?.leftArm == "" || measurementObjects.last?.leftArm == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.leftArm)!)
                            }
                            
                            // Right Arm
                            if measurementObjects.last?.rightArm == "" || measurementObjects.last?.rightArm == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.rightArm)!)
                            }
                            
                            // Waist
                            if measurementObjects.last?.waist == "" || measurementObjects.last?.waist == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.waist)!)
                            }
                            
                            // Hips
                            if measurementObjects.last?.hips == "" || measurementObjects.last?.hips == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.hips)!)
                            }
                            
                            // Left Thigh
                            if measurementObjects.last?.leftThigh == "" || measurementObjects.last?.leftThigh == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.leftThigh)!)
                            }
                            
                            // Right Thigh
                            if measurementObjects.last?.rightThigh == "" || measurementObjects.last?.rightThigh == nil {
                                self.month1Array.add("0")
                            }
                            else {
                                self.month1Array.add((measurementObjects.last?.rightThigh)!)
                            }
                        }
                        
                        else if monthArray[i] == "2" {
                            
                            // Weight
                            if measurementObjects.last?.weight == "" || measurementObjects.last?.weight == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.weight)!)
                            }
                            
                            // Chest
                            if measurementObjects.last?.chest == "" || measurementObjects.last?.chest == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.chest)!)
                            }
                            
                            // Left Arm
                            if measurementObjects.last?.leftArm == "" || measurementObjects.last?.leftArm == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.leftArm)!)
                            }
                            
                            // Right Arm
                            if measurementObjects.last?.rightArm == "" || measurementObjects.last?.rightArm == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.rightArm)!)
                            }
                            
                            // Waist
                            if measurementObjects.last?.waist == "" || measurementObjects.last?.waist == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.waist)!)
                            }
                            
                            // Hips
                            if measurementObjects.last?.hips == "" || measurementObjects.last?.hips == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.hips)!)
                            }
                            
                            // Left Thigh
                            if measurementObjects.last?.leftThigh == "" || measurementObjects.last?.leftThigh == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.leftThigh)!)
                            }
                            
                            // Right Thigh
                            if measurementObjects.last?.rightThigh == "" || measurementObjects.last?.rightThigh == nil {
                                self.month2Array.add("0")
                            }
                            else {
                                self.month2Array.add((measurementObjects.last?.rightThigh)!)
                            }
                        }

                        else if monthArray[i] == "3" {
                            
                            // Weight
                            if measurementObjects.last?.weight == "" || measurementObjects.last?.weight == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.weight)!)
                            }
                            
                            // Chest
                            if measurementObjects.last?.chest == "" || measurementObjects.last?.chest == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.chest)!)
                            }
                            
                            // Left Arm
                            if measurementObjects.last?.leftArm == "" || measurementObjects.last?.leftArm == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.leftArm)!)
                            }
                            
                            // Right Arm
                            if measurementObjects.last?.rightArm == "" || measurementObjects.last?.rightArm == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.rightArm)!)
                            }
                            
                            // Waist
                            if measurementObjects.last?.waist == "" || measurementObjects.last?.waist == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.waist)!)
                            }
                            
                            // Hips
                            if measurementObjects.last?.hips == "" || measurementObjects.last?.hips == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.hips)!)
                            }
                            
                            // Left Thigh
                            if measurementObjects.last?.leftThigh == "" || measurementObjects.last?.leftThigh == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.leftThigh)!)
                            }
                            
                            // Right Thigh
                            if measurementObjects.last?.rightThigh == "" || measurementObjects.last?.rightThigh == nil {
                                self.month3Array.add("0")
                            }
                            else {
                                self.month3Array.add((measurementObjects.last?.rightThigh)!)
                            }
                        }

                        else if monthArray[i] == "4" {
                            
                            // Weight
                            if measurementObjects.last?.weight == "" || measurementObjects.last?.weight == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.weight)!)
                            }
                            
                            // Chest
                            if measurementObjects.last?.chest == "" || measurementObjects.last?.chest == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.chest)!)
                            }
                            
                            // Left Arm
                            if measurementObjects.last?.leftArm == "" || measurementObjects.last?.leftArm == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.leftArm)!)
                            }
                            
                            // Right Arm
                            if measurementObjects.last?.rightArm == "" || measurementObjects.last?.rightArm == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.rightArm)!)
                            }
                            
                            // Waist
                            if measurementObjects.last?.waist == "" || measurementObjects.last?.waist == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.waist)!)
                            }
                            
                            // Hips
                            if measurementObjects.last?.hips == "" || measurementObjects.last?.hips == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.hips)!)
                            }
                            
                            // Left Thigh
                            if measurementObjects.last?.leftThigh == "" || measurementObjects.last?.leftThigh == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.leftThigh)!)
                            }
                            
                            // Right Thigh
                            if measurementObjects.last?.rightThigh == "" || measurementObjects.last?.rightThigh == nil {
                                self.finalArray.add("0")
                            }
                            else {
                                self.finalArray.add((measurementObjects.last?.rightThigh)!)
                            }
                        }
                    }
                    
                    else {
                        
                        if monthArray[i] == "1" {
                            
                            self.month1Array.add("0")
                            self.month1Array.add("0")
                            self.month1Array.add("0")
                            self.month1Array.add("0")
                            self.month1Array.add("0")
                            self.month1Array.add("0")
                            self.month1Array.add("0")
                            self.month1Array.add("0")
                        }
                        
                        else if monthArray[i] == "2" {
                            
                            self.month2Array.add("0")
                            self.month2Array.add("0")
                            self.month2Array.add("0")
                            self.month2Array.add("0")
                            self.month2Array.add("0")
                            self.month2Array.add("0")
                            self.month2Array.add("0")
                            self.month2Array.add("0")
                        }
                        
                        else if monthArray[i] == "3" {
                            
                            self.month3Array.add("0")
                            self.month3Array.add("0")
                            self.month3Array.add("0")
                            self.month3Array.add("0")
                            self.month3Array.add("0")
                            self.month3Array.add("0")
                            self.month3Array.add("0")
                            self.month3Array.add("0")
                        }
                        
                        else if monthArray[i] == "4" {
                            
                            self.finalArray.add("0")
                            self.finalArray.add("0")
                            self.finalArray.add("0")
                            self.finalArray.add("0")
                            self.finalArray.add("0")
                            self.finalArray.add("0")
                            self.finalArray.add("0")
                            self.finalArray.add("0")
                        }
                    }
                }
                
            } catch { print(" ERROR executing a fetch request: \( error)") }
        }
    }
    
    func createHTML() -> NSString {
        
        // Create an array of measurements to iterate thru when building the table rows.
        let measurementsArray = [self.month1Array, self.month2Array, self.month3Array, self.finalArray]
        let measurementsNameArray = ["Weight", "Chest", "Left Arm", "Right Arm", "Waist", "Hips", "Left Thigh", "Right Thigh"]
        
        var myHTML = "<html><head>"
        
        // Table Style
        myHTML = myHTML.appendingFormat("<STYLE TYPE='text/css'><!--TD{font-family: Arial; font-size: 12pt;}TH{font-family: Arial; font-size: 14pt;}---></STYLE></head><body><table border='1' bordercolor='#3399FF' style='background-color:#CCCCCC' width='%f' cellpadding='2' cellspacing='1'>", self.htmlView.frame.size.width - 15)
        
        // Table Headers
        myHTML = myHTML.appendingFormat("<tr><th style='background-color:#999999'>Session %@</th><th style='background-color:#999999'>1</th><th style='background-color:#999999'>2</th><th style='background-color:#999999'>3</th><th style='background-color:#999999'>Final</th></tr>", session)
        
        // Table Data
        for i in 0..<measurementsNameArray.count {
            
            myHTML = myHTML.appendingFormat("<tr><td style='background-color:#999999'>%@</td>", measurementsNameArray[i])
            
            for a in 0..<measurementsArray.count {
                
                myHTML = myHTML.appendingFormat("<td>%@</td>", measurementsArray[a][i] as! String)
            }
            
            myHTML = myHTML + "</tr>"
        }
        
        // HTML closing tags
        myHTML = myHTML + "</table></body></html>"
        
        return myHTML as NSString
    }
}
