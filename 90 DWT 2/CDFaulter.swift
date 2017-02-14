////
////  CDFaulter.swift
////
////  Created by Tim Roadley on 6/10/2015.
////  Copyright © 2015 Tim Roadley. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class CDFaulter: NSObject {
//   
//    class func faultObject (object:NSManagedObject, moc:NSManagedObjectContext) {
//    
//        moc.performBlockAndWait {
//            
//            if object.hasChanges {
//                CDHelper.save(moc)
//            }
//                
//            if object.fault == false {
//                moc.refreshObject(object, mergeChanges: false)
//            }
//                
//            if let parentMoc = moc.parentContext {
//                CDFaulter.faultObject(object, moc:parentMoc)
//            }
//        }
//    }
//}
