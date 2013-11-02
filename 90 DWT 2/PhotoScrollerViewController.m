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
    
    [self.collectionView reloadData];
    
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
                NSLog(@"%@", subjectTitle);
                
                for (int b = 0; b < picAngle.count; b++) {
                    
                    if (self.arrayOfImages[b] != [UIImage imageNamed:@"icon-pics2.png"]) {
                        
                        // Don't attach photos that just use the placeholder image.
                        
                        NSData *imageData = UIImageJPEGRepresentation(self.arrayOfImages[b], 1.0); //convert image into .JPG format.
                        NSString *photoAttachmentFileName = @"";
                        
                        photoAttachmentFileName = [photoAttachmentFileName stringByAppendingFormat:@"%@ %@.jpg", monthArray[i], picAngle[b]];
                        
                        NSLog(@"File name = %@", photoAttachmentFileName);
                        
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
    [action showFromTabBar:self.tabBarController.tabBar];

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
            [self cameraOrPhotoLibrary];
        }
        
        if (buttonIndex == 1) {
            
            self.whereToGetPhoto = @"Photo Library";
            [self cameraOrPhotoLibrary];
        }
        
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
    
    cell.backgroundColor = [UIColor whiteColor];
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
            
            NSLog(@"Photo = %@", self.arrayOfImages[i]);
            
        }
        
        else
            // Load a placeholder image.
        {
            [self.arrayOfImages addObject:[UIImage imageNamed:@"icon-pics2.png"]];
            
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
    
    self.selectedPhotoTitle = [self.navigationItem.title stringByAppendingString:photoAngle[indexPath.item]];
    self.selectedPhotoIndex = indexPath.item;
    
    [photoAction showFromTabBar:self.tabBarController.tabBar];
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (void)cameraOrPhotoLibrary {
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if ([self.whereToGetPhoto isEqualToString:@"Camera"]) {
        
        // Use Camera
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        
        // Use Photo Library
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    // Check to see what device you are using iPad or iPhone.
    NSString *deviceModel = [UIDevice currentDevice].model;
    
    // If your device is iPad then show the imagePicker in a popover.
    // If not iPad then show the imagePicker modally.
    if (([deviceModel isEqualToString:@"iPad"] && imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
        || ([deviceModel isEqualToString:@"iPad Simulator"] && imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)) {
        
        //self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        //self.popoverController.delegate = self;
        //[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Start new thread
    dispatch_queue_t saveQueue = dispatch_queue_create("image saver", NULL);
    dispatch_async(saveQueue, ^{
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        [self.arrayOfImages replaceObjectAtIndex:self.selectedPhotoIndex withObject:image];
        UIImage *scaledImage = nil;
        
        if (image.size.height > image.size.width) {
            
            // Image was taken in Portriat mode.
            scaledImage = [image resizedImageWithSize:CGSizeMake(1536,2048)];
            
        } else {
            
            // Image was taken in Landscape mode.
            scaledImage = [image resizedImageWithSize:CGSizeMake(2048,1536)];
        }
        
        // Only save image to photo library if it is a new pic taken with the camera.
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        
        PhotoNavController *photoNC = [[PhotoNavController alloc] init];
        
        
        
        // Save image to application documents directory.
        [photoNC saveImage:scaledImage imageName:self.selectedPhotoTitle];
        
        // Go back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // Display newly scaled image.
            
        });
    });
    
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