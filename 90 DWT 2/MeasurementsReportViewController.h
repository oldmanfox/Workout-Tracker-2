//
//  MeasurementsReportViewController.h
//  i90X 2
//
//  Created by Jared Grant on 6/29/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UIViewController+Social.h"

@interface MeasurementsReportViewController : UIViewController<MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *htmlView;
@property (strong, nonatomic) NSDictionary *phase1Dict;
@property (strong, nonatomic) NSDictionary *phase2Dict;
@property (strong, nonatomic) NSDictionary *phase3Dict;
@property (strong, nonatomic) NSDictionary *finalDict;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

- (void)emailSummary;
- (IBAction)actionSheet:(id)sender;
@end
