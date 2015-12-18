//
//  MeasurementsViewController.m
//  i90X 2
//
//  Created by Jared Grant on 6/29/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "MeasurementsViewController.h"
#import "AppDelegate.h"

@interface MeasurementsViewController ()

@end

@implementation MeasurementsViewController

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
    
    // Respond to changes in underlying store
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:@"SomethingChanged"
                                               object:nil];

    [self configureViewForIOSVersion];
    [self loadMeasurements];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)emailMeasurements {
    
    // Create MailComposerViewController object.
    MFMailComposeViewController *mailComposer;
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor = [UIColor whiteColor];
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
        
        NSString *currentSessionString = [mainAppDelegate getCurrentSession];
        
        NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
        [writeString appendString:[NSString stringWithFormat:@"Session,Month,Weight,Chest,Left Arm,Right Arm,Waist,Hips,Left Thigh,Right Thigh\n"]];
        
        // Get workout data with the current session
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@)", currentSessionString];
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if ([objects count] >= 1) {
            matches = objects[[objects count]-1];
            
            [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                       currentSessionString,
                                       self.navigationItem.title,
                                       [matches valueForKey:@"weight"],
                                       [matches valueForKey:@"chest"],
                                       [matches valueForKey:@"leftArm"],
                                       [matches valueForKey:@"rightArm"],
                                       [matches valueForKey:@"waist"],
                                       [matches valueForKey:@"hips"],
                                       [matches valueForKey:@"leftThigh"],
                                       [matches valueForKey:@"rightThigh"]]];
            
            NSData *csvData = [writeString dataUsingEncoding:NSASCIIStringEncoding];
            //NSString *fileName = [self.navigationItem.title stringByAppendingString:@" Measurements - Session %@.csv", currentSessionString];
            NSString *fileName = [NSString stringWithFormat:@"90 DWT 2 %@ Measurements - Session %@.csv", self.navigationItem.title, currentSessionString];
            
            // Fetch defaultEmail data.
            entityDesc = [NSEntityDescription entityForName:@"Email" inManagedObjectContext:context];
            request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDesc];
            matches = nil;
            error = nil;
            objects = [context executeFetchRequest:request error:&error];
            
            // Array to store the default email address.
            NSArray *emailAddresses;
            
            if ([objects count] != 0) {
                
                matches = objects[[objects count] - 1];
                
                // There is a default email address.
                emailAddresses = @[[matches valueForKey:@"defaultEmail"]];
            }
            else {
                
                // There is NOT a default email address.  Put an empty email address in the arrary.
                emailAddresses = @[@""];
            }
            
            [mailComposer setToRecipients:emailAddresses];
            
            NSString *subject = @"90 DWT 2";
            subject = [subject stringByAppendingFormat:@" %@ Measurements - Session %@", self.navigationItem.title, currentSessionString];
            [mailComposer setSubject:subject];
            [mailComposer addAttachmentData:csvData mimeType:@"text/csv" fileName:fileName];
            [self presentViewController:mailComposer animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadMeasurements {
    
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    
    NSString *currentSessionString = [mainAppDelegate getCurrentSession];
    
    // Get workout data with the current session
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (month = %@)", currentSessionString, ((MeasurementsNavController *)self.parentViewController).monthString];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] >= 1) {
        matches = objects[[objects count]-1];
        
        self.weight.text = [matches valueForKey:@"weight"];
        self.chest.text = [matches valueForKey:@"chest"];
        self.waist.text = [matches valueForKey:@"waist"];
        self.hips.text = [matches valueForKey:@"hips"];
        self.leftArm.text = [matches valueForKey:@"leftArm"];
        self.rightArm.text = [matches valueForKey:@"rightArm"];
        self.leftThigh.text = [matches valueForKey:@"leftThigh"];
        self.rightThigh.text = [matches valueForKey:@"rightThigh"];
    }
}
 
- (void)saveMeasurements {
    
    NSDate *todaysDate = [NSDate date];
    
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    
    NSString *currentSessionString = [mainAppDelegate getCurrentSession];
    
    if (self.weight.text == nil) {
        self.weight.text = @"0";
    }
    
    if (self.chest.text == nil) {
        self.chest.text = @"0";
    }
    
    if (self.leftArm.text == nil) {
        self.leftArm.text = @"0";
    }
    
    if (self.rightArm.text == nil) {
        self.rightArm.text = @"0";
    }
    
    if (self.waist.text == nil) {
        self.waist.text = @"0";
    }
    
    if (self.hips.text == nil) {
        self.hips.text = @"0";
    }
    
    if (self.leftThigh.text == nil) {
        self.leftThigh.text = @"0";
    }
    
    if (self.rightThigh.text == nil) {
        self.rightThigh.text = @"0";
    }
    
    // Save the workout data with the current session
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (month = %@)", currentSessionString, ((MeasurementsNavController *)self.parentViewController).monthString];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] == 0) {
        //NSLog(@"submitEntry = No matches - create new record and save");
        
        NSManagedObject *newMeasurement;
        newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:context];
        [newMeasurement setValue:currentSessionString forKey:@"session"];
        [newMeasurement setValue:((MeasurementsNavController *)self.parentViewController).monthString forKey:@"month"];
        [newMeasurement setValue:todaysDate forKey:@"date"];
        [newMeasurement setValue:self.weight.text forKey:@"weight"];
        [newMeasurement setValue:self.chest.text forKey:@"chest"];
        [newMeasurement setValue:self.waist.text forKey:@"waist"];
        [newMeasurement setValue:self.hips.text forKey:@"hips"];
        [newMeasurement setValue:self.leftArm.text forKey:@"leftArm"];
        [newMeasurement setValue:self.rightArm.text forKey:@"rightArm"];
        [newMeasurement setValue:self.leftThigh.text forKey:@"leftThigh"];
        [newMeasurement setValue:self.rightThigh.text forKey:@"rightThigh"];
        
    } else {
        //NSLog(@"submitEntry = Match found - update existing record and save");
        
        matches = objects[[objects count]-1];
        
        [matches setValue:todaysDate forKey:@"date"];
        [matches setValue:self.weight.text forKey:@"weight"];
        [matches setValue:self.chest.text forKey:@"chest"];
        [matches setValue:self.waist.text forKey:@"waist"];
        [matches setValue:self.hips.text forKey:@"hips"];
        [matches setValue:self.leftArm.text forKey:@"leftArm"];
        [matches setValue:self.rightArm.text forKey:@"rightArm"];
        [matches setValue:self.leftThigh.text forKey:@"leftThigh"];
        [matches setValue:self.rightThigh.text forKey:@"rightThigh"];
    }
    
    [[CoreDataHelper sharedHelper] backgroundSaveContext];
    
    UIAlertView *alert;
    
    alert = [[UIAlertView alloc] initWithTitle:@"Save Success!"
                                       message:@"Your data was successfully saved."
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)hideKeyboard:(id)sender {
    [self.weight resignFirstResponder];
    [self.chest resignFirstResponder];
    [self.leftArm resignFirstResponder];
    [self.rightArm resignFirstResponder];
    [self.waist resignFirstResponder];
    [self.hips resignFirstResponder];
    [self.leftThigh resignFirstResponder];
    [self.rightThigh resignFirstResponder];
}

- (IBAction)actionSheet:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook", @"Twitter", nil];
    [action showFromBarButtonItem:sender animated:YES];
}

- (IBAction)saveAction:(id)sender {
    
    [self saveMeasurements];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self emailMeasurements];
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
    UIColor *blueColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
    //UIColor *lightGreyColor = [UIColor colorWithRed:219/255.0f green:224/255.0f blue:234/255.0f alpha:1.0f];
    
    // Apply Text Colors
    self.weightLabel.textColor = blueColor;
    self.leftArmLabel.textColor = blueColor;
    self.rightArmLabel.textColor = blueColor;
    self.chestLabel.textColor = blueColor;
    self.waistLabel.textColor = blueColor;
    self.hipsLabel.textColor = blueColor;
    self.leftThighLabel.textColor = blueColor;
    self.rightThighLabel.textColor = blueColor;
    
    // Apply Background Colors
    self.view.backgroundColor = [UIColor blackColor];
    
    // Apply Keyboard Color
    self.weight.keyboardAppearance = UIKeyboardAppearanceDark;
    self.chest.keyboardAppearance = UIKeyboardAppearanceDark;
    self.leftArm.keyboardAppearance = UIKeyboardAppearanceDark;
    self.rightArm.keyboardAppearance = UIKeyboardAppearanceDark;
    self.waist.keyboardAppearance = UIKeyboardAppearanceDark;
    self.hips.keyboardAppearance = UIKeyboardAppearanceDark;
    self.leftThigh.keyboardAppearance = UIKeyboardAppearanceDark;
    self.rightThigh.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)updateUI {
    
    if ([CoreDataHelper sharedHelper].iCloudStore) {
        
        [self loadMeasurements];
    }
}
@end
