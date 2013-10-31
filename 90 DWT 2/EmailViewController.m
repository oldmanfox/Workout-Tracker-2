//
//  EmailViewController.m
//  i90X 2
//
//  Created by Jared Grant on 7/1/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "EmailViewController.h"

@interface EmailViewController ()

@end

@implementation EmailViewController

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
    self.defaultEmail.text = ((SettingsNavController *)self.parentViewController).emailAddress;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)hideKeyboard:(id)sender {
    [self.defaultEmail resignFirstResponder];
}

- (IBAction)saveEmail:(id)sender {
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *defaultEmailFile = nil;
    defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];
        
    // Create the file
    [[NSFileManager defaultManager] createFileAtPath:defaultEmailFile contents:nil attributes:nil];
        
    // Write file to documents directory
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:defaultEmailFile];
    [fileHandle writeData:[self.defaultEmail.text dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
        
    ((SettingsNavController *)self.parentViewController).emailAddress = self.defaultEmail.text;
    
    // Clear the text field and show the placeholder text.
    self.defaultEmail.placeholder = self.defaultEmail.text;
    self.defaultEmail.text = @"";
}

- (void)configureViewForIOSVersion {
    
    // Colors
    UIColor *blueColor = [UIColor colorWithRed:76/255.0f green:152/255.0f blue:213/255.0f alpha:1.0f];
    //UIColor *lightGreyColor = [UIColor colorWithRed:219/255.0f green:224/255.0f blue:234/255.0f alpha:1.0f];
    
    // Apply Text Colors
    self.emailLabel.textColor = blueColor;
    
    // Apply Background Colors
    self.view.backgroundColor = [UIColor blackColor];
    
    // Apply Keyboard Color
    self.defaultEmail.keyboardAppearance = UIKeyboardAppearanceDark;
}

@end
