 //
//  ExerciseViewController.m
//  i90X 2
//
//  Created by Jared Grant on 4/11/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//

#import "ExerciseViewController.h"
#import "SWRevealViewController.h"

@interface ExerciseViewController ()

@end

@implementation ExerciseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setUpVariables {
    
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mainAppDelegate.week = ((DataNavController *)self.parentViewController).week;
    mainAppDelegate.workout =((DataNavController *)self.parentViewController).workout;
    mainAppDelegate.index = ((DataNavController *)self.parentViewController).index;
    mainAppDelegate.exerciseName = self.currentExercise.title;
    mainAppDelegate.exerciseRound = self.renamedRound;
}

- (void)renameRoundText {
    
    if ([self.roundButton.title isEqualToString:@"R1"]) {
        self.renamedRound = @"Round 1";
    }
    
    else if ([self.roundButton.title isEqualToString:@"R2"])
    {
        self.renamedRound = @"Round 2";
    }
    
    else if ([self.roundButton.title isEqualToString:@"R3"])
    {
        self.renamedRound = @"Round 3";
    }
}

-(void)keyboardType {
    
    // Set keyboard type
    if (self.view.frame.size.width <= 640) {
        
        // IPHONE - Set the keyboard type of the REPS text box to DECIMAL NUMBER PAD.
        self.currentReps.keyboardType = UIKeyboardTypeDecimalPad;
        
        // Set the keyboard type of the WEIGHT field
        if ([((MainTBC *)self.parentViewController.parentViewController).bandSetting isEqualToString:@"ON"]) {
            self.currentWeight.keyboardType = UIKeyboardTypeDefault;
        }
        
        else {
            self.currentWeight.keyboardType = UIKeyboardTypeDecimalPad;
        }
    }
    
    else {
        
        // IPAD - No decimal pad on ipad so set it to numbers and punctuation.
        self.currentReps.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        
        // Set the keyboard type of the WEIGHT field
        if ([((MainTBC *)self.parentViewController.parentViewController).bandSetting isEqualToString:@"ON"]) {
            self.currentWeight.keyboardType = UIKeyboardTypeDefault;
        }
        
        else {
            self.currentWeight.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
    }
}

-(void)queryDatabase {
    
    // Get Data from database.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                         ((DataNavController *)self.parentViewController).workout,
                         self.currentExercise.title,
                         self.renamedRound,
                         [((DataNavController *)self.parentViewController).index integerValue]];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    int workoutIndex = [((DataNavController *)self.parentViewController).index intValue];
    
    // 1st time exercise is done only.
    if (workoutIndex == 1) {
        // The workout has not been done before.
        // Do NOT get previous workout data.
        // Set the current placeholders to defaults/nil.
        
        if ([objects count] == 0) {
            //NSLog(@"viewDidLoad = No matches - Exercise has not been done before - set previous textfields to nil");
            
            self.currentReps.placeholder = @"0";
            self.currentWeight.placeholder = @"0.0";
            self.currentNotes.placeholder = @"Type any notes here";
            
            self.previousReps.text = @"";
            self.previousWeight.text = @"";
            self.previousNotes.text = @"";
        }
        
        // The workout has been done 1 time but the user came back to the 1st week workout screen to update or view.
        // Only use the current 1st week workout data when the user comes back to this screen.
        
        else {
            //NSLog(@"viewDidLoad = Match found - set previous textfields to stored values for this weeks workout");
            
            matches = objects[[objects count] -1];
            
            self.previousReps.text = [matches valueForKey:@"reps"];
            self.previousWeight.text = [matches valueForKey:@"weight"];
            self.previousNotes.text = [matches valueForKey:@"notes"];
        }
        
    }
    
    // 2nd time exercise has been done and beyond.
    else {
        // This workout with this index has been done before.
        // User came back to look at his results so display this weeks results in the current results section.
        
        if ([objects count] == 1) {
            matches = objects[[objects count] -1];
            
            self.currentReps.placeholder = [matches valueForKey:@"reps"];
            self.currentWeight.placeholder = [matches valueForKey:@"weight"];
            self.currentNotes.placeholder = [matches valueForKey:@"notes"];
        }
        
        // This workout with this index has NOT been done befoe.
        // Set the current placeholders to defaults/nil.
        else {
            self.currentReps.placeholder = @"0";
            self.currentWeight.placeholder = @"0.0";
            self.currentNotes.placeholder = @"Type any notes here";
        }
        
        // This is at least the 2nd time a particular workout has been started.
        // Get the previous workout data and present it to the user in the previous section.
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                             //((DataNavController *)self.parentViewController).week,
                             ((DataNavController *)self.parentViewController).workout,
                             self.currentExercise.title,
                             self.renamedRound,
                             [((DataNavController *)self.parentViewController).index integerValue] -1];  // Previous workout index.
        [request setPredicate:pred];
        NSManagedObject *matches = nil;
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if ([objects count] == 1) {
            matches = objects[[objects count]-1];
            
            self.previousReps.text = [matches valueForKey:@"reps"];
            self.previousWeight.text = [matches valueForKey:@"weight"];
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
    [self keyboardType];
    [self renameRoundText];
    [self queryDatabase];
    
    if (self.view.frame.size.width < 768) {
        [self createSliderButton];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self renameRoundText];
    [self setUpVariables];
    [self queryDatabase];
}

-(void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
    
    [self setUpVariables];
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        self.canDisplayBannerAds = YES;
    }
}

- (void)createSliderButton {
    
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.slidergraph"]) {
        
        //NSLog(@"Allow Slider");
        self.sliderButton.enabled = YES;
        
        // Slider Setup
        [self.sliderButton setTarget: self.revealViewController];
        [self.sliderButton setAction: @selector(revealToggle:)];
        [self.toolbar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error 
{
    
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner 
{
    
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner 
{
    
}

- (IBAction)submitEntry:(id)sender 
{
    NSDate *todaysDate = [NSDate date];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                         ((DataNavController *)self.parentViewController).workout,
                         self.currentExercise.title,
                         self.renamedRound,
                         [((DataNavController *)self.parentViewController).index integerValue]];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] == 0) {
        //NSLog(@"submitEntry = No matches - create new record and save");
        
        NSManagedObject *newExercise;
        newExercise = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:context];
        [newExercise setValue:self.currentReps.text forKey:@"reps"];
        [newExercise setValue:self.currentWeight.text forKey:@"weight"];
        [newExercise setValue:self.currentNotes.text forKey:@"notes"];
        [newExercise setValue:todaysDate forKey:@"date"];
        [newExercise setValue:self.currentExercise.title forKey:@"exercise"];
        [newExercise setValue:self.renamedRound forKey:@"round"];
        [newExercise setValue:((DataNavController *)self.parentViewController).phase forKey:@"phase"];
        [newExercise setValue:((DataNavController *)self.parentViewController).week forKey:@"week"];
        [newExercise setValue:((DataNavController *)self.parentViewController).workout forKey:@"workout"];
        [newExercise setValue:((DataNavController *)self.parentViewController).index forKey:@"index"];
        
    } else {
        //NSLog(@"submitEntry = Match found - update existing record and save");
        
        matches = objects[[objects count]-1];
        
        // Only update the fields that have been changed.
        if (self.currentReps.text.length != 0) {
            [matches setValue:self.currentReps.text forKey:@"reps"];
            
        }
        if (self.currentWeight.text.length != 0) {
            [matches setValue:self.currentWeight.text forKey:@"weight"];
            
        }
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
    
    if ([objects count] == 1) {
        matches = objects[[objects count]-1];
        self.currentReps.placeholder = [matches valueForKey:@"reps"];
        self.currentWeight.placeholder = [matches valueForKey:@"weight"];
        self.currentNotes.placeholder = [matches valueForKey:@"notes"];
    }
    
    self.currentReps.text = @"";
    self.currentWeight.text = @"";
    self.currentNotes.text = @"";
    
    [self hideKeyboard:sender];
}

- (IBAction)hideKeyboard:(id)sender {
    [self.currentReps resignFirstResponder];
    [self.currentWeight resignFirstResponder];
    [self.currentNotes resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ResultsViewController *resultsVC = (ResultsViewController *)segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"coreFitness"])
    {
        resultsVC.exerciseNames = ((DataNavController *)self.parentViewController).coreFitness;
    }
    if ([segue.identifier isEqualToString:@"strengthStability"]) {
        resultsVC.exerciseNames = ((DataNavController *)self.parentViewController).strengthStability;
    }
}

- (void)configureViewForIOSVersion {
    
    // Colors
    UIColor *blueColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
    UIColor *lightGreyColor = [UIColor colorWithRed:219/255.0f green:224/255.0f blue:234/255.0f alpha:1.0f];
    
    // Apply Text Colors
    self.currentRepsLabel.textColor = blueColor;
    self.currentWeightLabel.textColor = blueColor;
    self.currentNotesLabel.textColor = blueColor;
    
    self.previousRepsLabel.textColor = lightGreyColor;
    self.previousWeightLabel.textColor = lightGreyColor;
    self.previousNotesLabel.textColor = lightGreyColor;
    
    self.sliderButton.tintColor = blueColor;
    self.currentExercise.tintColor = blueColor;
    self.roundButton.tintColor = blueColor;
    
    self.currentExercise.style = UIBarButtonItemStyleDone;

    // Apply Background Colors
    self.previousReps.backgroundColor = lightGreyColor;
    self.previousWeight.backgroundColor = lightGreyColor;
    self.previousNotes.backgroundColor = lightGreyColor;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Apply Keyboard Color
    self.currentReps.keyboardAppearance = UIKeyboardAppearanceDark;
    self.currentWeight.keyboardAppearance = UIKeyboardAppearanceDark;
    self.currentNotes.keyboardAppearance = UIKeyboardAppearanceDark;
    
    // Show or Hide Ads
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        self.canDisplayBannerAds = YES;
    }
}
@end
