//
//  WebsiteViewController.m
//  i90X 2
//
//  Created by Jared Grant on 7/1/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "WebsiteViewController.h"

@interface WebsiteViewController ()

@end

@implementation WebsiteViewController

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
    NSString *websiteURLString = @"http://www.grantdevelopers.com/fitness.html";
    
    NSURL *websiteURL = [[NSURL alloc] initWithString:websiteURLString];
    
    [self.websiteView loadRequest:[NSURLRequest requestWithURL:websiteURL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
