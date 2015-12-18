//
//  DataNavController.h
//  i90X 2
//
//  Created by Jared Grant on 4/11/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//
//  This class keeps track of my global variables and does the "Next" "Back" buttons on the navigation bar.

#import <UIKit/UIKit.h>

@interface DataNavController : UINavigationController
@property (strong, nonatomic) NSString *month;    // Current month.
@property (strong, nonatomic) NSString *week;     // Current week of workout.
@property (strong, nonatomic) NSString *workout;  // Full name of an individual workout.
@property (strong, nonatomic) NSNumber *index;    // The number of times this workout has been done.

@property (strong, nonatomic) NSArray *coreFitness;    // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *completeFitness;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *strengthStability;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *chestBackStability;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *shoulderBiTri;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *legsBack;  // List of exercises for this workout with round added to it.
@end
