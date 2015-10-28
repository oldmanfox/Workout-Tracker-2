//
//  NotesViewController.h
//  i90X 2
//
//  Created by Jared Grant on 4/15/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>
#import "DataNavController.h"
#import "AppDelegate.h"
#import "Workout_AbRipper_ResultsViewController.h"
#import "AppDelegate.h"
#import "UIViewController+Social.h"
#import "UIViewController+iAdBanner.h"
#import "MPAdView.h"

@interface NotesViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, MPAdViewDelegate>

@property (nonatomic) MPAdView *adView;

@property CGSize bannerSize;

@property (weak, nonatomic) IBOutlet UITextView *currentNotes;
@property (weak, nonatomic) IBOutlet UILabel *round;
@property (weak, nonatomic) IBOutlet UITextView *previousNotes;
@property (weak, nonatomic) IBOutlet UILabel *currentNotesLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousNotesLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareActionButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)submitEntry:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)shareActionSheet:(id)sender;

@end
