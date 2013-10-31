//
//  MeasurementsReportViewController.m
//  i90X 2
//
//  Created by Jared Grant on 6/29/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "MeasurementsReportViewController.h"

@interface MeasurementsReportViewController ()

@end

@implementation MeasurementsReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self configureViewForIOSVersion];
    [self loadDictionary];
    [self.htmlView loadHTMLString:[self createHTML] baseURL:nil];
    self.htmlView.backgroundColor = [UIColor clearColor];
    self.htmlView.opaque = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)emailSummary {
    
    // Create MailComposerViewController object.
    MFMailComposeViewController *mailComposer;
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        // Send email

        // Create an array of measurements to iterate thru when building the table rows.
        NSArray *measurementsArray = @[self.phase1Dict, self.phase2Dict, self.phase3Dict, self.finalDict];
        NSArray *measurementsPhase = @[@"Start Month 1", @"Start Month 2", @"Start Month 3", @"Final"];

        NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
        [writeString appendString:[NSString stringWithFormat:@"Phase,Weight,Chest,Left Arm,Right Arm,Waist,Hips,Left Thigh,Right Thigh\n"]];

        for (int i = 0; i < measurementsPhase.count; i++) {
            [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                       measurementsPhase[i],
                                       measurementsArray[i][@"Weight"],
                                       measurementsArray[i][@"Chest"],
                                       measurementsArray[i][@"Left Arm"],
                                       measurementsArray[i][@"Right Arm"],
                                       measurementsArray[i][@"Waist"],
                                       measurementsArray[i][@"Hips"],
                                       measurementsArray[i][@"Left Thigh"],
                                       measurementsArray[i][@"Right Thigh"]]];
        }

        NSData *csvData = [writeString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *fileName = [self.navigationItem.title stringByAppendingString:@" Measurements.csv"];

        // Array to store the default email address.
        NSArray *emailAddresses;

        // Get path to documents directory to get default email address.
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *defaultEmailFile = nil;
        defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];

        if ([[NSFileManager defaultManager] fileExistsAtPath:defaultEmailFile]) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultEmailFile];
            
            NSString *defaultEmail = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
            [fileHandle closeFile];
            
            // There is a default email address.
            emailAddresses = @[defaultEmail];
        }
        else {
            // There is NOT a default email address.  Put an empty email address in the arrary.
            emailAddresses = @[@""];
        }

        [mailComposer setToRecipients:emailAddresses];

        NSString *subject = @"90 DWT 2";
        subject = [subject stringByAppendingFormat:@" %@ Measurements", self.navigationItem.title];
        [mailComposer setSubject:subject];
        [mailComposer addAttachmentData:csvData mimeType:@"text/csv" fileName:fileName];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSheet:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook", @"Twitter", nil];
    [action showInView:self.view];
}

- (void)loadDictionary {
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dictionaryFile = nil;
    
    // Phase 1
    dictionaryFile = [docDir stringByAppendingPathComponent:@"Start Month 1 Measurements.out"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dictionaryFile]) {
        self.phase1Dict = [NSDictionary dictionaryWithContentsOfFile:dictionaryFile];
    }
    else {
        self.phase1Dict = @{@"Weight": @"0",
                      @"Chest": @"0",
                      @"Left Arm": @"0",
                      @"Right Arm": @"0",
                      @"Waist": @"0",
                      @"Hips": @"0",
                      @"Left Thigh": @"0",
                      @"Right Thigh": @"0"};
    }
    
    // Phase 2
    dictionaryFile = [docDir stringByAppendingPathComponent:@"Start Month 2 Measurements.out"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dictionaryFile]) {
        self.phase2Dict = [NSDictionary dictionaryWithContentsOfFile:dictionaryFile];
    }
    else {
        self.phase2Dict = @{@"Weight": @"0",
                      @"Chest": @"0",
                      @"Left Arm": @"0",
                      @"Right Arm": @"0",
                      @"Waist": @"0",
                      @"Hips": @"0",
                      @"Left Thigh": @"0",
                      @"Right Thigh": @"0"};
    }
    
    // Phase 3
    dictionaryFile = [docDir stringByAppendingPathComponent:@"Start Month 3 Measurements.out"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dictionaryFile]) {
        self.phase3Dict = [NSDictionary dictionaryWithContentsOfFile:dictionaryFile];
    }
    else {
        self.phase3Dict = @{@"Weight": @"0",
                      @"Chest": @"0",
                      @"Left Arm": @"0",
                      @"Right Arm": @"0",
                      @"Waist": @"0",
                      @"Hips": @"0",
                      @"Left Thigh": @"0",
                      @"Right Thigh": @"0"};
    }
    
    // Final
    dictionaryFile = [docDir stringByAppendingPathComponent:@"Final Measurements.out"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dictionaryFile]) {
        self.finalDict = [NSDictionary dictionaryWithContentsOfFile:dictionaryFile];
    }
    else {
        self.finalDict = @{@"Weight": @"0",
                     @"Chest": @"0",
                     @"Left Arm": @"0",
                     @"Right Arm": @"0",
                     @"Waist": @"0",
                     @"Hips": @"0",
                     @"Left Thigh": @"0",
                     @"Right Thigh": @"0"};    }
}

- (NSString*)createHTML {
    // Create an array of measurements to iterate thru when building the table rows.
    NSArray *measurementsArray = @[self.phase1Dict, self.phase2Dict, self.phase3Dict, self.finalDict];
    NSArray *measurementsNameArray = @[@"Weight", @"Chest", @"Left Arm", @"Right Arm", @"Waist", @"Hips", @"Left Thigh", @"Right Thigh"];
    
    NSString *myHTML = @"<html><head>";
    
    // Table Style
    myHTML = [myHTML stringByAppendingFormat:@"<STYLE TYPE='text/css'><!--TD{font-family: Arial; font-size: 12pt;}TH{font-family: Arial; font-size: 14pt;}---></STYLE></head><body><table border='1' bordercolor='#3399FF' style='background-color:#CCCCCC' width='%f' cellpadding='2' cellspacing='1'>", (self.htmlView.frame.size.width - 15)];
    
    // Table Headers
    myHTML = [myHTML stringByAppendingString:@"<tr><th style='background-color:#999999'></th><th style='background-color:#999999'>1</th><th style='background-color:#999999'>2</th><th style='background-color:#999999'>3</th><th style='background-color:#999999'>Final</th></tr>"];
    
    // Table Data
    for (int i = 0; i < measurementsNameArray.count; i++) {
        myHTML = [myHTML stringByAppendingFormat:@"<tr><td style='background-color:#999999'>%@</td>", measurementsNameArray[i]];
        
        for (int a = 0; a < measurementsArray.count; a++) {
            myHTML = [myHTML stringByAppendingFormat:@"<td>%@</td>",
                      measurementsArray[a][measurementsNameArray[i]]];
        }
        
        myHTML = [myHTML stringByAppendingString:@"</tr>"];
    }
    
    // HTML closing tags
    myHTML = [myHTML stringByAppendingString:@"</table></body></html>"];
    
    return myHTML;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self emailSummary];
    }
    
    if (buttonIndex == 1) {
        [self facebook];
    }
    
    if (buttonIndex == 2) {
        [self twitter];
    }
}

- (void)configureViewForIOSVersion {
    
    // Colors
    //UIColor *blueColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
    //UIColor *lightGreyColor = [UIColor colorWithRed:219/255.0f green:224/255.0f blue:234/255.0f alpha:1.0f];
    
    // Apply Text Colors
    
    // Apply Background Colors
    self.view.backgroundColor = [UIColor blackColor];
    
    // Apply Keyboard Color
    
}
@end
