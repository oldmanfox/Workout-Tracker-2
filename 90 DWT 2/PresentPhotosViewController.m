//
//  PresentPhotosViewController.m
//  i90X 2
//
//  Created by Jared Grant on 6/19/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "PresentPhotosViewController.h"

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
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        // Send email
        PhotoNavController *photoNC = [[PhotoNavController alloc] init];
        
        // Get path to documents directory to get default email address and images./
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *imageFile = nil;
        
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
        
        // ALL PHOTOS
        if ([self.navigationItem.title isEqualToString:@"All"]) {
            [mailComposer setSubject:@"90 DWT 2 All Photos"];
            
            // PHASE 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                
                NSData *imageForEmail = [photoNC emailImage:@"Start Month 1 Front"];
                [mailComposer addAttachmentData:imageForEmail mimeType:@"image/jpg" fileName:@"Start Month 1 Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Side"] mimeType:@"image/jpg" fileName:@"Start Month 1 Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Back"] mimeType:@"image/jpg" fileName:@"Start Month 1 Back.jpg"];
            }

            // PHASE 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Front"] mimeType:@"image/jpg" fileName:@"Start Month 2 Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Side"] mimeType:@"image/jpg" fileName:@"Start Month 2 Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Back"] mimeType:@"image/jpg" fileName:@"Start Month 2 Back.jpg"];
            }

            // PHASE 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Front"] mimeType:@"image/jpg" fileName:@"Start Month 3 Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Side"] mimeType:@"image/jpg" fileName:@"Start Month 3 Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Back"] mimeType:@"image/jpg" fileName:@"Start Month 3 Back.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Front"] mimeType:@"image/jpg" fileName:@"Final Front.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Final Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Side"] mimeType:@"image/jpg" fileName:@"Final Side.jpg"];
            }
            
            imageFile = [docDir stringByAppendingPathComponent:@"Final Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Back"] mimeType:@"image/jpg" fileName:@"Final Back.jpg"];
            }
        }
        
        // FRONT PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Front"]) {
            [mailComposer setSubject:@"90 DWT 2 Front Photos"];
            
            // PHASE 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                
                NSData *imageForEmail = [photoNC emailImage:@"Start Month 1 Front"];
                [mailComposer addAttachmentData:imageForEmail mimeType:@"image/jpg" fileName:@"Start Month 1 Front.JPG"];
            }
            
            // PHASE 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Front"] mimeType:@"image/jpg" fileName:@"Start Month 2 Front.jpg"];
            }
            
            // PHASE 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Front"] mimeType:@"image/jpg" fileName:@"Start Month 3 Front.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Front.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Front"] mimeType:@"image/jpg" fileName:@"Final Front.jpg"];
            }
        }
        
        // SIDE PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Side"]) {
            [mailComposer setSubject:@"90 DWT 2 Side Photos"];
            
            // PHASE 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Side"] mimeType:@"image/jpg" fileName:@"Start Month 1 Side.jpg"];
            }
            
            // PHASE 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Side"] mimeType:@"image/jpg" fileName:@"Start Month 2 Side.jpg"];
            }
            
            // PHASE 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Side"] mimeType:@"image/jpg" fileName:@"Start Month 3 Side.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Side.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Side"] mimeType:@"image/jpg" fileName:@"Final Side.jpg"];
            }
        }
        
        // BACK PHOTOS
        else if ([self.navigationItem.title isEqualToString:@"Back"]) {
            [mailComposer setSubject:@"90 DWT 2 Back Photos"];
            
            // PHASE 1
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 1 Back"] mimeType:@"image/jpg" fileName:@"Start Month 1 Back.jpg"];
            }
            
            // PHASE 2
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 2 Back"] mimeType:@"image/jpg" fileName:@"Start Month 2 Back.jpg"];
            }
            
            // PHASE 3
            imageFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Start Month 3 Back"] mimeType:@"image/jpg" fileName:@"Start Month 3 Back.jpg"];
            }
            
            // FINAL
            imageFile = [docDir stringByAppendingPathComponent:@"Final Back.JPG"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
                [mailComposer addAttachmentData:[photoNC emailImage:@"Final Back"] mimeType:@"image/jpg" fileName:@"Final Back.jpg"];
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
    
    cell.backgroundColor = [UIColor whiteColor];
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

@end
