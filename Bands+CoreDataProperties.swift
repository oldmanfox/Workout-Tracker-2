//
//  Bands+CoreDataProperties.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 2/13/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import Foundation
import CoreData


extension Bands {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bands> {
        return NSFetchRequest<Bands>(entityName: "Bands");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var useBands: String?

}
