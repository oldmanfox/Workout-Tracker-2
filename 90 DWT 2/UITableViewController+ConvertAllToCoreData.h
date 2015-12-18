//
//  UITableViewController+ConvertAllToCoreData.h
//  90 DWT 1
//
//  Created by Grant, Jared on 12/1/15.
//  Copyright © 2015 Grant, Jared. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "Workout.h"
#import "SettingsNavController.h"
#import "MainTBC.h"

@interface UITableViewController (ConvertAllToCoreData)

- (void)convertPhotosToCoreData;
- (void)convertMeasurementsToCoreData;
- (void)convertSettingsToCoreData;
- (void)addSession1ToExistingCoreDataObjects;
@end
