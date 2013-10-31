//
//  UIViewController+iAdBanner.m
//  90 DWT 2
//
//  Created by Jared Grant on 10/20/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "UIViewController+iAdBanner.h"

@implementation UIViewController (iAdBanner)

- (CGRect)calculateMainBannerViewDimensions {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //NSLog(@"Screen W = %f", screenWidth);
    //NSLog(@"Screen H = %f", screenHeight);
    
    CGRect newFrame;
    
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        
        // Portrait
        newFrame.size.height = 50;
        newFrame.origin.y = (screenHeight - 49 - 44 - 20 - newFrame.size.height);
        newFrame.size.width = screenWidth;
    }
    
    else
    {
        // Landscape
        newFrame.size.height = 32;
        newFrame.origin.y = (screenWidth - 49 - 32 - 20 - newFrame.size.height);
        newFrame.size.width = screenHeight;
    }
    
    newFrame.origin.x = 0;
    
    //NSLog(@"iAd Banner X = %f", newFrame.origin.x);
    //NSLog(@"iAd Banner Y = %f", newFrame.origin.y);
    //NSLog(@"iAd Banner W = %f", newFrame.size.width);
    //NSLog(@"iAd Banner H = %f", newFrame.size.height);
    
    return newFrame;
}
@end
