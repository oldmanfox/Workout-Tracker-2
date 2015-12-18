//
//  ProgressTVC.h
//  90 DWT 2
//
//  Created by Grant, Jared on 12/1/12.
//  Copyright (c) 2012 Grant, Jared. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataNavController.h"
#import "WorkoutTVC.h"
#import "UITableViewController+Design.h"
//#import <iAd/iAd.h>
#import "MPAdView.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "UITableViewController+ConvertAllToCoreData.h"

@interface ProgressTVC : UITableViewController <MPAdViewDelegate>

@property (nonatomic) MPAdView *adView;

@property (nonatomic, strong) UIView *headerView;

@property CGSize bannerSize;

@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell4;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell5;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell6;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell7;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell8;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell9;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell10;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell11;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell12;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell13;

@end
