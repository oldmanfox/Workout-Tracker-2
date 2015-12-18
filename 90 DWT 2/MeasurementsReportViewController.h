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
#import "CoreDataHelper.h"
#import "MeasurementsNavController.h"

@interface MeasurementsReportViewController : UIViewController<MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *htmlView;
@property (strong, nonatomic) NSDictionary *month1Dict;
@property (strong, nonatomic) NSDictionary *month2Dict;
@property (strong, nonatomic) NSDictionary *month3Dict;
@property (strong, nonatomic) NSDictionary *finalDict;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

@property (strong, nonatomic) NSMutableArray *month1Array;
@property (strong, nonatomic) NSMutableArray *month2Array;
@property (strong, nonatomic) NSMutableArray *month3Array;
@property (strong, nonatomic) NSMutableArray *finalArray;

- (void)emailSummary;
- (IBAction)actionSheet:(id)sender;
@end
