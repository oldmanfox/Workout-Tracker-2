//
//  PhotoTVC.h
//  i90X 2
//
//  Created by Jared Grant on 6/6/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoScrollerViewController.h"
#import "PresentPhotosViewController.h"
#import "UITableViewController+Design.h"

@interface PhotoTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellFinal;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAll;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellFront;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSide;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBack;

@end
