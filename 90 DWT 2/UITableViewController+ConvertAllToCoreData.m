//
//  UITableViewController+ConvertAllToCoreData.m
//  90 DWT 1
//
//  Created by Grant, Jared on 12/1/15.
//  Copyright © 2015 Grant, Jared. All rights reserved.
//

#import "UITableViewController+ConvertAllToCoreData.h"

@implementation UITableViewController (ConvertAllToCoreData)

#define debug 0

- (void)convertPhotosToCoreData {
    
    NSMutableArray *cdMonths = [[NSMutableArray alloc] init];
    NSMutableArray *cdAngles = [[NSMutableArray alloc] init];
    NSMutableArray *cdImages = [[NSMutableArray alloc] init];
    
    // Find the location of the image files
    NSArray *monthNames = @[@"Start Month 1",
                            @"Start Month 2",
                            @"Start Month 3",
                            @"Final"];

    NSArray *photoAngle = @[@"Front",
                            @"Side",
                            @"Back"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = paths[0];
    
    // Get photos from the documents directory
    for (int i = 0; i < monthNames.count; i++) {

        for (int j = 0; j < photoAngle.count; j++) {
            
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %@.JPG", monthNames[i], photoAngle[j]]];
            
            if ([fileManager fileExistsAtPath: fullPath]) {
                
                // Add image and month and angle to arrays to store later in core data
                [cdMonths addObject:[NSString stringWithFormat:@"%i", i+1]];
                [cdAngles addObject:photoAngle[j]];
                [cdImages addObject:[NSData dataWithContentsOfFile:fullPath]];
            }
        }
    }
    
    // Add Photos to core data with session 1
    NSDate *todaysDate = [NSDate date];
    
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects.count == 0) {
        
        //NSLog(@"submitEntry = No matches - create new record and save");
        
        for (int i = 0; i < cdImages.count; i++) {
            
            NSManagedObject *newPhoto;
            newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];

            [newPhoto setValue:@"1" forKey:@"session"];
            [newPhoto setValue:cdMonths[i] forKey:@"month"];
            [newPhoto setValue:cdAngles[i] forKey:@"angle"];
            [newPhoto setValue:todaysDate forKey:@"date"];
            [newPhoto setValue:cdImages[i] forKey:@"image"];
            
            if (debug==1) {
                NSLog(@"Add Photo To CD %@ - %@", cdMonths[i], cdAngles[i]);
            }
        }
        
        [[CoreDataHelper sharedHelper] backgroundSaveContext];
    }
    
    // Delete photos from the file directory.  Not used anymore.
    for (int i = 0; i < monthNames.count; i++) {
        
        for (int j = 0; j < photoAngle.count; j++) {
            
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %@.JPG", monthNames[i], photoAngle[j]]];
            
            if ([fileManager fileExistsAtPath: fullPath]) {
                
                // Delete image at filepath.
                NSError *error;
                [fileManager removeItemAtPath: fullPath error:&error];
                if (error){
                    NSLog(@"%@", error);
                }
                else {
                    if (debug==1) {
                        NSLog(@"Removed Photo From Documents Directory %@ - %@", [NSString stringWithFormat:@"%i", i+1], photoAngle[j]);
                    }
                }
            }
        }
    }
}

- (void)convertMeasurementsToCoreData {
    
    NSMutableArray *cdMonth = [[NSMutableArray alloc] init];
    NSMutableArray *cdWeight = [[NSMutableArray alloc] init];
    NSMutableArray *cdChest = [[NSMutableArray alloc] init];
    NSMutableArray *cdLeftArm = [[NSMutableArray alloc] init];
    NSMutableArray *cdRightArm = [[NSMutableArray alloc] init];
    NSMutableArray *cdWaist = [[NSMutableArray alloc] init];
    NSMutableArray *cdHips = [[NSMutableArray alloc] init];
    NSMutableArray *cdLeftThigh = [[NSMutableArray alloc] init];
    NSMutableArray *cdRightThigh = [[NSMutableArray alloc] init];
    
    NSDictionary *measurementsDictonary;
    
    // Find the location of the measurement files
    NSArray *monthNames = @[@"Start Month 1",
                            @"Start Month 2",
                            @"Start Month 3",
                            @"Final"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it

    NSString *documentsDirectory = paths[0]; //create NSString object, that holds our exact path to the documents directory
    
    // Get measurements from the documents directory
    for (int i = 0; i < monthNames.count; i++) {
        
         NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Measurements.out", monthNames[i]]];
            
            if ([fileManager fileExistsAtPath: fullPath]) {
                
                // Read back in new collection
                measurementsDictonary = nil;
                measurementsDictonary = [NSDictionary dictionaryWithContentsOfFile:fullPath];
                
                // Add data to Arrays to store later in core data
                [cdMonth addObject:[NSString stringWithFormat:@"%i", i+1]];
                [cdWeight addObject:measurementsDictonary[@"Weight"]];
                [cdChest addObject:measurementsDictonary[@"Chest"]];
                [cdLeftArm addObject:measurementsDictonary[@"Left Arm"]];
                [cdRightArm addObject:measurementsDictonary[@"Right Arm"]];
                [cdWaist addObject:measurementsDictonary[@"Waist"]];
                [cdHips addObject:measurementsDictonary[@"Hips"]];
                [cdLeftThigh addObject:measurementsDictonary[@"Left Thigh"]];
                [cdRightThigh addObject:measurementsDictonary[@"Right Thigh"]];
            }
    }

    // Add Measurements to core data with session 1
    NSDate *todaysDate = [NSDate date];
    
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects.count == 0) {
        
        //NSLog(@"submitEntry = No matches - create new record and save");
        
        for (int i = 0; i < cdMonth.count; i++) {
            
            NSManagedObject *newMeasurement;
            newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:context];
            
            [newMeasurement setValue:@"1" forKey:@"session"];
            [newMeasurement setValue:cdMonth[i] forKey:@"month"];
            [newMeasurement setValue:todaysDate forKey:@"date"];
            [newMeasurement setValue:cdWeight[i] forKey:@"weight"];
            [newMeasurement setValue:cdChest[i] forKey:@"chest"];
            [newMeasurement setValue:cdWaist[i] forKey:@"waist"];
            [newMeasurement setValue:cdHips[i] forKey:@"hips"];
            [newMeasurement setValue:cdLeftArm[i] forKey:@"leftArm"];
            [newMeasurement setValue:cdRightArm[i] forKey:@"rightArm"];
            [newMeasurement setValue:cdLeftThigh[i] forKey:@"leftThigh"];
            [newMeasurement setValue:cdRightThigh[i] forKey:@"rightThigh"];
            
            if (debug==1) {
                NSLog(@"Add Measurement To CD Month - %@", cdMonth[i]);
            }
        }
        
        [[CoreDataHelper sharedHelper] backgroundSaveContext];
    }
    
    // Delete measurements from the documents directory.  Not used anymore.
    for (int i = 0; i < monthNames.count; i++) {
        
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Measurements.out", monthNames[i]]];
        
        if ([fileManager fileExistsAtPath: fullPath]) {
            
            // Delete measurement at filepath.
            NSError *error;
            [fileManager removeItemAtPath: fullPath error:&error];
            if (error){
                NSLog(@"%@", error);
            }
            else {
                if (debug==1) {
                    NSLog(@"Removed Measurement From Documents Directory Month - %@", [NSString stringWithFormat:@"%i", i+1]);
                }
            }
        }
    }
}

- (void)convertSettingsToCoreData {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // EMAIL
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    // Email File
    NSString *defaultEmailFile = nil;
    defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];
    
    if  ([fileManager fileExistsAtPath:defaultEmailFile]) {
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultEmailFile];
        NSString *defaultEmailAddress = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
        
        // Add defaultEmail to core data
        NSDate *todaysDate = [NSDate date];
        
        NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Email" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if (objects.count == 0) {
            
            if (debug==1) {
                NSLog(@"No matches - create new record and save - Email");
            }
            
            NSManagedObject *newEmail;
            newEmail = [NSEntityDescription insertNewObjectForEntityForName:@"Email" inManagedObjectContext:context];
            [newEmail setValue:defaultEmailAddress forKey:@"defaultEmail"];
            [newEmail setValue:todaysDate forKey:@"date"];
            
            [[CoreDataHelper sharedHelper] backgroundSaveContext];
        }
    }

    // DELETE
    // Delete email file from the documents directory.  Not used anymore.
    // Email File
    defaultEmailFile = nil;
    defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];
    
    if  ([fileManager fileExistsAtPath:defaultEmailFile]) {
        
        // Delete email at filepath.
        NSError *error;
        [fileManager removeItemAtPath: defaultEmailFile error:&error];
        if (error){
            NSLog(@"%@", error);
        }
        else {
            if (debug==1) {
                NSLog(@"Removed Email File From Documents Directory");
            }
        }
    }
}

- (void)addSession1ToExistingCoreDataObjects {
    
    //Set any objects in Core Data that don't have a session assigned to them to session 1
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    int objectsUpdatedCount = 0;
    
    for (Workout *info in objects) {
        
        NSString *sessionValue = info.session;
        
        if (sessionValue == nil) {
            
            info.session = @"1";
            objectsUpdatedCount++;
        }
    }
    
    if (objectsUpdatedCount != 0) {
        
        if (debug==1) {
            NSLog(@"ObjectsUpdatedCount = %d", objectsUpdatedCount);
        }
        
        [[CoreDataHelper sharedHelper] backgroundSaveContext];
    }
}
@end
