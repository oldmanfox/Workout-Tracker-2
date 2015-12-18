//
//  PresentPhotosViewController.h
//  i90X 2
//
//  Created by Jared Grant on 6/19/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoNavController.h"
#import <CoreImage/CoreImage.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import "UIViewController+Social.h"
#import "photoCollectionViewCell.h"
#import "CoreDataHelper.h"

@interface PresentPhotosViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareActionButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *arrayOfImages;
@property (strong, nonatomic) NSArray *arrayOfImageTitles;

- (IBAction)shareActionSheet:(id)sender;
@end
