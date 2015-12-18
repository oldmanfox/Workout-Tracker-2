//
//  Workout_AbRipper_ResultsViewController.m
//  i90X 2
//
//  Created by Jared Grant on 4/30/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "Workout_AbRipper_ResultsViewController.h"
#import "DWT2IAPHelper.h"
#import "CoreDataHelper.h"

@interface Workout_AbRipper_ResultsViewController ()

@end

@implementation Workout_AbRipper_ResultsViewController

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
    
    // Get workout data with current session
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
    
    for (int x = 0; x < [self.exerciseNames count]; x++) {
        
        NSString *arrayExerciseNameRound = self.exerciseNames[x];
        
        NSString *currentExercise = [arrayExerciseNameRound substringToIndex:[arrayExerciseNameRound length] - 8];
        NSString *currentRound = [arrayExerciseNameRound substringFromIndex:[arrayExerciseNameRound length] - 7];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                             currentSessionString,
                             ((DataNavController *)self.parentViewController).workout,
                             currentExercise,
                             currentRound,
                             [((DataNavController *)self.parentViewController).index integerValue]];
        
        //NSLog(@"Workout = %@", ((DataNavController *)self.parentViewController).workout);
        //NSLog(@"Index = %@", ((DataNavController *)self.parentViewController).index);
        
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if ([objects count] != 0)
        {
            matches = objects[[objects count] -1];
            NSString *exercise = [matches valueForKey:@"exercise"];
            NSString *reps = [matches valueForKey:@"reps"];
            NSString *weight = [matches valueForKey:@"weight"];
            NSString *notes = [matches valueForKey:@"notes"];
            
            [writeString appendString:[NSString stringWithFormat:@"%@ \n  Reps: %@  Wt: %@ \n  Notes: %@ \n\n", exercise, reps, weight, notes]];
            
        } else {
            
            [writeString appendString:[NSString stringWithFormat:@"%@ \n  Reps:    Wt:   \n  Notes: \n\n", currentExercise]];
        }
    }
    
    self.workoutSummary.text = writeString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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

    // Set Content Insets to account for the new Adview on the screen
    CGFloat top = self.workoutSummary.contentInset.top;
    CGFloat left = self.workoutSummary.contentInset.left;
    CGFloat bottom = self.workoutSummary.contentInset.bottom + self.bannerSize.height;
    CGFloat right = self.workoutSummary.contentInset.right;
    
    [self.workoutSummary setContentInset:UIEdgeInsetsMake(top, left, bottom, right)];
}

- (void)viewDidUnload
{
    [self setWorkoutSummary:nil];
    [self setExerciseNames:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
    
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

- (void)viewDidAppear:(BOOL)animated {
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)emailResults
{
    // Create MailComposerViewController object.
    MFMailComposeViewController *mailComposer;
    mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor = [UIColor whiteColor];
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        // Get the objects for the current session
        NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
        AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // Fetch current session data.
        NSString *currentSessionString = [mainAppDelegate getCurrentSession];
        
        // Get workout data with the current session
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
        [writeString appendString:[NSString stringWithFormat:@"Session,Month,Week,Workout,Round,Exercise,Reps,Weight,Notes,Date\n"]];
        
        for (int x = 0; x < [self.exerciseNames count]; x++) {
            
            NSString *arrayExerciseNameRound = self.exerciseNames[x];
            
            NSString *currentExercise = [arrayExerciseNameRound substringToIndex:[arrayExerciseNameRound length] - 8];
            NSString *currentRound = [arrayExerciseNameRound substringFromIndex:[arrayExerciseNameRound length] - 7];
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                                 currentSessionString,
                                 ((DataNavController *)self.parentViewController).workout,
                                 currentExercise,
                                 currentRound,
                                 [((DataNavController *)self.parentViewController).index integerValue]];
            
            //NSLog(@"Routine = %@", ((DataNavController *)self.parentViewController).routine);
            //NSLog(@"Workout = %@", ((DataNavController *)self.parentViewController).workout);
            //NSLog(@"Index = %@", ((DataNavController *)self.parentViewController).index);
            
            [request setPredicate:pred];
            NSManagedObject *matches = nil;
            NSError *error;
            NSArray *objects = [context executeFetchRequest:request error:&error];
            
            if ([objects count] != 0)
            {
                matches = objects[[objects count] -1];
                NSString *session =     [matches valueForKey:@"session"];
                NSString *month =       [matches valueForKey:@"month"];
                NSString *week  =       [matches valueForKey:@"week"];
                NSString *workout =     [matches valueForKey:@"workout"];
                NSString *round =       [matches valueForKey:@"round"];
                NSString *exercise =    [matches valueForKey:@"exercise"];
                NSString *reps =        [matches valueForKey:@"reps"];
                NSString *weight =      [matches valueForKey:@"weight"];
                NSString *notes =       [matches valueForKey:@"notes"];
                NSString *date =        [matches valueForKey:@"date"];
                
                [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                           session, month, week, workout, round, exercise, reps, weight, notes, date]];
                
            } else {
                
                [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,,%@,,,,\n",
                                           currentSessionString,
                                           ((DataNavController *)self.parentViewController).month,
                                           ((DataNavController *)self.parentViewController).week,
                                           ((DataNavController *)self.parentViewController).workout,
                                           currentExercise]];
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
        NSManagedObject *matches = nil;
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:requestEmail error:&error];
        
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
