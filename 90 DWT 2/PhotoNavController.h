//
//  PhotoNavController.h
//  i90X 2
//
//  Created by Jared Grant on 6/6/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoNavController : UINavigationController

@property (strong, nonatomic) NSString *phase; // Current phase for pictures.

- (void)saveImage:(UIImage*)image imageName:(NSString*)imageName;
- (UIImage*)loadImage:(NSString*)imageName;
- (void)removeImage:(NSString*)fileName;
- (NSData*)emailImage:(NSString*)imageName;
- (NSString*)fileLocation:(NSString*)imageName;
@end
