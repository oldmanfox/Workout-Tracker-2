//
//  AppDelegate.h
//  90 DWT 2
//
//  Created by Grant, Jared on 8/2/12.
//  Copyright (c) 2012 Grant, Jared. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSString *month;          // Current month.
@property (strong, nonatomic) NSString *week;           // Current week of workout.
@property (strong, nonatomic) NSString *workout;        // Full name of an individual workout.
@property (strong, nonatomic) NSNumber *index;          // The number of times this workout has been done.
@property (strong, nonatomic) NSString *exerciseName;   // Full name of an individual exercise.
@property (strong, nonatomic) NSString *exerciseRound;  // Round of an individual exercise (1 or 2).

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
