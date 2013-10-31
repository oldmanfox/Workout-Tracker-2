//
//  ExerciseViewController.h
//  i90X 2
//
//  Created by Jared Grant on 4/11/12.
//  Copyright (c) 2012 Jared Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "DataNavController.h"
#import "AppDelegate.h"
#import "ResultsViewController.h"
#import "MainTBC.h"
#import "ScatterPlotViewController.h"
#import "DWT2IAPHelper.h"
#import "UIViewController+iAdBanner.h"

@interface ExerciseViewController : UIViewController <ADBannerViewDelegate>

// Current Labels
@property (weak, nonatomic) IBOutlet UILabel *currentRepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentNotesLabel;

// Current TextFields
@property (weak, nonatomic) IBOutlet UITextField *currentReps;
@property (weak, nonatomic) IBOutlet UITextField *currentWeight;
@property (weak, nonatomic) IBOutlet UITextField *currentNotes;

// Previous Labels
@property (weak, nonatomic) IBOutlet UILabel *previousRepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousNotesLabel;

// Previous TextFields
@property (weak, nonatomic) IBOutlet UITextField *previousReps;
@property (weak, nonatomic) IBOutlet UITextField *previousWeight;
@property (weak, nonatomic) IBOutlet UITextField *previousNotes;

// Toolbar
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sliderButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *roundButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentExercise;

@property (weak, nonatomic) IBOutlet UIButton *hideKeyboardButton;
@property (weak, nonatomic) NSString *renamedRound;

- (IBAction)submitEntry:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end