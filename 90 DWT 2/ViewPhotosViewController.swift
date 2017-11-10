//
//  ViewPhotosViewController.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 9/19/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import CoreData
import Social

class ViewPhotosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // **********
    let debug = 0
    // **********
    
    @IBOutlet weak var shareActionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayOfImages = [[], []]
    
    var session = ""
    var monthString = ""
    
    var photoAngle = [[], []]
    var photoMonth = [[], []]
    var photoTitles = [[], []]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.getPhotosFromDatabase()
        
        let lightGrey = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
        self.collectionView.backgroundColor = lightGrey
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force fetch when notified of significant data changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.doNothing), name: NSNotification.Name(rawValue: "SomethingChanged"), object: nil)
        
        self.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "doNothing"), object: nil)
    }
    
    @objc func doNothing() {
        
        // Do nothing
        self.getPhotosFromDatabase()
        self.collectionView.reloadData()
    }

    func getPhotosFromDatabase() {
        
        // Fetch Photos
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Photo")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        for arraySection in 0..<photoAngle.count {
            
            let tempArray = NSMutableArray()
            
            if arraySection == 0 {
                
                arrayOfImages.removeAll()
            }
            
            for arrayRow in 0..<photoAngle[arraySection].count {
                
                if debug == 1 {
                    
                    print("Section = \(arraySection) Row = \(arrayRow)")
                }
                
                let filter = NSPredicate(format: "session == %@ AND month == %@ AND angle == %@",
                                         self.session,
                                         self.photoMonth[arraySection][arrayRow] as! String,
                                         self.photoAngle[arraySection][arrayRow] as! String)
                
                request.predicate = filter
                
                do {
                    if let photoObjects = try CoreDataHelper.shared().context.fetch(request) as? [Photo] {
                        
                        if debug == 1 {
                            
                            print("photosObjects.count = \(photoObjects.count)")
                        }
                        
                        if photoObjects.count != 0 {
                            
                            // Get the image from the last object
                            let matches = photoObjects.last
                            let image = UIImage(data: (matches?.image)! as Data)
                            
                            // Add image to array.
                            tempArray.add(image!)
                        }
                        else {
                            
                            // Load a placeholder image.
                            tempArray.add(UIImage(named: "PhotoPlaceHolder")!)
                        }
                    }
                } catch { print(" ERROR executing a fetch request: \( error)") }
            }
            
            self.arrayOfImages.insert((tempArray as AnyObject) as! Array<Any>, at: arraySection)
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Share", message: "", preferredStyle: .actionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: {
            action in
            
            self.emailPhotos()
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
    
    func emailPhotos() {
        
        // Create MailComposerViewController object.
        let mailcomposer = MFMailComposeViewController()
        mailcomposer.mailComposeDelegate = self
        mailcomposer.navigationBar.tintColor = UIColor.white
        
        // Check to see if the device has at least 1 email account configured
        if MFMailComposeViewController.canSendMail() {
            
            // Array to store the default email address.
            let emailAddress = self.getEmailAddresses()
            
            mailcomposer.setToRecipients(emailAddress)
            
            switch self.navigationItem.title! as String {
            case "All":
                
                // ALL PHOTOS
                let emailTitle = String.localizedStringWithFormat("90 DWT 2 All Photos - Session %@", self.session)
                mailcomposer.setSubject(emailTitle)
                
                for arraySection in 0..<self.arrayOfImages.count {
                    
                    for arrayRow in 0..<self.arrayOfImages[arraySection].count {
                        
                        // Don't attach photos that just use the placeholder image.
                        if self.arrayOfImages[arraySection][arrayRow] as? UIImage != UIImage(named: "PhotoPlaceHolder") {
                            
                            let photoAttachmentFileName = String.localizedStringWithFormat("%@ - Session %@.jpg", self.photoTitles[arraySection][arrayRow] as! String, self.session)
                            
                            let imageData = UIImageJPEGRepresentation(self.arrayOfImages[arraySection][arrayRow] as! UIImage, 1.0)
                            
                            mailcomposer.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: photoAttachmentFileName)
                        }
                    }
                }
                
            case "Front":
                
                // FRONT PHOTOS
                let emailTitle = String.localizedStringWithFormat("90 DWT 2 Front Photos - Session %@", self.session)
                mailcomposer.setSubject(emailTitle)
                
                for arraySection in 0..<self.arrayOfImages.count {
                    
                    for arrayRow in 0..<self.arrayOfImages[arraySection].count {
                        
                        // Don't attach photos that just use the placeholder image.
                        if self.arrayOfImages[arraySection][arrayRow] as? UIImage != UIImage(named: "PhotoPlaceHolder") {
                            
                            let photoAttachmentFileName = String.localizedStringWithFormat("%@ - Session %@.jpg", self.photoTitles[arraySection][arrayRow] as! String, self.session)
                            
                            let imageData = UIImageJPEGRepresentation(self.arrayOfImages[arraySection][arrayRow] as! UIImage, 1.0)
                            
                            mailcomposer.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: photoAttachmentFileName)

                        }
                    }
                }

            case "Side":
                
                // SIDE PHOTOS
                let emailTitle = String.localizedStringWithFormat("90 DWT 2 Side Photos - Session %@", self.session)
                mailcomposer.setSubject(emailTitle)
                
                for arraySection in 0..<self.arrayOfImages.count {
                    
                    for arrayRow in 0..<self.arrayOfImages[arraySection].count {
                        
                        // Don't attach photos that just use the placeholder image.
                        if self.arrayOfImages[arraySection][arrayRow] as? UIImage != UIImage(named: "PhotoPlaceHolder") {
                            
                            let photoAttachmentFileName = String.localizedStringWithFormat("%@ - Session %@.jpg", self.photoTitles[arraySection][arrayRow] as! String, self.session)
                            
                            let imageData = UIImageJPEGRepresentation(self.arrayOfImages[arraySection][arrayRow] as! UIImage, 1.0)
                            
                            mailcomposer.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: photoAttachmentFileName)
                        }
                    }
                }
                
            default:
                
                // BACK PHOTOS
                let emailTitle = String.localizedStringWithFormat("90 DWT 2 Back Photos - Session %@", self.session)
                mailcomposer.setSubject(emailTitle)
                
                for arraySection in 0..<self.arrayOfImages.count {
                    
                    for arrayRow in 0..<self.arrayOfImages[arraySection].count {
                        
                        // Don't attach photos that just use the placeholder image.
                        if self.arrayOfImages[arraySection][arrayRow] as? UIImage != UIImage(named: "PhotoPlaceHolder") {
                            
                            let photoAttachmentFileName = String.localizedStringWithFormat("%@ - Session %@.jpg", self.photoTitles[arraySection][arrayRow] as! String, self.session)
                            
                            let imageData = UIImageJPEGRepresentation(self.arrayOfImages[arraySection][arrayRow] as! UIImage, 1.0)
                            
                            mailcomposer.addAttachmentData(imageData!, mimeType: "image/jpg", fileName: photoAttachmentFileName)
                        }
                    }
                }
            }
            
            present(mailcomposer, animated: true, completion: {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func getEmailAddresses() -> [String] {
        
        // Fetch defaultEmail data.
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Email")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        var emailAddressArray = [String]()
        
        do {
            if let emailObjects = try CoreDataHelper.shared().context.fetch(request) as? [Email] {
                
                if debug == 1 {
                    
                    print("emailObjects.count = \(emailObjects.count)")
                }
                
                if emailObjects.count != 0 {
                    
                    // There is a default email address.
                    emailAddressArray = [(emailObjects.last?.defaultEmail)!]
                }
                else {
                    
                    // There is NOT a default email address.  Put an empty email address in the arrary.
                    emailAddressArray = [""]
                }
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return emailAddressArray
    }
    
    // MARK: UICollectionView Datasource
    
    // 1
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrayOfImages[0].count
    }
    
    // 2
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if self.photoTitles.count == 4 {
            
            return 4
        }
        else {
            
            return 1
        }
    }
    
    // 3
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let blueColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        let cell = cv .dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.backgroundColor = UIColor.black
        
        let section = indexPath.section
        let row = indexPath.row
        
        if debug == 1 {
            
            print("Section = \(section) Row = \(row)")
        }
        
        cell.myImage.image = self.arrayOfImages[indexPath.section][indexPath.row] as? UIImage
        
        cell.myLabel.text = self.photoTitles[indexPath.section][indexPath.row] as? String
        cell.myLabel.backgroundColor = UIColor.black
        cell.myLabel.textColor = blueColor
        cell.myLabel.textAlignment = NSTextAlignment.center
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Size cell for iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            
            return CGSize(width: 152, height: 204);
        }
            
            // Size cell for iPad
        else {
            
            return CGSize(width: 304, height: 408);
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as! PhotoCollectionHeaderView
        
        if photoAngle.count == 4 {
            
            switch indexPath.section {
            case 0:
                
                header.headerLabel.text = "Start Month 1"
                
            case 1:
                
                header.headerLabel.text = "Start Month 2"
                
            case 2:
                
                header.headerLabel.text = "Start Month 3"
                
            default:
                
                header.headerLabel.text = "Final"
            }
        }
        else {
            
            header.headerLabel.text = ""
        }
        
        return header
    }
}
