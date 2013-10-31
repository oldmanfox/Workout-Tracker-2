//
//  SettingsNavController.m
//  i90X 2
//
//  Created by Jared Grant on 6/6/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "SettingsNavController.h"

@interface SettingsNavController ()

@end

@implementation SettingsNavController

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
