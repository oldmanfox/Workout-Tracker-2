//
//  MainTBC.m
//  90 DWT 2
//
//  Created by Grant, Jared on 3/11/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "MainTBC.h"

@interface MainTBC ()

@end

@implementation MainTBC

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
    
    [self readBandSetting];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readBandSetting {
    
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *defaultWorkoutFile = nil;
    defaultWorkoutFile = [docDir stringByAppendingPathComponent:@"Band Setting.out"];
    
    if  ([[NSFileManager defaultManager] fileExistsAtPath:defaultWorkoutFile]) {
        
        // File has already been created. Get value of routine from it.
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultWorkoutFile];
        self.bandSetting = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
    }
    
    else {
        
        // File has not been created so this is the first time the app has been opened or user has not changed band setting.
        self.bandSetting = @"OFF";  // NOT using bands.
    }
    
    //NSLog(@"BandSetting = %@", self.bandSetting);
}
@end
