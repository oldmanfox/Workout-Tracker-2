//
//  Workout+CoreDataProperties.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 2/13/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var exercise: String?
    @NSManaged public var exerciseCompleted: NSNumber?
    @NSManaged public var index: NSNumber?
    @NSManaged public var month: String?
    @NSManaged public var notes: String?
    @NSManaged public var photo: String?
    @NSManaged public var reps: String?
    @NSManaged public var round: String?
    @NSManaged public var session: String?
    @NSManaged public var week: String?
    @NSManaged public var weekCompleted: NSNumber?
    @NSManaged public var weight: String?
    @NSManaged public var workout: String?

}
