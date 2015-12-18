//
//  PhotoScrollerViewController.h
//  i90X 2
//
//  Created by Jared Grant on 6/15/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PhotoScrollerDetailViewController.h"
#import "PhotoNavController.h"
#import <CoreImage/CoreImage.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import "UIViewController+Social.h"
#import "UIImage+Resizing.h"
//#import "CoverFlowLayout.h"
#import "photoCollectionViewCell.h"
#import "CoreDataHelper.h"

@interface PhotoScrollerViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareActionButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *arrayOfImages;
@property (strong, nonatomic) UIPopoverController *myPopoverController;

- (IBAction)shareActionSheet:(id)sender;
@end
