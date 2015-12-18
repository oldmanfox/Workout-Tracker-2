//
//  MeasurementsTVC.m
//  i90X 2
//
//  Created by Jared Grant on 6/29/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "MeasurementsTVC.h"

@interface MeasurementsTVC ()

@end

@implementation MeasurementsTVC

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
    
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"ruler_selected"];
    
    // Configure tableview.
    NSArray *tableCell = @[self.cell1,
                            self.cell2,
                            self.cell3,
                            self.cellFinal,
                            self.cellAll];
    NSArray *accessoryIcon = @[@NO,
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
    NSArray *tableViewHeaderStrings = @[@"RECORD YOUR MEASUREMENTS",
                                        @"VIEW YOUR MEASUREMENTS"];
    
    double tempSection = section;
    return [self configureSectionHeader:tableViewHeaderStrings :tableViewWidth :tempSection];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 4;
    }
    else {
        return 1;
    }
}

#pragma mark - Table view delegate
/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            ((MeasurementsNavController *)self.parentViewController).monthString = @"1";
        }
        
        if (indexPath.row == 1) {
            ((MeasurementsNavController *)self.parentViewController).monthString = @"2";
        }
        
        if (indexPath.row == 2) {
            ((MeasurementsNavController *)self.parentViewController).monthString = @"3";
        }
        
        if (indexPath.row == 3) {
            ((MeasurementsNavController *)self.parentViewController).monthString = @"4";
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set navigation bar title
    ((MeasurementsNavController *)self.parentViewController).month = segue.identifier;
    MeasurementsViewController *mvc = (MeasurementsViewController *)segue.destinationViewController;
    MeasurementsReportViewController *mrvc = (MeasurementsReportViewController *)segue.destinationViewController;
    mvc.navigationItem.title = segue.identifier;
    mrvc.navigationItem.title = segue.identifier;    
}
@end
