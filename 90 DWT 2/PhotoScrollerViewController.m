//
//  PhotoScrollerViewController.m
//  i90X 2
//
//  Created by Jared Grant on 6/15/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "PhotoScrollerViewController.h"

@interface PhotoScrollerViewController ()

@property (strong, nonatomic) NSString *actionButtonType;
@property (strong, nonatomic) NSString *whereToGetPhoto;
@property (strong, nonatomic) NSString *selectedPhotoTitle;

@property CGRect selectedImageRect;
@property int selectedPhotoIndex;

@end

@implementation PhotoScrollerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureViewForIOSVersion];
    
    self.arrayOfImages = [[NSMutableArray alloc] init];
    
    [self getPhotos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self.collectionView reloadData];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)emailPhotos
{
    // Create MailComposerViewController object.
    MFMailComposeViewController *mailComposer;
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        // Send email
        //PhotoNavController *photoNC = [[PhotoNavController alloc] init];
        
        // Get path to documents directory to get default email address and images.
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        //NSString *imageFile = nil;
        
        // Create MailComposerViewController object.
        MFMailComposeViewController *mailComposer;
        mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        // Array to store the default email address.
        NSArray *emailAddresses; 
        
        NSString *defaultEmailFile = nil;
        defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:defaultEmailFile]) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultEmailFile];
            
            NSString *defaultEmail = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
            [fileHandle closeFile];
            
            // There is a default email address.
            emailAddresses = @[defaultEmail];
        }
        else {
            // There is NOT a default email address.  Put an empty email address in the arrary.
            emailAddresses = @[@""];
        }
        
        [mailComposer setToRecipients:emailAddresses];
        
        NSArray *monthArray = @[@"Start Month 1", @"Start Month 2", @"Start Month 3", @"Final"];
        NSArray *picAngle = @[@"Front", @"Side", @"Back"];
        
        for (int i = 0; i < monthArray.count; i++) {
            
            if ([self.navigationItem.title isEqualToString:monthArray[i]]) {
                
                // Prepare string for the Subject of the email
                NSString *subjectTitle = @"";
                subjectTitle = [subjectTitle stringByAppendingFormat:@"90 DWT 2 %@ Photos", monthArray[i]];
                
                [mailComposer setSubject:subjectTitle];
                //NSLog(@"%@", subjectTitle);
                
                for (int b = 0; b < picAngle.count; b++) {
                    
                    if (self.arrayOfImages[b] != [UIImage imageNamed:@"icon-pics2.png"]) {
                        
                        // Don't attach photos that just use the placeholder image.
                        
                        NSData *imageData = UIImageJPEGRepresentation(self.arrayOfImages[b], 1.0); //convert image into .JPG format.
                        NSString *photoAttachmentFileName = @"";
                        
                        photoAttachmentFileName = [photoAttachmentFileName stringByAppendingFormat:@"%@ %@.jpg", monthArray[i], picAngle[b]];
                        
                        //NSLog(@"File name = %@", photoAttachmentFileName);
                        
                        [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:photoAttachmentFileName];
                    }
                }
            }
        }
        
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureViewForIOSVersion {
    
    // Colors
    //UIColor *blueColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
    //UIColor *lightGreyColor = [UIColor colorWithRed:219/255.0f green:224/255.0f blue:234/255.0f alpha:1.0f];
    
    // Apply Text Colors
    
    // Apply Background Colors
    
    self.view.backgroundColor = [UIColor blackColor];
    self.collectionView.backgroundColor = [UIColor blackColor];
    
    // Apply Keyboard Color
}
- (IBAction)shareActionSheet:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook", @"Twitter", nil];
    
    self.actionButtonType = @"Share";
    [action showFromBarButtonItem:sender animated:YES];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([self.actionButtonType isEqualToString:@"Share"]) {
        
        if (buttonIndex == 0) {
            [self emailPhotos];
        }
        
        if (buttonIndex == 1) {
            [self facebook];
        }
        
        if (buttonIndex == 2) {
            [self twitter];
        }
    }
    
    else
    {
        // Photo
        
        if (buttonIndex == 0) {
            
            self.whereToGetPhoto = @"Camera";
        }
        
        if (buttonIndex == 1) {
            
            self.whereToGetPhoto = @"Photo Library";
        }
        
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (![self.actionButtonType isEqualToString:@"Share"]) {
        [self cameraOrPhotoLibrary];
    }
}

#pragma mark - UICollectionView Datasource

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //NSString *searchTerm = self.searches[section];
    
    return [self.arrayOfImages count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UIColor *blueColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
    
    photoCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor blackColor];
    cell.myImage.image = [self.arrayOfImages objectAtIndex:indexPath.item];
    
    NSArray *photoAngle = @[@"Front",
                            @"Side",
                            @"Back"];

    cell.myLabel.text = photoAngle[indexPath.item];
    cell.myLabel.backgroundColor = [UIColor blackColor];
    cell.myLabel.textColor = blueColor;
    cell.myLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)getPhotos {
    
    PhotoNavController *photoNC = [[PhotoNavController alloc] init];
    NSString *currentPhase = ((PhotoNavController *)self.parentViewController).phase;
    
    NSArray *photoAngle = @[@" Front",
                            @" Side",
                            @" Back"];
    
    for (int i = 0; i < photoAngle.count; i++) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: [photoNC fileLocation:[currentPhase stringByAppendingString:photoAngle[i] ]]]) {
            
            [self.arrayOfImages addObject:[photoNC loadImage:[currentPhase stringByAppendingString:photoAngle[i] ]]];
            
            //NSLog(@"Photo = %@", self.arrayOfImages[i]);
            
        }
        
        else
            // Load a placeholder image.
        {
            [self.arrayOfImages addObject:[UIImage imageNamed:@"PhotoPlaceHolder.png"]];
            
        }

    }
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Select Item
    
    UIActionSheet *photoAction = [[UIActionSheet alloc] initWithTitle:@"Set Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    
    self.actionButtonType = @"Photo";
    
    NSArray *photoAngle = @[@" Front",
                            @" Side",
                            @" Back"];
    
    // Check to see what device you are using iPad or iPhone.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Get the position of the image so the popover arrow can point to it.
        static NSString *CellIdentifier = @"Cell";
        photoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        self.selectedImageRect = [collectionView convertRect:cell.frame toView:self.view];
    }
    
    double tempItem = indexPath.item;
    self.selectedPhotoTitle = [self.navigationItem.title stringByAppendingString:photoAngle[indexPath.item]];
    self.selectedPhotoIndex = tempItem;
    
    self.whereToGetPhoto = @"";
    [photoAction showFromRect:self.selectedImageRect inView:self.view animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    // Size cell for iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        return CGSizeMake(152.f, 204.f);
    }
    
    // Size cell for iPad
    else {
        
        return CGSizeMake(304.f, 408.f);
    }
}

- (void)cameraOrPhotoLibrary {
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if ([self.whereToGetPhoto isEqualToString:@"Camera"]) {
        
        // Use Camera
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            // Camera is available.  Use Camera
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        
        else {
            
            // No camera detected.  Use Photo Library
            UIAlertView *alert;
            
            alert = [[UIAlertView alloc] initWithTitle:@"Camera Not Found"
                                               message:@"No camera was detected.  Using photo library instead."
                                              delegate:self
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil, nil];
            
            [alert show];
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
    }
    
    else if ([self.whereToGetPhoto isEqualToString:@"Photo Library"]) {
        
        // Use Photo Library
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    else {
        
        // User Canceled the action sheet.
        return;
    }

    // Check to see what device you are using iPad or iPhone.
    
    // If your device is iPad then show the imagePicker in a popover.
    // If not iPad then show the imagePicker modally.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![self.whereToGetPhoto isEqualToString:@""]) {
        
        self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.myPopoverController.delegate = self;
        [self.myPopoverController presentPopoverFromRect:self.selectedImageRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //[[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self.arrayOfImages replaceObjectAtIndex:self.selectedPhotoIndex withObject:image];
    
    /*
    UIImage *scaledImage = nil;
    
    if (image.size.height > image.size.width) {
        
        // Image was taken in Portriat mode.
        scaledImage = [image resizedImageWithSize:CGSizeMake(1536,2048)];
        
    } else {
        
        // Image was taken in Landscape mode.
        scaledImage = [image resizedImageWithSize:CGSizeMake(2048,1536)];
    }
    */
    
    // Only save image to photo library if it is a new pic taken with the camera.
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    PhotoNavController *photoNC = [[PhotoNavController alloc] init];
    
    // Save image to application documents directory.
    [photoNC saveImage:image imageName:self.selectedPhotoTitle];

    [self.collectionView reloadData];
    
    picker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    /*
    UIAlertView *alert;
    
    // Unable to save the image
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photo Library."
                                          delegate:self
                                 cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil, nil];
    } else { // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved to Photo Library."
                                          delegate:self
                                 cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil, nil];
    }
    
    [alert show];
     */
}
@end
