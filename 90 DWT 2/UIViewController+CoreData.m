//
//  UIViewController+CoreData.m
//  90 DWT 1
//
//  Created by Jared Grant on 5/8/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "UIViewController+CoreData.h"
#import "DataNavController.h"
#import "CoreDataHelper.h"

@implementation UIViewController (CoreData)

- (NSArray *)databaseMatches {
    
    // Get Data from the database.
    // Get the objects for the current session
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Fetch current session data.
    NSString *currentSessionString = [mainAppDelegate getCurrentSession];
    
    // Get workout data using the current session
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (exercise = %@) AND (round = %@)",
                         currentSessionString,
                         mainAppDelegate.workout,
                         mainAppDelegate.exerciseName,
                         mainAppDelegate.exerciseRound];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    //NSLog(@"Objects = %lu", (unsigned long)[objects count]);
    
    // Get a list of sorted unique indexes
    NSArray *sortedArray = [self findSortedIndexes:objects];
    
    // Get the last object per index.  That would be the most recently inserted record.
    NSArray *lastObjectForIndexArray = [self findLastObjectForIndex:sortedArray];
    
    return lastObjectForIndexArray;
}

- (NSArray *)findSortedIndexes:(NSArray *)objectArray {
    
    NSArray *tempObjectArray = objectArray;
    
    NSArray* uniqueValues = [tempObjectArray valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", @"index"]];
    //NSLog(@"%@", uniqueValues);
    
    NSArray *sortedIndex = [uniqueValues sortedArrayUsingComparator:
                            ^NSComparisonResult(id obj1, id obj2) {
                                if ([obj1 integerValue] < [obj2 integerValue]) {
                                    return NSOrderedAscending;
                                } else if ([obj1 integerValue] > [obj2 integerValue]) {
                                    return NSOrderedDescending;
                                } else {
                                    return NSOrderedSame;
                                }
                            }];
    //NSLog(@"%@", sortedIndex);
    
    return sortedIndex;
}

- (NSArray *)findLastObjectForIndex:(NSArray *)indexArray {
    
    NSArray *tempIndexArray = indexArray;
    NSMutableArray *lastObjectForIndexArray = [[NSMutableArray alloc] init];
    
    // Get Data from the database.
    // Get the objects for the current session
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    AppDelegate *mainAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Fetch current session data.
    NSString *currentSessionString = [mainAppDelegate getCurrentSession];
    
    // Get workout data using the current session
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    for (int i = 0; i < tempIndexArray.count; i++) {
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(session = %@) AND (workout = %@) AND (exercise = %@) AND (round = %@) AND (index = %d)",
                             currentSessionString,
                             mainAppDelegate.workout,
                             mainAppDelegate.exerciseName,
                             mainAppDelegate.exerciseRound,
                             [tempIndexArray[i] integerValue] ];
        [request setPredicate:pred];
        
        NSManagedObject *lastObject = nil;
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        lastObject = [objects lastObject];
        [lastObjectForIndexArray addObject:lastObject];
    }
    
    //NSLog(@"Objects = %lu", (unsigned long)[lastObjectForIndexArray count]);
    
    NSArray *objects = lastObjectForIndexArray;
    return objects;
}
@end
