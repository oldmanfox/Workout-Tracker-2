//
//  WebViewController.m
//  90 DWT 1
//
//  Created by Jared Grant on 5/9/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "WebViewController.h"
#import "UIViewController+CoreData.h"
#import "DWT2IAPHelper.h"

@interface WebViewController ()

@end

@implementation WebViewController

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
    
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.slidergraph"]) {
        
        //NSLog(@"Allow iPad Table");

        [self.htmlView loadHTMLString:[self createHTML] baseURL:nil];
        self.htmlView.hidden = NO;
        
    } else {
        self.htmlView.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)createHTML {
    
    NSArray *matchesArray = [self databaseMatches];
    NSString *myHTML = @"";
    
    // Check to see what device you are using iPad or iPhone.
    NSString *deviceModel = [UIDevice currentDevice].model;
    
    if ([deviceModel isEqualToString:@"iPad"] || [deviceModel isEqualToString:@"iPad Simulator"]) {
        
        // iPad
        myHTML = @"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'><html xmlns='http://www.w3.org/1999/xhtml'><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8' /><title>Untitled Document</title><style type='text/css'>.WhiteColor {color: #FFF;}.rightBoarder {}body {background-color: #000;}</style></head><body><table width='349' border='1'><tr bgcolor='#297FD5' class='WhiteColor'><th width='24' scope='col'>Wk</th><th width='28' scope='col'>Rep</th><th width='20' scope='col'>Wt</th><th width='163' scope='col'>Notes</th></tr>";
        
    } else {
        
        // iPhone
        myHTML = @"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'><html xmlns='http://www.w3.org/1999/xhtml'><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8' /><title>Untitled Document</title><style type='text/css'>.WhiteColor {color: #FFF;}.rightBoarder {}body {background-color: #000;}</style></head><body><table width='245' border='1'><tr bgcolor='#297FD5' class='WhiteColor'><th width='24' scope='col'>Wk</th><th width='28' scope='col'>Rep</th><th width='20' scope='col'>Wt</th><th width='163' scope='col'>Notes</th></tr>";
    }
    
    // Table Data
    for (int i = 1; i <= matchesArray.count; i++) {
        
        // Create tabel row
        if (i & 1) {
            // Odd - Row color = light blue
            myHTML = [myHTML stringByAppendingString:@"<tr bgcolor='#D5E6F7'>"];
        } else {
            // Even - Row color = white
            myHTML = [myHTML stringByAppendingString:@"<tr bgcolor='#FFFFFF'>"];
        }
        
        // Remove the work "week " from the string leaving only the number at the end
        NSString *cleanDate = [[NSString alloc] initWithString:[[matchesArray[i-1] valueForKey:@"week"] substringFromIndex:5]];
        
        // Insert data into table cell
        myHTML = [myHTML stringByAppendingFormat:@"<td class='rightBoarder'><span class='rightBoarder'>%@</span></td><td class='rightBoarder'><span class='rightBoarder'>%@</span></td><td class='rightBoarder'><span class='rightBoarder'>%@</span></td><td class='rightBoarder'><span class='rightBoarder'>%@</span></td></tr>", cleanDate, [matchesArray[i-1] valueForKey:@"reps"], [matchesArray[i-1] valueForKey:@"weight"], [matchesArray[i-1] valueForKey:@"notes"]];
    }
    
    // HTML closing tags
    myHTML = [myHTML stringByAppendingString:@"</table></body></html>"];
     
    return myHTML;
}
@end
