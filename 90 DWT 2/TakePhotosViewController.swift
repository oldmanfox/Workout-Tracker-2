//
//  TakePhotosViewController.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 9/16/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import CoreData
import Social

class TakePhotosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // **********
    let debug = 0
    // **********
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let arrayOfImages = NSMutableArray()
    
    var session = ""
    var monthString = ""
    
    let actionButtonType = ""
    var whereToGetPhoto = ""
    var selectedPhotoTitle = ""
    
    var selectedImageRect = CGRect()
    var selectedCell = UICollectionViewCell()
    var selectedPhotoIndex = NSInteger()
    
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
            
            let monthArray = ["Start Month 1", "Start Month 2", "Start Month 3", "Final"]
            let picAngle = ["Front", "Side", "Back"]
            
            for i in 0..<monthArray.count {
                
                if self.navigationItem.title == monthArray[i] {
                    
                    // Prepare string for the Subject of the email
                    var subjectTitle = ""
                    subjectTitle = subjectTitle.appendingFormat("90 DWT 2 %@ Photos - Session %@", monthArray[i], self.session)
                    
                    mailcomposer.setSubject(subjectTitle)
                    
                    for b in 0..<picAngle.count {
                        
                        // Don't attach photos that just use the placeholder image.
                        if self.arrayOfImages[b] as? UIImage != UIImage(named: "PhotoPlaceHolder") {
                            
                            let imageData = UIImageJPEGRepresentation(self.arrayOfImages[b] as! UIImage, 1.0)
                            
                            var photoAttachmentFileName = ""
                            photoAttachmentFileName = photoAttachmentFileName.appendingFormat("%@ %@ - Session %@.jpg", monthArray[i], picAngle[b], self.session)
                            
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
    
    func getPhotosFromDatabase() {
        
        // Get photo data with the current session
        let photoAngle = ["Front",
                          "Side",
                          "Back"]
        
        for i in 0..<photoAngle.count {
            
            // Fetch Photos
            let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Photo")
            let sortDate = NSSortDescriptor( key: "date", ascending: true)
            request.sortDescriptors = [sortDate]
            
            let filter = NSPredicate(format: "session == %@ AND month == %@ AND angle == %@",
                                     self.session,
                                     self.monthString,
                                     photoAngle[i])
            
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
                        self.arrayOfImages.add(image!)
                    }
                    else {
                        
                        // Load a placeholder image.
                        self.arrayOfImages.add(UIImage(named: "PhotoPlaceHolder")!)
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
        }
    }
    
    func cameraOrPhotoLibrary() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if self.whereToGetPhoto == "Camera" {
            
            // Use Camera
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            }
        }
        
        else if self.whereToGetPhoto == "Photo Library" {
            
            // Use Photo Library
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        else {
            
            // User Canceled the alert controller.
            return
        }
        
        // Check to see what device you are using iPad or iPhone.
        
        // If your device is iPad then show the imagePicker in a popover.
        // If not iPad then show the imagePicker modally.

        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
         
            imagePicker.modalPresentationStyle = .popover
        }
        
        if let popover = imagePicker.popoverPresentationController {
            
            popover.sourceView = self.selectedCell
            popover.delegate = self
            popover.sourceRect = (self.selectedCell.bounds)
            popover.permittedArrowDirections = .any
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage]
        
        self.arrayOfImages.replaceObject(at: self.selectedPhotoIndex, with: image!)
        
        var selectedAngle = ""
        
        switch selectedPhotoIndex {
        case 0:
            selectedAngle = "Front"
        case 1:
            selectedAngle = "Side"
        default:
            // selectedPhotoIndex = 2
            selectedAngle = "Back"
        }
        
        let imageData = UIImageJPEGRepresentation(image as! UIImage, 1.0)
        
        // Save the image data with the current session
        // Fetch Photos
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Photo")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Photo with session, month, and angle
        let filter = NSPredicate(format: "session == %@ AND month == %@ AND angle == %@",
                                 self.session,
                                 self.monthString,
                                 selectedAngle)
        
        request.predicate = filter
        
        do {
            if let photoObjects = try CoreDataHelper.shared().context.fetch(request) as? [Photo] {
                
                if debug == 1 {
                    
                    print("photosObjects.count = \(photoObjects.count)")
                }
                
                switch photoObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    if debug == 1 {
                        
                        print("No Matches")
                    }
                    
                    let insertPhotoInfo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: CoreDataHelper.shared().context) as! Photo
                    
                    insertPhotoInfo.session = session
                    insertPhotoInfo.month = monthString
                    insertPhotoInfo.angle = selectedAngle
                    insertPhotoInfo.date = Date() as NSDate?
                    insertPhotoInfo.image = imageData as NSData?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updatePhotoInfo = photoObjects[0]
                    
                    updatePhotoInfo.date = Date() as NSDate?
                    updatePhotoInfo.image = imageData as NSData?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    if debug == 1 {
                        
                        print("More than one match for object")
                    }
                    
                    for index in 0..<photoObjects.count {
                        
                        if (index == photoObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updatePhotoInfo = photoObjects[index]
                            
                            updatePhotoInfo.date = Date() as NSDate?
                            updatePhotoInfo.image = imageData as NSData?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(photoObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
            
            self.dismiss(animated: true, completion: nil)
            
            self.collectionView.reloadData()
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionView Datasource
    
    // 1
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrayOfImages.count
    }
    
    // 2
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    // 3
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let blueColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        let cell = cv .dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.backgroundColor = UIColor.black
        cell.myImage.image = self.arrayOfImages.object(at: indexPath.item) as? UIImage
        
        let photoAngle = ["Front",
                          "Side",
                          "Back"]
        
        cell.myLabel.text = photoAngle[indexPath.item]
        cell.myLabel.backgroundColor = UIColor.black
        cell.myLabel.textColor = blueColor
        cell.myLabel.textAlignment = NSTextAlignment.center
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var alertController = UIAlertController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            alertController = UIAlertController(title: "Set Photo", message: "Select Photo Source", preferredStyle: .actionSheet)
        }
        else {
            
            alertController = UIAlertController(title: "Set Photo", message: "No Camera Found.  Must Use Photo Library", preferredStyle: .actionSheet)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            
            self.whereToGetPhoto = "Camera"
            self.cameraOrPhotoLibrary()
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            
            self.whereToGetPhoto = "Photo Library"
            self.cameraOrPhotoLibrary()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
         
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        let photoAngle = [" Front",
                          " Side",
                          " Back"]
        
        self.selectedPhotoTitle = ((self.navigationItem.title)! + photoAngle[indexPath.item])
        self.selectedPhotoIndex = indexPath.item
        
        if let popover = alertController.popoverPresentationController {
            
            // Get the position of the image so the popover arrow can point to it.
            let cell = cv.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            self.selectedImageRect = cv .convert(cell.frame, to: self.view)
            self.selectedCell = cell
            
            popover.sourceView = cell
            popover.delegate = self
            popover.sourceRect = (cell.bounds)
            popover.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
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
}
