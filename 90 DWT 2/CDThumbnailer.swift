////
////  CDThumbnailer.swift
////
////  Created by Tim Roadley on 6/10/2015.
////  Copyright © 2015 Tim Roadley. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class CDThumbnailer: NSObject {
//
//    class func createMissingThumbnails(entityName:String, thumbnailAttribute:String, photoRelationship:String, photoAttribute:String, sort:[NSSortDescriptor]?, size:CGSize, moc:NSManagedObjectContext) {
//    
//        moc.performBlock {
//        
//            let filter = NSPredicate(format: "%K==nil && %K.%K!=nil", thumbnailAttribute, photoRelationship, photoAttribute)
//    
//            if let objects = CDOperation.objectsForEntity(entityName, context: moc, filter: filter, sort: sort) as? [NSManagedObject] {
//                for object in objects { 
//                    if object.valueForKey(thumbnailAttribute) == nil {
//                        if let objectName = object.valueForKey("name") as? String,
//                            let photoObject = object.valueForKey(photoRelationship) as? NSManagedObject,
//                            let photoData = photoObject.valueForKey(photoAttribute) as? NSData,
//                            let photo = UIImage(data: photoData) {
//                        
//                        print("Creating thumbnail for object with name '\(objectName)'")
//                            
//                        // Create thumbnail
//                        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
//                        photo.drawInRect(CGRectMake(0, 0, size.width, size.height))
//                        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
//                        UIGraphicsEndImageContext()
//                        object.setValue(UIImageJPEGRepresentation(thumbnail, 0.5), forKey: thumbnailAttribute)
//                        
//                        // Fault objects out of memory
//                        CDFaulter.faultObject(photoObject, moc: moc)
//                        CDFaulter.faultObject(object, moc: moc)
//                        
//                        } else {print("\(#function) failed to prepare the thumbnail attribute object")}
//                    }
//                }
//            }
//        }
//    }
//}
