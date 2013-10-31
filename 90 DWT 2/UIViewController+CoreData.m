//
//  UIViewController+CoreData.m
//  90 DWT 1
//
//  Created by Jared Grant on 5/8/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "UIViewController+CoreData.h"
#import "DataNavController.h"

@implementation UIViewController (CoreData)

- (NSArray *)databaseMatches {
    
    // Get Data from the database.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(workout = %@) AND (exercise = %@) AND (round = %@)",
                         appDelegate.workout,
                         appDelegate.exerciseName,
                         appDelegate.exerciseRound];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    //NSLog(@"Objects = %d", [objects count]);
    
    return objects;
}
@end
