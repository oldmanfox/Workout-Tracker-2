//
//  ProgressTVC.m
//  90 DWT 2
//
//  Created by Grant, Jared on 12/1/12.
//  Copyright (c) 2012 Grant, Jared. All rights reserved.
//

#import "ProgressTVC.h"
#import "DWT2IAPHelper.h"

@interface ProgressTVC ()

@end

@implementation ProgressTVC

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
    
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"weight_lifting_selected"];
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        //self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        //self.canDisplayBannerAds = YES;
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            // iPhone
            self.adView = [[MPAdView alloc] initWithAdUnitId:@"6232cd4a1e374ecebed0f15440ba2a65"
                                                        size:MOPUB_BANNER_SIZE];
            self.bannerSize = MOPUB_BANNER_SIZE;
            
        } else {
            
            // iPad
            self.adView = [[MPAdView alloc] initWithAdUnitId:@"05f5a06e1c8e4560ba24068341868285"
                                                        size:MOPUB_LEADERBOARD_SIZE];
            self.bannerSize = MOPUB_LEADERBOARD_SIZE;
            
        }
        
        self.adView.delegate = self;
        self.adView.frame = CGRectMake((self.view.bounds.size.width - self.bannerSize.width) / 2,
                                       self.bannerSize.height - self.bannerSize.height,
                                       self.bannerSize.width, self.bannerSize.height);
        
        [self.headerView addSubview:self.adView];
        
        [self.adView loadAd];
    }

    // Configure tableview.
    NSArray *tableCell = @[self.cell1,
                            self.cell2,
                            self.cell3,
                            self.cell4,
                            self.cell5,
                            self.cell6,
                            self.cell7,
                            self.cell8,
                            self.cell9,
                            self.cell10,
                            self.cell11,
                            self.cell12,
                            self.cell13];
    NSArray *accessoryIcon = @[@NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO,
                                @NO];
    
    [self configureTableView:tableCell :accessoryIcon];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // Don't show ads.
        self.tableView.tableHeaderView = nil;
        self.adView.delegate = nil;
        self.adView = nil;
        
    } else {
        
        // Show ads
        self.adView.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {

    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // Don't show ads.
        self.tableView.tableHeaderView = nil;
        self.adView.delegate = nil;
        self.adView = nil;
        
    } else {
        
        // Show ads
        self.adView.frame = CGRectMake((self.view.bounds.size.width - self.bannerSize.width) / 2,
                                       self.bannerSize.height - self.bannerSize.height,
                                       self.bannerSize.width, self.bannerSize.height);
        self.adView.hidden = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int tableViewWidth = tableView.bounds.size.width;
    NSArray *tableViewHeaderStrings = @[@"MONTH 1",
                                        @"MONTH 2",
                                        @"MONTH 3"];
    
    double tempSection = section;
    return [self configureSectionHeader:tableViewHeaderStrings :tableViewWidth :tempSection];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0 || section == 1) {
        return 4;
    }
    
    else {
        return 5;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WorkoutTVC *workoutTVC = (WorkoutTVC *)segue.destinationViewController;
    
    NSArray *weekNumber = @[@"Week 1",
                            @"Week 2",
                            @"Week 3",
                            @"Week 4",
                            @"Week 5",
                            @"Week 6",
                            @"Week 7",
                            @"Week 8",
                            @"Week 9",
                            @"Week 10",
                            @"Week 11",
                            @"Week 12",
                            @"Week 13"];
    
    NSArray *monthList = @[@"Month 1", @"Month 2", @"Month 3"];
    NSArray *month1 = @[@"Week 1", @"Week 2", @"Week 3", @"Week 4"];
    NSArray *month2 = @[@"Week 5", @"Week 6", @"Week 7", @"Week 8"];
    NSArray *month3 = @[@"Week 9", @"Week 10", @"Week 11", @"Week 12", @"Week 13"];
    
    NSArray *monthWeeks = @[monthList, month1, month2, month3];
    
    // Get the week name
    for (int i = 0; i < weekNumber.count; i++) {
        
        if ([segue.identifier isEqualToString:weekNumber[i] ]) {
            
            ((DataNavController *)self.parentViewController).week = weekNumber[i];
            
        }
    }
    
    // Get the month name (aka "phase" from i90X code)
    for (int m = 0; m < [monthWeeks[0] count]; m++) {
        
        for (int w = 0; w < [monthWeeks[m +1] count]; w++) {
            
            if ([monthWeeks[m + 1][w] isEqualToString:((DataNavController *)self.parentViewController).week]) {
                
                ((DataNavController *)self.parentViewController).phase = monthWeeks[0][m];
                //NSLog(@"Month = %@", monthWeeks[0][m]);
            }
        }
    }

    // Set the WorkoutTVC section header
    NSMutableString *tempSecionHeader = [NSMutableString stringWithCapacity:0];
    [tempSecionHeader appendString:[NSString stringWithFormat:@"%@ - %@", [((DataNavController *)self.parentViewController).phase uppercaseString], [((DataNavController *)self.parentViewController).week uppercaseString]]];
    
    workoutTVC.sectionHeader = tempSecionHeader;
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        
    } else {
        
        // Show the Interstitial Ad
        //UIViewController *c = segue.destinationViewController;
        
        //c.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.bannerSize.height - size.height;
    view.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
    
    if (self.headerView.frame.size.height == 0) {
        
        // No ads shown yet.  Animate showing the ad.
        CGRect headerViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.bannerSize.height);
        
        [UIView animateWithDuration:0.25 animations:^{ self.headerView.frame = headerViewFrame;
            self.tableView.tableHeaderView = self.headerView;
            self.adView.hidden = YES;}
         
                         completion:^(BOOL finished) {self.adView.hidden = NO;
                         }];
        
    } else {
        
        // Ad is already showing.
        self.tableView.tableHeaderView = self.headerView;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    
    self.adView.hidden = YES;
    [self.adView rotateToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGSize size = [self.adView adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.headerView.bounds.size.height - size.height;
    self.adView.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
    
    self.adView.hidden = NO;
}
@end
