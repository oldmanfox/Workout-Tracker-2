//
//  ScatterPlotViewController.h
//  90 DWT 1
//
//  Created by Grant, Jared on 5/8/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CoreData.h"
#import "AppDelegate.h"
#import "DWT2IAPHelper.h"

@interface ScatterPlotViewController : UIViewController <CPTPlotDataSource>

//@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (strong, nonatomic) NSArray *matches;

-(void)initPlot;
@end
