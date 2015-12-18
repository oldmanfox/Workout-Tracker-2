//
//  PresentPhotosViewController.m
//  i90X 2
//
//  Created by Jared Grant on 6/19/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "PresentPhotosViewController.h"
#import "AppDelegate.h"

@interface PresentPhotosViewController ()

@end

@implementation PresentPhotosViewController

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

    // Respond to changes in underlying store
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:@"SomethingChanged"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    mailComposer.navigationBar.tintColor = [UIColor whiteColor];
    
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        // Send email
        // Get the current session string.
        NSString *currentSessionString = [mainAppDelegate getCurrentSession];
        
        // Array to store the default email address.
        NSArray *emailAddresses = [self getDefaultEmailAddress];
        
        [mailComposer setToRecipients:emailAddresses];
        
        // ALL PHOTOS
        if ([self.navigationItem.title isEqualToString:@"All"]) {
            NSString *emailTitle = [NSString stringWithFormat:@"90 DWT 2 All Photos - Session %@", currentSessionString];
            [mailComposer setSubject:emailTitle];
            
            for (int i = 0; i < self.arrayOfImages.count; i++) {
                
                NSString *photoAttachmentFileName = [NSString stringWithFormat:@"%@ - Session %@.jpg", self.arrayOfImageTitles[i], currentSessionString];
                
                NSData *imageData = UIImageJPEGRepresentation(self.arrayOfImages[i], 1.0); //convert image into .JPG format.
                
                [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:photoAttachmentFileName];
            }
        }
        
        // FRONT PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Front"]) {
            NSString *emailTitle = [NSString stringWithFormat:@"90 DWT 2 Front Photos - Session %@", currentSessionString];
            [mailComposer setSubject:emailTitle];
            
            for (int i = 0; i < self.arrayOfImages.count; i++) {
                
                NSString *photoAttachmentFileName = [NSString stringWithFormat:@"%@ - Session %@.jpg", self.arrayOfImageTitles[i], currentSessionString];
                
                NSData *imageData = UIImageJPEGRepresentation(self.arrayOfImages[i], 1.0); //convert image into .JPG format.
                
                [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:photoAttachmentFileName];
            }
        }
        
        // SIDE PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Side"]) {
            NSString *emailTitle = [NSString stringWithFormat:@"90 DWT 2 Side Photos - Session %@", currentSessionString];
            [mailComposer setSubject:emailTitle];
            
            for (int i = 0; i < self.arrayOfImages.count; i++) {
                
                NSString *photoAttachmentFileName = [NSString stringWithFormat:@"%@ - Session %@.jpg", self.arrayOfImageTitles[i], currentSessionString];
                
                NSData *imageData = UIImageJPEGRepresentation(self.arrayOfImages[i], 1.0); //convert image into .JPG format.
                
                [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:photoAttachmentFileName];
            }
        }
        
        // BACK PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Back"]) {
            NSString *emailTitle = [NSString stringWithFormat:@"90 DWT 2 Back Photos - Session %@", currentSessionString];
            [mailComposer setSubject:emailTitle];
            
            for (int i = 0; i < self.arrayOfImages.count; i++) {
                
                NSString *photoAttachmentFileName = [NSString stringWithFormat:@"%@ - Session %@.jpg", self.arrayOfImageTitles[i], currentSessionString];
                
                NSData *imageData = UIImageJPEGRepresentation(self.arrayOfImages[i], 1.0); //convert image into .JPG format.
                
                [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:photoAttachmentFileName];
            }
        }
        
        [self presentViewController:mailComposer animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
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
    
    [action showFromBarButtonItem:sender animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
        
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

#pragma mark - UICollectionView Datasource

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
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
    
    cell.myLabel.text = self.arrayOfImageTitles[indexPath.item];
    cell.myLabel.backgroundColor = [UIColor blackColor];
    cell.myLabel.textColor = blueColor;
    cell.myLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
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

- (NSArray *)getDefaultEmailAddress {
    
    // Fetch defaultEmail data.
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    
    // Fetch current session data.
    NSEntityDescription *entityDescEmail = [NSEntityDescription entityForName:@"Email" inManagedObjectContext:context];
    NSFetchRequest *requestEmail = [[NSFetchRequest alloc] init];
    [requestEmail setEntity:entityDescEmail];
    
    NSManagedObject *matches = nil;
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:requestEmail error:&error];
    
    // Array to store the default email address.
    NSArray *emailAddresses;
    
    if ([objects count] != 0) {
        
        matches = objects[[objects count] - 1];
        
        // There is a default email address.
        emailAddresses = @[[matches valueForKey:@"defaultEmail"]];
    }
    else {
        
        // There is NOT a default email address.  Put an empty email address in the arrary.
        emailAddresses = @[@""];
    }
    return emailAddresses;
}

- (void)updateUI {
    
    if ([CoreDataHelper sharedHelper].iCloudStore) {
        //[self.arrayOfImages removeAllObjects];
        //[self getPhotosFromDatabase];
        //[self.collectionView reloadData];
    }
}
@end
