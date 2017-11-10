//
//  AppDelegate.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 6/22/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MPRewardedVideoDelegate {

    var window: UIWindow?
    
    var endDate = NSDate()
    var shouldShowRewardGraph = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //UIColor *green = [UIColor colorWithRed:133/255.0f green:187/255.0f blue:60/255.0f alpha:1.0f];
        
        // Change navigation bar tint color
        // White Color
        UINavigationBar.appearance().tintColor = UIColor.white
        
        // Change navigation bar bar button items and title text color
        // Blue Color
        // White Color
        UINavigationBar.appearance().barTintColor = UIColor (red: 0/255, green: 125/255, blue: 191/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        // Change tab bar tint color
        // Redish Color
        UITabBar.appearance().tintColor = UIColor (red: 204/255, green: 70/255, blue: 20/255, alpha: 1)
        
        // Initialize rewarded video before loading any ads.
        MoPub.sharedInstance().initializeRewardedVideo(withGlobalMediationSettings: nil, delegate: self)
        
        CoreDataHelper.shared().iCloudAccountIsSignedIn()
        
        return true
    }
    
    func rewardedVideoAdShouldReward(forAdUnitID adUnitID: String!, reward: MPRewardedVideoReward!) {
        
        if reward.currencyType == "Hour" {
            
            // Set the endDate for the Graph to 60 minutes from now
            endDate = NSDate.init(timeIntervalSinceNow: (60.0 * 60.0))
            
            // Allow the reward Graph to be shown
            shouldShowRewardGraph = true
        }
    }
    
    func rewardedVideoAdDidDisappear(forAdUnitID adUnitID: String!) {
        
        // Fetch the rewarded video ad.
        // Rewarded Ad Unit
        MPRewardedVideo.loadAd(withAdUnitID: "c9130834e2324aa281a4b59dbcc41301", withMediationSettings: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        CoreDataHelper.shared().backgroundSaveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        CoreDataHelper.shared().ensureAppropriateStoreIsLoaded()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Fetch the rewarded video ad.
        // Rewarded Ad Unit
        MPRewardedVideo.loadAd(withAdUnitID: "c9130834e2324aa281a4b59dbcc41301", withMediationSettings: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        CoreDataHelper.shared().backgroundSaveContext()
    }
}

