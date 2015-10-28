//
//  Workout_AbRipper_ResultsViewController.m
//  i90X 2
//
//  Created by Jared Grant on 4/30/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "Workout_AbRipper_ResultsViewController.h"
#import "DWT2IAPHelper.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(workout = %@) AND (index = %d)",
                         ((DataNavController *)self.parentViewController).workout,
                         [((DataNavController *)self.parentViewController).index integerValue]];
    
    //NSLog(@"Workout = %@", ((DataNavController *)self.parentViewController).workout);
    //NSLog(@"Index = %@", ((DataNavController *)self.parentViewController).index);
    
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
    
    if ([objects count] != 0)
    {
        for (int a = 0; a < [self.exerciseNames count]; a++)
        {
            BOOL matchFound = false;
            NSString *arrayExerciseNameRound = self.exerciseNames[a];
            NSString *exerciseNameClean = [arrayExerciseNameRound substringToIndex:[arrayExerciseNameRound length] - 8];
            
            for (int i = 0; i < [objects count]; i++) 
            {
                matches = objects[i];
                NSString *exercise = [matches valueForKey:@"exercise"];
                NSString *reps = [matches valueForKey:@"reps"];
                NSString *weight = [matches valueForKey:@"weight"];
                NSString *notes = [matches valueForKey:@"notes"];
                NSString *round = [matches valueForKey:@"round"];
                
                
                NSString *combinedExerciseNameRound = [exercise stringByAppendingString:@" "];
                combinedExerciseNameRound = [combinedExerciseNameRound stringByAppendingString:round];
                
                if ([arrayExerciseNameRound isEqualToString:combinedExerciseNameRound]) 
                {
                    [writeString appendString:[NSString stringWithFormat:@"%@ \n  Reps: %@  Wt: %@ \n  Notes: %@ \n\n",
                                               exercise, reps, weight, notes]];
                    matchFound = true;
                }
            }
            
            if (!matchFound) 
            {
                [writeString appendString:[NSString stringWithFormat:@"%@ \n  Reps:    Wt:   \n  Notes: \n\n", exerciseNameClean]]; 
            }
        }
    }
        self.workoutSummary.text = writeString;
    
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
    
    // Check to see if the device has at least 1 email account configured.
    if ([MFMailComposeViewController canSendMail]) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(workout = %@) AND (index = %d)",
                             ((DataNavController *)self.parentViewController).workout,
                             [((DataNavController *)self.parentViewController).index integerValue]];
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
        
        if ([objects count] != 0)
        {
            [writeString appendString:[NSString stringWithFormat:@"Phase,Week,Workout,Round,Exercise,Reps,Weight,Notes,Date\n"]];
            for (int a = 0; a < [self.exerciseNames count]; a++) 
            {
                BOOL matchFound = false;
                NSString *arrayExerciseNameRound = self.exerciseNames[a];
                
                // Remove the (Round #) at the end of the exercise name.
                NSString *exerciseNameClean = [arrayExerciseNameRound substringToIndex:[arrayExerciseNameRound length] - 8];
                
                for (int i = 0; i < [objects count]; i++) 
                {
                    matches = objects[i];
                    NSString *phase =       [matches valueForKey:@"phase"];
                    NSString *week  =       [matches valueForKey:@"week"];
                    NSString *workout =     [matches valueForKey:@"workout"];
                    NSString *round =       [matches valueForKey:@"round"];
                    NSString *exercise =    [matches valueForKey:@"exercise"];
                    NSString *reps =        [matches valueForKey:@"reps"];
                    NSString *weight =      [matches valueForKey:@"weight"];
                    NSString *notes =       [matches valueForKey:@"notes"];
                    NSString *date =        [matches valueForKey:@"date"];
                    
                    NSString *combinedExerciseNameRound = [exercise stringByAppendingString:@" "];
                    combinedExerciseNameRound = [combinedExerciseNameRound stringByAppendingString:round];
                    
                    if ([arrayExerciseNameRound isEqualToString:combinedExerciseNameRound]) 
                    {
                        [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                                   phase, week, workout, round, exercise, reps, weight, notes, date]];
                        matchFound = true;
                    }
                }
                
                if (!matchFound) 
                {
                    [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,,%@,,,,\n",
                                               ((DataNavController *)self.parentViewController).phase,
                                               ((DataNavController *)self.parentViewController).week,
                                               ((DataNavController *)self.parentViewController).workout,
                                               exerciseNameClean]];
                }
            }
        }
        
        // Send email
        
        NSData *csvData = [writeString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *workoutName = ((DataNavController *)self.parentViewController).workout;
        workoutName = [workoutName stringByAppendingString:@".csv"];
        
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
        [mailComposer setSubject:@"90 DWT 2 Workout Data"];
        [mailComposer addAttachmentData:csvData mimeType:@"text/csv" fileName:workoutName];
        [self presentViewController:mailComposer animated:YES completion:nil];
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
@end
