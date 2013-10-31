//
//  UITableViewController+Design.h
//  90 DWT 2
//
//  Created by Grant, Jared on 11/17/12.
//  Copyright (c) 2012 Grant, Jared. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (Design)

- (void)configureTableView:(NSArray*)tableCell :(NSArray*)needAccessoryIcon;
- (UIView*)configureSectionHeader:(NSArray*)tvHeaderStrings :(int)tvWidth :(int)tvSection;

@end
