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

@interface SettingsTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *emailDetail;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBands;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellVersion;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAuthor;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellWebsite;
@property (weak, nonatomic) IBOutlet UISwitch *bandsSettings;

- (IBAction)toggleBands:(id)sender;

@end
