//
//  SettingsTVC.h
//  i90X 2
//
//  Created by Jared Grant on 7/8/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsNavController.h"
#import "WebsiteViewController.h"
#import "UITableViewController+Design.h"
#import "DataNavController.h"
#import "MainTBC.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"

@interface SettingsTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBands;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellVersion;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAuthor;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellWebsite;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellCurrentSession;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDisableAutoLock;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellReset;
@property (weak, nonatomic) IBOutlet UITableViewCell *celliCloudAccountStatus;
@property (weak, nonatomic) IBOutlet UITableViewCell *celliCloudAppStatus;

@property (weak, nonatomic) IBOutlet UILabel *emailDetail;
@property (weak, nonatomic) IBOutlet UISwitch *bandsSettings;
@property (weak, nonatomic) IBOutlet UISwitch *autoLockSwitch;  // Disable autolock while using the app.
@property (weak, nonatomic) IBOutlet UILabel *currentSessionLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetAllDataButton;
@property (weak, nonatomic) IBOutlet UIButton *resetCurrentSessionDataButton;
@property (weak, nonatomic) IBOutlet UIButton *decreaseSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *increaseSessionButton;
@property (weak, nonatomic) IBOutlet UILabel *iCloudAccountStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *iCloudAppStatusLabel;

- (IBAction)toggleBands:(id)sender;
- (IBAction)decreaseSession:(id)sender;
- (IBAction)increaseSession:(id)sender;
- (IBAction)resetAllData:(id)sender;
- (IBAction)resetCurrentSessionData:(id)sender;
- (IBAction)toggleAutoLock:(id)sender;
@end
