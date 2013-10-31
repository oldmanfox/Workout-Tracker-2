//
//  ResultsViewController.h
//  i90X 2
//
//  Created by Jared Grant on 4/27/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "DataNavController.h"
#import "AppDelegate.h"
#import "UIViewController+Social.h"
#import "UIViewController+iAdBanner.h"

@interface ResultsViewController : UIViewController <ADBannerViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextView *workoutSummary;
@property (strong, nonatomic) NSArray *exerciseNames;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareActionButton;

- (IBAction)shareActionSheet:(id)sender;
@end
