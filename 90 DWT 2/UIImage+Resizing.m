//
//  UIImage+Resizing.m
//  i90X 2
//
//  Created by Jared Grant on 6/15/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "UIImage+Resizing.h"

@implementation UIImage (Resizing)

/**
 * Creates a resized, autoreleased copy of the image, with the given dimensions.
 * @return an autoreleased, resized copy of the image
 */
- (UIImage*) resizedImageWithSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
    
	[self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
	// An autoreleased image
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return newImage;
}
@end
