//
//  DataNavController.m
//  i90X 2
//
//  Created by Jared Grant on 4/11/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//

#import "DataNavController.h"
#import "DWT2IAPHelper.h"
#import "AppDelegate.h"

@interface DataNavController ()

@end

@implementation DataNavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (appDelegate.purchasedAdRemoveBeforeAppLaunch) {
            
            // Do nothing.  No need to pop to root view controller.
            
        } else {
            
            [self popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Populate the Arrays with their workouts.  Some workouts have more than one round (like x2TotalBody).
    // I added the round at the end of each exercise to distinguish it from the previous round when storing.
    
    self.coreFitness = @[@"Sphinx Plank Crunches Round 1",
                    @"Balance Crunches Round 1",
                    @"1 Leg Balance to Sphinx Round 1",
                    @"Side Leg Arm Raises Round 1",
                    @"V Holds Round 1",
                    @"Ball Push-Ups Round 1",
                    @"1 Leg Side to Side Squats Round 1",
                    @"Sphinx Med Ball Circles Round 1",
                    @"Jump Lunges Round 1",
                    @"Weighted Squat Jumps Round 1",
                    @"Plank Burpees Round 1",
                    @"Rotating Ball Crunches Round 1",
                    @"Squat Presses Round 1",
                    @"Sphinx Med Ball Crunches Round 1",
                    @"Push-Up to Standing Round 1",
                    @"Side Sphinx Crunch Round 1",
                    @"1 Leg Burpee Round 1"];
    
    self.completeFitness = @[@"Chest Presses Round 1",
                        @"4-Way Pull-Ups Round 1",
                        @"Push-Up to Arm Balance Round 1",
                        @"Lunge Presses Round 1",
                        @"Balance Tricep Extensions Round 1",
                        @"Balance Curls Round 1",
                        @"Stability Ball Push-Ups Round 1",
                        @"Pull-Up Crunches Round 1",
                        @"Burpee Crunches Round 1",
                        @"Balanced Bicep Curl to Shoulder Presses Round 1",
                        @"Stability Ball Tricep Extensions Round 1",
                        @"Preacher Curls Round 1",
                        // Round 2
                        @"Chest Presses Round 2",
                        @"4-Way Pull-Ups Round 2",
                        @"Push-Up to Arm Balance Round 2",
                        @"Lunge Presses Round 2",
                        @"Balance Tricep Extensions Round 2",
                        @"Balance Curls Round 2",
                        @"Stability Ball Push-Ups Round 2",
                        @"Pull-Up Crunches Round 2",
                        @"Burpee Crunches Round 2",
                        @"Balanced Bicep Curl to Shoulder Presses Round 2",
                        @"Stability Ball Tricep Extensions Round 2",
                        @"Preacher Curls Round 2",
                        // Ab Workout
                        @"Ab Workout Round 1"];
    
    self.strengthStability = @[@"Plyometric Sphinx Round 1",
                        @"Balanced Plyometric Squats Round 1",
                        @"Weighted Crunches Round 1",
                        @"Sphinx to Plank Round 1",
                        @"4 Square Round 1",
                        @"Side Sphinx Round 1",
                        @"Decline Sphinx Round 1",
                        @"Jump Lunges Round 1",
                        @"Plank Crunches Round 1",
                        @"Rowing Forearm Balance Round 1",
                        @"Hamstring Curls Round 1",
                        @"V Crunches Round 1",
                        @"Balanced Row to Press Round 1",
                        @"Lunges Round 1",
                        @"Stability Ball Elbow Presses Round 1",
                        @"Side to Side Plyometric Push-Ups Round 1",
                        @"Lunge Presses Round 1",
                        @"Side Plank Crunches Round 1",
                        @"Side Plank Rows Round 1",
                        @"Weighted Burpees Round 1",
                        @"Plank Crunches on Med Ball Round 1"];
    
    self.chestBackStability = @[@"Pull-Ups Round 1",
                        @"Plyometric Large Ball Push-Ups Round 1",
                        @"Underhand Pull-Up Crunches Round 1",
                        @"Push-Up to Side Plank Round 1",
                        @"Horizontal Pull-Ups Round 1",
                        @"4 Point Push-Ups Round 1",
                        @"Underhand Pull-Ups Round 1",
                        @"2 Point Push-Ups Round 1",
                        @"V Pull-Ups Round 1",
                        @"3 Point Plyometric Push-Ups Round 1",
                        @"Opposite Grip Pull-Ups Round 1",
                        @"Balance Push-Ups Round 1",
                        @"Wide to Narrow Pull-Ups Round 1",
                        @"2 Point Plank Push-Ups Round 1",
                        @"4-Way Pull-Ups Round 1",
                        @"Wide Push-Ups Round 1",
                        @"Wide Pull-Ups Round 1",
                        @"Sphinx Push-Ups Round 1",
                        @"Uneven Pull-Ups Round 1",
                        @"Plyometric Small Ball Push-Ups Round 1",
                        // Ab Workout
                        @"Ab Workout Round 1"];
    
    self.shoulderBiTri = @[@"1 Leg Bicep Curls Round 1",
                    @"Alternating Shoulder Presses Round 1",
                    @"Overhead Tricep Extensions Round 1",
                    @"Straight Arm Shoulder Flys Round 1",
                    @"1 Leg Static Bicep Curls Round 1",
                    @"Shoulder Flys Round 1",
                    @"Tricep Extensions Round 1",
                    // Round 2
                    @"1 Leg Bicep Curls Round 2",
                    @"Alternating Shoulder Presses Round 2",
                    @"Overhead Tricep Extensions Round 2",
                    @"Straight Arm Shoulder Flys Round 2",
                    @"1 Leg Static Bicep Curls Round 2",
                    @"Shoulder Flys Round 2",
                    @"Tricep Extensions Round 2",
                    // Round 3
                    @"1 Leg Bicep Curls Round 3",
                    @"Alternating Shoulder Presses Round 3",
                    @"Overhead Tricep Extensions Round 3",
                    @"Straight Arm Shoulder Flys Round 3",
                    @"1 Leg Static Bicep Curls Round 3",
                    @"Shoulder Flys Round 3",
                    @"Tricep Extensions Round 3",
                    // Ab Workout
                    @"Ab Workout Round 1"];
    
    self.legsBack = @[@"Board Pull-Ups Round 1",
                @"Deep Squat Jumps Round 1",
                @"Close Underhand Pull-Ups Round 1",
                @"Squat Jumps Round 1",
                @"Underhand Pull-Ups Round 1",
                @"Jump Presses Round 1",
                @"Pull-Ups Round 1",
                @"180's Round 1",
                @"Fast Pull-Ups Round 1",
                @"Elbow Touch Jump Squats Round 1",
                // Round 2
                @"Board Pull-Ups Round 2",
                @"Deep Squat Jumps Round 2",
                @"Close Underhand Pull-Ups Round 2",
                @"Squat Jumps Round 2",
                @"Underhand Pull-Ups Round 2",
                @"Jump Presses Round 2",
                @"Pull-Ups Round 2",
                @"180's Round 2",
                @"Fast Pull-Ups Round 2",
                @"Elbow Touch Jump Squats Round 2",
                // Ab Workout
                @"Ab Workout Round 1"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // This just says I only support the portriat mode orientation.  If I wanted to support landscape
    // I would put that here.
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
