//
//  UITableViewController+Design.m
//  90 DWT 2
//
//  Created by Grant, Jared on 11/17/12.
//  Copyright (c) 2012 Grant, Jared. All rights reserved.
//

#import "UITableViewController+Design.h"

@implementation UITableViewController (Design)

- (void)configureTableView:(NSArray*)tableCell :(NSArray*)accessoryIcon {
    //UIImage *backgroundImage;
    UIColor *backgroundColor;
    //UIImage *cellbackgroundImage;
    UIColor *cellbackgroundColor;
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundView:[[UIView alloc] init]];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    UIColor* headerColor = [UIColor colorWithRed:33/255.0f green:37/255.0f blue:41/255.0f alpha:1.0f];
    backgroundColor = headerColor;
    
    cellbackgroundColor = [UIColor blackColor];
    
    // TableView background color
    self.tableView.backgroundColor = backgroundColor;
    
    // Accessory view icon
    UIImage* accessory = [UIImage imageNamed:@"cell_r_arrow"];
    
    for (int i = 0; i < tableCell.count; i++) {
        
        UITableViewCell *cell = tableCell[i];
        
        // Cell background color
        cell.backgroundColor = cellbackgroundColor;
        
        UIColor* detailTextColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = detailTextColor;
        
        // Accessory view icon
        if ([accessoryIcon[i] boolValue]) {
            UIImageView* accessoryView = [[UIImageView alloc] initWithImage:accessory];
            cell.accessoryView = accessoryView;
        }
    }
}

- (UIView*)configureSectionHeader:(NSArray*)tvHeaderStrings :(int)tvWidth :(int)tvSection {
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectZero];
    hView.backgroundColor=[UIColor clearColor];
    
    int x;
    int fontSize;
    int frameHeight;
    
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        // iPad
        x = 55;
        fontSize = 22;
        frameHeight = 76;
    }
    else {
        // iPhone
        x = 14;
        fontSize = 14;
        
        if (tvSection == 0) {
            frameHeight = 76;
        }
        
        else
        {
            frameHeight = 40;
        }
    }
     */
    
    // iPhone
    x = 14;
    fontSize = 15;
    
    if (tvSection == 0) {
        frameHeight = 76;
    }
    
    else
    {
        frameHeight = 40;
    }


    UILabel *hLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, tvWidth, frameHeight)];
    
    hLabel.shadowOffset = CGSizeMake(0, -1);  // closest as far as I could tell
    hLabel.textColor = [UIColor whiteColor];  // or whatever you want
    hLabel.font = [UIFont systemFontOfSize:fontSize];
    
    hLabel.text = tvHeaderStrings[tvSection];
    
    [hView addSubview:hLabel];
    
    return hView;
}
@end
