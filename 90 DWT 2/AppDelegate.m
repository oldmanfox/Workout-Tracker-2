//
//  AppDelegate.m
//  90 DWT 2
//
//  Created by Grant, Jared on 8/2/12.
//  Copyright (c) 2012 Grant, Jared. All rights reserved.
//

#import "AppDelegate.h"
#import "DWT2IAPHelper.h"
#import "CoreDataHelper.h"

@implementation AppDelegate

#define debug 0

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Override point for customization after application launch.
    
    // For In App Purchases - check to see if any transactions were purchased but not completed due to network loss or somethign similar.
    [DWT2IAPHelper sharedInstance];

    //  Configure for iOS 7

    // style the navigation bar
    //UIColor* navColor = [UIColor colorWithRed:0.175f green:0.458f blue:0.831f alpha:1.0f];
    UIColor* navColor = [UIColor colorWithRed:0/255.0f green:167/255.0f blue:255/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // make the status bar white
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    //[[UITabBar appearance] setBarTintColor:navColor];
    [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UITabBar appearance] setBackgroundColor:[UIColor blackColor]];
   
    //[UIViewController prepareInterstitialAds];
    
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        self.purchasedAdRemoveBeforeAppLaunch = YES;
    }

    [[ CoreDataHelper sharedHelper] iCloudAccountIsSignedIn];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    [[ CoreDataHelper sharedHelper] backgroundSaveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    [[ CoreDataHelper sharedHelper] ensureAppropriateStoreIsLoaded];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    //[self saveContext];
    [[ CoreDataHelper sharedHelper] backgroundSaveContext];
}

- (NSString *)getCurrentSession {
    
    // Get the objects for the current session
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    
    // Fetch current session data.
    NSEntityDescription *entityDescSession = [NSEntityDescription entityForName:@"Session" inManagedObjectContext:context];
    NSFetchRequest *requestSession = [[NSFetchRequest alloc] init];
    [requestSession setEntity:entityDescSession];
    
    NSManagedObject *matches = nil;
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:requestSession error:&error];
    NSString *currentSessionString;
    
    if ([objects count] == 0) {
        
        // No matches.
        currentSessionString = @"1";
    }
    
    else {
        
        // Multiple session matches.
        matches = objects[[objects count] - 1];
        
        currentSessionString = [matches valueForKey:@"currentSession"];
    }
    
    return currentSessionString;
}
@end
