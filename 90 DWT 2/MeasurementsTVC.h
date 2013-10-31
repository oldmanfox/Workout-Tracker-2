//
//  MeasurementsTVC.h
//  i90X 2
//
//  Created by Jared Grant on 6/29/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeasurementsViewController.h"
#import "MeasurementsReportViewController.h"
#import "MeasurementsNavController.h"
#import "UITableViewController+Design.h"

@interface MeasurementsTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellFinal;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAll;

@end
