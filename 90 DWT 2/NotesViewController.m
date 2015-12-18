//
//  NotesViewController.m
//  i90X 2
//
//  Created by Jared Grant on 4/15/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//

#import "NotesViewController.h"
#import "DWT2IAPHelper.h"
#import "CoreDataHelper.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)queryDatabase {
    
    // Get the objects for the current session
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Fetch current session data.
    NSString *currentSessionString = [mainAppDelegate getCurrentSession];
    
    // Get the workout data with the current session
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                         currentSessionString,
                         ((DataNavController *)self.parentViewController).workout,
                         self.navigationItem.title,
                         self.round.text,
                         [((DataNavController *)self.parentViewController).index integerValue]];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    int workoutIndex = [((DataNavController *)self.parentViewController).index intValue];
    //NSLog(@"%@ index = %@", ((DataNavController *)self.parentViewController).workout, ((DataNavController *)self.parentViewController).index);

    // 1st time exercise is done only.
    if (workoutIndex == 1) {
        // The workout has not been done before.
        // Do NOT get previous workout data.
        
        if ([objects count] == 0) {
            //NSLog(@"viewDidLoad = No matches - Exercise has not been done before - set previous textfields to nil");
            
            self.currentNotes.text = @"Type any notes here";
            self.previousNotes.text = @"";
        }
        
        // The workout has been done 1 time but the user came back to the 1st week workout screen to update or view.
        // Only use the current 1st week workout data when the user comes back to this screen.
        
        else {
            //NSLog(@"viewDidLoad = Match found - set previous textfields to stored values for this weeks workout");
            
            matches = objects[[objects count] -1];
            
            self.previousNotes.text = [matches valueForKey:@"notes"];
        }
        
    }
    
    // 2nd time exercise has been done and beyond.
    else {
        // This workout with this index has been done before.
        // User came back to look at his results so display this weeks results in the current results section.
        
        if ([objects count] >= 1) {
            matches = objects[[objects count] -1];
            
            self.currentNotes.text = [matches valueForKey:@"notes"];
        }
        
        // This workout with this index has NOT been done befoe.
        // Set the current placeholders to defaults/nil.
        else {
            self.currentNotes.text = @"Type any notes here";
        }
        
        // This is at least the 2nd time a particular workout has been started.
        // Get the previous workout data and present it to the user in the previous section.
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                             currentSessionString,
                             ((DataNavController *)self.parentViewController).workout,
                             self.navigationItem.title,
                             self.round.text,
                             [((DataNavController *)self.parentViewController).index integerValue] -1];  // Previous workout index.
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if ([objects count] >= 1) {
            matches = objects[[objects count]-1];
            
            self.previousNotes.text = [matches valueForKey:@"notes"];
        }
        
        else {
            self.previousNotes.text = @"No record for the last workout";
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self configureViewForIOSVersion];
    [self queryDatabase];
    
    // Respond to changes in underlying store
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:@"SomethingChanged"
                                               object:nil];
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        //self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        //self.canDisplayBannerAds = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            // iPhone
            self.adView = [[MPAdView alloc] initWithAdUnitId:@"4bed96fcb70a4371b972bf19d149e433"
                                                        size:MOPUB_BANNER_SIZE];
            self.bannerSize = MOPUB_BANNER_SIZE;
            
        } else {
            
            // iPad
            self.adView = [[MPAdView alloc] initWithAdUnitId:@"7c80f30698634a22b77778b084e3087e"
                                                        size:MOPUB_LEADERBOARD_SIZE];
            self.bannerSize = MOPUB_LEADERBOARD_SIZE;
            
        }
        
        self.adView.delegate = self;
        self.adView.frame = CGRectMake((self.view.bounds.size.width - self.bannerSize.width) / 2,
                                       self.view.bounds.size.height - self.bannerSize.height - self.tabBarController.tabBar.bounds.size.height,
                                       self.bannerSize.width, self.bannerSize.height);
        
        [self.view addSubview:self.adView];
        
        [self.adView loadAd];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView setText:@""];
}

-(void)viewWillAppear:(BOOL)animated 
{
    self.currentNotes.delegate = self;
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        //self.canDisplayBannerAds = NO;
        self.adView.delegate = nil;
        self.adView = nil;
        [self.adView removeFromSuperview];
        
    } else {
        
        // Show the Banner Ad
        //self.canDisplayBannerAds = YES;
        
        self.adView.hidden = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // Don't show ads.
        self.adView.delegate = nil;
        self.adView = nil;
        [self.adView removeFromSuperview];
        
    } else {
        
        // Show ads
        self.adView.frame = CGRectMake((self.view.bounds.size.width - self.bannerSize.width) / 2,
                                       self.view.bounds.size.height - self.bannerSize.height - self.tabBarController.tabBar.bounds.size.height,
                                       self.bannerSize.width, self.bannerSize.height);
        self.adView.hidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)submitEntry:(id)sender {
    NSDate *todaysDate = [NSDate date];
    
    // Get the objects for the current session
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Fetch current session data.
    NSString *currentSessionString = [mainAppDelegate getCurrentSession];
    
    // Save the workout data with the current session
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                         currentSessionString,
                         ((DataNavController *)self.parentViewController).workout,
                         self.navigationItem.title,
                         self.round.text,
                         [((DataNavController *)self.parentViewController).index integerValue]];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] == 0) {
        //NSLog(@"submitEntry = No matches - create new record and save");
        
        NSManagedObject *newExercise;
        newExercise = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:context];
        [newExercise setValue:currentSessionString forKey:@"session"];
        [newExercise setValue:self.currentNotes.text forKey:@"notes"];
        [newExercise setValue:todaysDate forKey:@"date"];
        [newExercise setValue:self.navigationItem.title forKey:@"exercise"];
        [newExercise setValue:self.round.text forKey:@"round"];
        [newExercise setValue:((DataNavController *)self.parentViewController).month forKey:@"month"];
        [newExercise setValue:((DataNavController *)self.parentViewController).week forKey:@"week"];
        [newExercise setValue:((DataNavController *)self.parentViewController).workout forKey:@"workout"];
        [newExercise setValue:((DataNavController *)self.parentViewController).index forKey:@"index"];
        
    } else {
        //NSLog(@"submitEntry = Match found - update existing record and save");
        
        matches = objects[[objects count]-1];
        
        // Only update the fields that have been changed.
        if (self.currentNotes.text.length != 0) {
            [matches setValue:self.currentNotes.text forKey:@"notes"];
        }
        [matches setValue:todaysDate forKey:@"date"];
        
    }
    
    [context save:&error];
    
    [request setPredicate:pred];
    matches = nil;
    objects = nil;
    objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] >= 1) {
        matches = objects[[objects count]-1];
    
        self.currentNotes.text = [matches valueForKey:@"notes"];
    }
    
    self.currentNotes.textColor = [UIColor grayColor];
    
    [self hideKeyboard:sender];
}

- (IBAction)hideKeyboard:(id)sender {
    [self.currentNotes resignFirstResponder];
}

- (void)emailResults
{
    // Create MailComposerViewController object.
    MFMailComposeViewController *mailComposer;
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor = [UIColor whiteColor];
    
    // Check to see if the device has at least 1 email account configured
    if ([MFMailComposeViewController canSendMail]) {
        
        // Get the objects for the current session
        NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
        AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // Fetch current session data.
        NSString *currentSessionString = [mainAppDelegate getCurrentSession];
        
        // Get workout data with current session
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (index = %d)",
                             currentSessionString,
                             ((DataNavController *)self.parentViewController).workout,
                             [((DataNavController *)self.parentViewController).index integerValue]];
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
        
        if ([objects count] != 0)
        {
            // Get data from database
            
            [writeString appendString:[NSString stringWithFormat:@"Session,Month,Week,Workout,Notes,Date\n"]];
            
            for (int i = 0; i < [objects count]; i++) {
                matches = objects[i];
                NSString *session =     [matches valueForKey:@"session"];
                NSString *month =       [matches valueForKey:@"month"];
                NSString *week  =       [matches valueForKey:@"week"];
                NSString *workout =     [matches valueForKey:@"workout"];
                NSString *notes =       [matches valueForKey:@"notes"];
                NSString *date =        [matches valueForKey:@"date"];
                
                [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@\n",
                                           session, month, week, workout, notes, date]];
            }
        }
        
        // Send email
        
        NSData *csvData = [writeString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *workoutName = ((DataNavController *)self.parentViewController).workout;
        workoutName = [workoutName stringByAppendingString:@".csv"];
        
        // Fetch defaultEmail data.
        NSEntityDescription *entityDescEmail = [NSEntityDescription entityForName:@"Email" inManagedObjectContext:context];
        NSFetchRequest *requestEmail = [[NSFetchRequest alloc] init];
        [requestEmail setEntity:entityDescEmail];
        matches = nil;
        error = nil;
        objects = [context executeFetchRequest:requestEmail error:&error];
        
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
        
        [mailComposer setSubject:@"90 DWT 2 Workout Data"];
        [mailComposer addAttachmentData:csvData mimeType:@"text/csv" fileName:workoutName];
        [self presentViewController:mailComposer animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareActionSheet:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook", @"Twitter", nil];
    
    [action showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
        if (buttonIndex == 0) {
            [self emailResults];
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
    UIColor *lightGreyColor = [UIColor colorWithRed:219/255.0f green:224/255.0f blue:234/255.0f alpha:1.0f];
    
    // Apply Text Colors
    self.currentNotesLabel.textColor = blueColor;
    
    self.previousNotesLabel.textColor = lightGreyColor;
    
    self.round.hidden = YES;
    
    // Apply Background Colors
    self.currentNotes.backgroundColor = [UIColor whiteColor];
    self.previousNotes.backgroundColor = lightGreyColor;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Apply Keyboard Color
    self.currentNotes.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *workoutName = ((DataNavController *)self.parentViewController).workout;
    Workout_AbRipper_ResultsViewController *summaryVC = (Workout_AbRipper_ResultsViewController *)segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"toSummary"])
    {
        if ([workoutName isEqualToString:@"Complete Fitness & Ab Workout"]) {
            summaryVC.exerciseNames = ((DataNavController *)self.parentViewController).completeFitness;
        }
        
        if ([workoutName isEqualToString:@"Chest + Back + Stability & Ab Workout"]) {
            summaryVC.exerciseNames = ((DataNavController *)self.parentViewController).chestBackStability;
        }
        
        if ([workoutName isEqualToString:@"Shoulder + Bi + Tri & Ab Workout"]) {
            summaryVC.exerciseNames = ((DataNavController *)self.parentViewController).shoulderBiTri;
        }
        
        if ([workoutName isEqualToString:@"Legs + Back & Ab Workout"]) {
            summaryVC.exerciseNames = ((DataNavController *)self.parentViewController).legsBack;
        }
    }
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.view.bounds.size.height - size.height - self.tabBarController.tabBar.bounds.size.height;
    view.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    self.adView.hidden = YES;
    [self.adView rotateToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGSize size = [self.adView adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.view.bounds.size.height - size.height - self.tabBarController.tabBar.bounds.size.height;
    self.adView.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
    
    self.adView.hidden = NO;
}

- (void)updateUI {
    
    if ([CoreDataHelper sharedHelper].iCloudStore) {
        [self queryDatabase];
    }
}
@end
