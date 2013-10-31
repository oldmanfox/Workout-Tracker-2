//
//  PhotoTVC.m
//  i90X 2
//
//  Created by Jared Grant on 6/6/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "PhotoTVC.h"

@interface PhotoTVC ()

@end

@implementation PhotoTVC

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
    
    // Configure tableview.
    NSArray *tableCell = @[self.cell1,
                            self.cell2,
                            self.cell3,
                            self.cellFinal,
                            self.cellAll,
                            self.cellFront,
                            self.cellSide,
                            self.cellBack];
    NSArray *accessoryIcon = @[@NO,
                                @NO,
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

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int tableViewWidth = tableView.bounds.size.width;
    NSArray *tableViewHeaderStrings = @[@"Take Photos",
                                        @"View Photos"];
    
    return [self configureSectionHeader:tableViewHeaderStrings :tableViewWidth :section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}
 
#pragma mark - Table view delegate
/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set navigation bar title
    ((PhotoNavController *)self.parentViewController).phase = segue.identifier;
    PhotoScrollerViewController *psvc = (PhotoScrollerViewController *)segue.destinationViewController;
    PresentPhotosViewController *ppvc = (PresentPhotosViewController *)segue.destinationViewController;
    psvc.navigationItem.title = segue.identifier;
    ppvc.navigationItem.title = segue.identifier;

    
    // View Photos
    PhotoNavController *photoNC = [[PhotoNavController alloc]  init];
    NSMutableArray *monthPhotoAngle = [[NSMutableArray alloc] init];
    NSArray *tempMonthPhotoAngle = [[NSArray alloc] init];
    
    // ALL
    if ([segue.identifier isEqualToString:@"All"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Front",
                                @"Start Month 1 Side",
                                @"Start Month 1 Back",
                                @"Start Month 2 Front",
                                @"Start Month 2 Side",
                                @"Start Month 2 Back",
                                @"Start Month 3 Front",
                                @"Start Month 3 Side",
                                @"Start Month 3 Back",
                                @"Final Front",
                                @"Final Side",
                                @"Final Back"];
    }
    
    // FRONT
    else if ([segue.identifier isEqualToString:@"Front"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Front",
                                @"Start Month 2 Front",
                                @"Start Month 3 Front",
                                @"Final Front"];
    }
    
    // SIDE
    else if ([segue.identifier isEqualToString:@"Side"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Side",
                                @"Start Month 2 Side",
                                @"Start Month 3 Side",
                                @"Final Side"];
    }
    
    // BACK
    else if ([segue.identifier isEqualToString:@"Back"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Back",
                                @"Start Month 2 Back",
                                @"Start Month 3 Back",
                                @"Final Back"];
    }
    
    if (tempMonthPhotoAngle.count != 0) {
        
        for (int i = 0; i < tempMonthPhotoAngle.count; i++) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[photoNC fileLocation:tempMonthPhotoAngle[i] ]]) {
                
                [monthPhotoAngle addObject:[photoNC loadImage:tempMonthPhotoAngle[i] ]];
            }
        }
        
        // Convert the mutable array to a normal unmutable array.
        ppvc.arrayOfImages = [monthPhotoAngle copy];
        ppvc.arrayOfImageTitles = tempMonthPhotoAngle;
    }
}
@end
