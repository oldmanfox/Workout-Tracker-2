//
//  SettingsTVC.m
//  i90X 2
//
//  Created by Jared Grant on 7/8/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import "SettingsTVC.h"

@interface SettingsTVC ()

@end

@implementation SettingsTVC

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
    
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"cogs_selected"];
    
    // Configure tableview
    NSArray *tableCell = @[self.cellEmail,
                           self.cellBands,
                           self.cellVersion,
                           self.cellAuthor,
                           self.cellWebsite];
    NSArray *accessoryIcon = @[@NO,
                               @NO,
                               @NO,
                               @NO,
                               @NO];
    
    [self configureTableView:tableCell :accessoryIcon];
    
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    // Email File
    NSString *defaultEmailFile = nil;
    defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];
    
    if  ([[NSFileManager defaultManager] fileExistsAtPath:defaultEmailFile]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultEmailFile];
        ((SettingsNavController *)self.parentViewController).emailAddress = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
    }
    else {
        ((SettingsNavController *)self.parentViewController).emailAddress = @"";
    }
    
    // BandSetting
    if ([((MainTBC *)self.parentViewController.parentViewController).bandSetting isEqualToString:@"ON"]) {
        [self.bandsSettings setOn:YES animated:NO];
    }
    else {
        [self.bandsSettings setOn:NO animated:NO];
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([((SettingsNavController *)self.parentViewController).emailAddress isEqualToString:@""]) {
        self.emailDetail.text = @"youremail@abc.com";
    }
    else {
        self.emailDetail.text = ((SettingsNavController *)self.parentViewController).emailAddress;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int tableViewWidth = tableView.bounds.size.width;
    NSArray *tableViewHeaderStrings = @[@"DEFAULTS",
                                        @"ABOUT"];
    double tempSection = section;
    return [self configureSectionHeader:tableViewHeaderStrings :tableViewWidth :tempSection];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *fView = [[UIView alloc] initWithFrame:CGRectZero];
    fView.backgroundColor=[UIColor clearColor];
    
    UILabel *fLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, (tableView.bounds.size.width - 40), 22)];
    
    fLabel.backgroundColor = [UIColor clearColor];
    fLabel.shadowColor = [UIColor darkTextColor];
    fLabel.shadowOffset = CGSizeMake(0, -1);  // closest as far as I could tell
    fLabel.textColor = [UIColor whiteColor];  // or whatever you want
    fLabel.font = [UIFont systemFontOfSize:13];
    fLabel.textAlignment = NSTextAlignmentCenter;
    
    // Automatic word wrap
    fLabel.lineBreakMode = NSLineBreakByWordWrapping;
    fLabel.numberOfLines = 0;
    
    if (section == 0) {
        fLabel.text = @"Turning Bands ON enables the alphanumeric keyboard on the Weight field.";
    }
    else {
        fLabel.text = @"For feature requests or to report a bug please visit my website.";
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    // iPhone
    // Autosize
    [fLabel sizeToFit];
    }

    [fView addSubview:fLabel];
    
    return fView;
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
        return 2;
    }
    else {
        return 3;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.view.frame.size.width <= 640) {
        // iPhone
        return 70;
    }
    else {
        // iPad
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"email"]) {
        ((SettingsNavController *)self.parentViewController).emailAddress = self.emailDetail.text;
    }
}
- (IBAction)toggleBands:(id)sender {
    
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *defaultBandSetting = nil;
    defaultBandSetting = [docDir stringByAppendingPathComponent:@"Band Setting.out"];
    
    // Create the file
    [[NSFileManager defaultManager] createFileAtPath:defaultBandSetting contents:nil attributes:nil];
    
    NSString *localBandSetting;
    
    if ([sender isOn]) {
        // User wants to use bands so turn on alphanumeric keyboard for weight fields.
        localBandSetting = @"ON";
    }
    
    else {
        // User doesn't want to use bands so turn on numberpad keyboard for weight fields.
        localBandSetting = @"OFF";
    }
    
    // Write file to documents directory
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:defaultBandSetting];
    [fileHandle writeData:[localBandSetting dataUsingEncoding:NSUTF8StringEncoding]];
    ((MainTBC *)self.parentViewController.parentViewController).bandSetting = localBandSetting;
    
    //NSLog(@"BandSetting = %@", ((MainTBC *)self.parentViewController.parentViewController).bandSetting);
}
@end
