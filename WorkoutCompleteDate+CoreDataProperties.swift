//
//  WorkoutCompleteDate+CoreDataProperties.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 2/13/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import Foundation
import CoreData


extension WorkoutCompleteDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutCompleteDate> {
        return NSFetchRequest<WorkoutCompleteDate>(entityName: "WorkoutCompleteDate");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var index: NSNumber?
    @NSManaged public var session: String?
    @NSManaged public var workout: String?
    @NSManaged public var workoutCompleted: NSNumber?

}
