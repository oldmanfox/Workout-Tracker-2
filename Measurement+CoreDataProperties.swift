//
//  Measurement+CoreDataProperties.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 2/13/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import Foundation
import CoreData


extension Measurement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Measurement> {
        return NSFetchRequest<Measurement>(entityName: "Measurement");
    }

    @NSManaged public var chest: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var hips: String?
    @NSManaged public var leftArm: String?
    @NSManaged public var leftThigh: String?
    @NSManaged public var month: String?
    @NSManaged public var rightArm: String?
    @NSManaged public var rightThigh: String?
    @NSManaged public var session: String?
    @NSManaged public var waist: String?
    @NSManaged public var weight: String?

}
