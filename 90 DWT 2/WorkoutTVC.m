//
//  WorkoutTVC.m
//  i90X 2
//
//  Created by Jared Grant on 4/11/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//

#import "WorkoutTVC.h"
#import "DWT2IAPHelper.h"
#import <iAd/iAd.h>

@interface WorkoutTVC ()

@end

@implementation WorkoutTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        self.canDisplayBannerAds = YES;
    }

    // Configure tableview.
    NSArray *tableCell = @[self.cell1,
                            self.cell2,
                            self.cell3,
                            self.cell4,
                            self.cell5,
                            self.cell6,
                            self.cell7];
    NSArray *accessoryIcon = @[@NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO];
    
    [self configureTableView:tableCell :accessoryIcon];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Table view data source


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int tableViewWidth = tableView.bounds.size.width;
    NSArray *tableViewHeaderStrings = @[self.sectionHeader];
    
    double tempSection = section;
    return [self configureSectionHeader:tableViewHeaderStrings :tableViewWidth :tempSection];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 7;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *week = ((DataNavController *)self.parentViewController).week;
    
    // Core Fitness
    if ([segue.identifier isEqualToString:@"Core Fitness"]) {
        if ([week isEqualToString:@"Week 1"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 2"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 3"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 4"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        ((DataNavController *)self.parentViewController).workout = @"Core Fitness";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
 
// Plyometrics
    else if ([segue.identifier isEqualToString:@"Plyometrics"]) {
        if ([week isEqualToString:@"Week 1"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 2"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 3"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 4"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        else if ([week isEqualToString:@"Week 5"]) {
            ((DataNavController *)self.parentViewController).index = @5;
        }
        else if ([week isEqualToString:@"Week 6"]) {
            ((DataNavController *)self.parentViewController).index = @6;
        }
        else if ([week isEqualToString:@"Week 7"]) {
            ((DataNavController *)self.parentViewController).index = @7;
        }
        else if ([week isEqualToString:@"Week 8"]) {
            ((DataNavController *)self.parentViewController).index = @8;
        }
        ((DataNavController *)self.parentViewController).workout = @"Plyometrics";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
// Stretch    
    else if ([segue.identifier isEqualToString:@"Stretch 1"]) {
        if ([week isEqualToString:@"Week 1"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 2"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 3"]) {
            ((DataNavController *)self.parentViewController).index = @5;
        }
        else if ([week isEqualToString:@"Week 4"]) {
            ((DataNavController *)self.parentViewController).index = @7;
        }
        ((DataNavController *)self.parentViewController).workout = @"Stretch";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Stretch 2"]) {
        if ([week isEqualToString:@"Week 1"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 2"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        else if ([week isEqualToString:@"Week 3"]) {
            ((DataNavController *)self.parentViewController).index = @6;
        }
        else if ([week isEqualToString:@"Week 4"]) {
            ((DataNavController *)self.parentViewController).index = @8;
        }
        ((DataNavController *)self.parentViewController).workout = @"Stretch";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Stretch 3"]) {
        if ([week isEqualToString:@"Week 5"]) {
            ((DataNavController *)self.parentViewController).index = @9;
        }
        else if ([week isEqualToString:@"Week 6"]) {
            ((DataNavController *)self.parentViewController).index = @11;
        }
        else if ([week isEqualToString:@"Week 7"]) {
            ((DataNavController *)self.parentViewController).index = @13;
        }
        else if ([week isEqualToString:@"Week 8"]) {
            ((DataNavController *)self.parentViewController).index = @15;
        }
        ((DataNavController *)self.parentViewController).workout = @"Stretch";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Stretch 4"]) {
        if ([week isEqualToString:@"Week 5"]) {
            ((DataNavController *)self.parentViewController).index = @10;
        }
        else if ([week isEqualToString:@"Week 6"]) {
            ((DataNavController *)self.parentViewController).index = @12;
        }
        else if ([week isEqualToString:@"Week 7"]) {
            ((DataNavController *)self.parentViewController).index = @14;
        }
        else if ([week isEqualToString:@"Week 8"]) {
            ((DataNavController *)self.parentViewController).index = @16;
        }
        ((DataNavController *)self.parentViewController).workout = @"Stretch";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Stretch 5"]) {
        if ([week isEqualToString:@"Week 9"]) {
            ((DataNavController *)self.parentViewController).index = @17;
        }
        else if ([week isEqualToString:@"Week 10"]) {
            ((DataNavController *)self.parentViewController).index = @19;
        }
        else if ([week isEqualToString:@"Week 11"]) {
            ((DataNavController *)self.parentViewController).index = @21;
        }
        else if ([week isEqualToString:@"Week 12"]) {
            ((DataNavController *)self.parentViewController).index = @23;
        }
        else if ([week isEqualToString:@"Week 13"]) {
            ((DataNavController *)self.parentViewController).index = @25;
        }
        ((DataNavController *)self.parentViewController).workout = @"Stretch";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Stretch 6"]) {
        if ([week isEqualToString:@"Week 9"]) {
            ((DataNavController *)self.parentViewController).index = @18;
        }
        else if ([week isEqualToString:@"Week 10"]) {
            ((DataNavController *)self.parentViewController).index = @20;
        }
        else if ([week isEqualToString:@"Week 11"]) {
            ((DataNavController *)self.parentViewController).index = @22;
        }
        else if ([week isEqualToString:@"Week 12"]) {
            ((DataNavController *)self.parentViewController).index = @24;
        }
        else if ([week isEqualToString:@"Week 13"]) {
            ((DataNavController *)self.parentViewController).index = @26;
        }
        ((DataNavController *)self.parentViewController).workout = @"Stretch";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
// Complete Fitness
    else if ([segue.identifier isEqualToString:@"Complete Fitness & Ab Workout"]) {
        if ([week isEqualToString:@"Week 1"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 2"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 3"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 4"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        ((DataNavController *)self.parentViewController).workout = @"Complete Fitness & Ab Workout";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
// Yoga     
    else if ([segue.identifier isEqualToString:@"Yoga 1"]) {
        if ([week isEqualToString:@"Week 1"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 2"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 3"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 4"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        ((DataNavController *)self.parentViewController).workout = @"Yoga";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Yoga 2"]) {
        if ([week isEqualToString:@"Week 5"]) {
            ((DataNavController *)self.parentViewController).index = @5;
        }
        else if ([week isEqualToString:@"Week 6"]) {
            ((DataNavController *)self.parentViewController).index = @6;
        }
        else if ([week isEqualToString:@"Week 7"]) {
            ((DataNavController *)self.parentViewController).index = @7;
        }
        else if ([week isEqualToString:@"Week 8"]) {
            ((DataNavController *)self.parentViewController).index = @8;
        }
        ((DataNavController *)self.parentViewController).workout = @"Yoga";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Yoga 3"]) {
        if ([week isEqualToString:@"Week 9"]) {
            ((DataNavController *)self.parentViewController).index = @9;
        }
        else if ([week isEqualToString:@"Week 10"]) {
            ((DataNavController *)self.parentViewController).index = @10;
        }
        else if ([week isEqualToString:@"Week 11"]) {
            ((DataNavController *)self.parentViewController).index = @11;
        }
        else if ([week isEqualToString:@"Week 12"]) {
            ((DataNavController *)self.parentViewController).index = @12;
        }
        else if ([week isEqualToString:@"Week 13"]) {
            ((DataNavController *)self.parentViewController).index = @13;
        }
        ((DataNavController *)self.parentViewController).workout = @"Yoga";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }

// Strength + Stability
    else if ([segue.identifier isEqualToString:@"Strength + Stability"]) {
        if ([week isEqualToString:@"Week 1"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 2"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 3"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 4"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        ((DataNavController *)self.parentViewController).workout = @"Strength + Stability";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    // Chest + Back + Stability
    else if ([segue.identifier isEqualToString:@"Chest + Back + Stability & Ab Workout"]) {
        if ([week isEqualToString:@"Week 5"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 6"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 7"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 8"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        ((DataNavController *)self.parentViewController).workout = @"Chest + Back + Stability & Ab Workout";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    // Shoulder + Bi + Tri
    else if ([segue.identifier isEqualToString:@"Shoulder + Bi + Tri & Ab Workout"]) {
        if ([week isEqualToString:@"Week 5"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 6"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 7"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 8"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        ((DataNavController *)self.parentViewController).workout = @"Shoulder + Bi + Tri & Ab Workout";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    // Legs + Back
    else if ([segue.identifier isEqualToString:@"Legs + Back & Ab Workout"]) {
        if ([week isEqualToString:@"Week 5"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 6"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 7"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 8"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        ((DataNavController *)self.parentViewController).workout = @"Legs + Back & Ab Workout";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }

// Lower Agility    
    else if ([segue.identifier isEqualToString:@"Lower Agility 1"]) {
        if ([week isEqualToString:@"Week 9"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 10"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 11"]) {
            ((DataNavController *)self.parentViewController).index = @5;
        }
        else if ([week isEqualToString:@"Week 12"]) {
            ((DataNavController *)self.parentViewController).index = @7;
        }
        else if ([week isEqualToString:@"Week 13"]) {
            ((DataNavController *)self.parentViewController).index = @9;
        }
        ((DataNavController *)self.parentViewController).workout = @"Lower Agility";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }
    
    else if ([segue.identifier isEqualToString:@"Lower Agility 2"]) {
        if ([week isEqualToString:@"Week 9"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 10"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        else if ([week isEqualToString:@"Week 11"]) {
            ((DataNavController *)self.parentViewController).index = @6;
        }
        else if ([week isEqualToString:@"Week 12"]) {
            ((DataNavController *)self.parentViewController).index = @8;
        }
        else if ([week isEqualToString:@"Week 13"]) {
            ((DataNavController *)self.parentViewController).index = @10;
        }
        ((DataNavController *)self.parentViewController).workout = @"Lower Agility";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }

// Upper Agility
    else if ([segue.identifier isEqualToString:@"Upper Agility 1"]) {
        if ([week isEqualToString:@"Week 9"]) {
            ((DataNavController *)self.parentViewController).index = @1;
        }
        else if ([week isEqualToString:@"Week 10"]) {
            ((DataNavController *)self.parentViewController).index = @3;
        }
        else if ([week isEqualToString:@"Week 11"]) {
            ((DataNavController *)self.parentViewController).index = @5;
        }
        else if ([week isEqualToString:@"Week 12"]) {
            ((DataNavController *)self.parentViewController).index = @7;
        }
        else if ([week isEqualToString:@"Week 13"]) {
            ((DataNavController *)self.parentViewController).index = @9;
        }
        ((DataNavController *)self.parentViewController).workout = @"Upper Agility";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }

    else if ([segue.identifier isEqualToString:@"Upper Agility 2"]) {
        if ([week isEqualToString:@"Week 9"]) {
            ((DataNavController *)self.parentViewController).index = @2;
        }
        else if ([week isEqualToString:@"Week 10"]) {
            ((DataNavController *)self.parentViewController).index = @4;
        }
        else if ([week isEqualToString:@"Week 11"]) {
            ((DataNavController *)self.parentViewController).index = @6;
        }
        else if ([week isEqualToString:@"Week 12"]) {
            ((DataNavController *)self.parentViewController).index = @8;
        }
        else if ([week isEqualToString:@"Week 13"]) {
            ((DataNavController *)self.parentViewController).index = @10;
        }
        ((DataNavController *)self.parentViewController).workout = @"Upper Agility";
        //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    }

    //NSLog(@"Variable Index = %d", [((DataNavController *)self.parentViewController).index integerValue]);
    //NSLog(@"Variable Workout = %@", ((DataNavController *)self.parentViewController).workout);
}
@end
