////
////  CDDeduplicator.swift
////
////  Created by Tim Roadley on 7/10/2015.
////  Copyright © 2015 Tim Roadley. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class CDDeduplicator: NSObject {
//   
//    class func duplicatesForEntityWithName (entityName:String, uniqueAttributeName:String, moc:NSManagedObjectContext) -> [AnyObject]? {
//        
//        if let psc = moc.persistentStoreCoordinator  {
//
//            // GET UNIQUE ATTRIBUTE
//            let allEntities = psc.managedObjectModel.entitiesByName
//            if let uniqueAttribute = allEntities[entityName]?.propertiesByName[uniqueAttributeName] as? NSAttributeDescription {
//
//                // CREATE COUNT EXPRESSION
//                let countExpression = NSExpressionDescription()
//                countExpression.name = "count"
//                countExpression.expression = NSExpression(format: "count:(%K)", uniqueAttributeName)
//                countExpression.expressionResultType = NSAttributeType.Integer64AttributeType
//                
//                // CREATE AN ARRAY OF *UNIQUE* ATTRIBUTE VALUES
//                let request = NSFetchRequest(entityName:entityName)
//                request.includesPendingChanges = false
//                request.fetchBatchSize = 100
//                request.propertiesToFetch = [uniqueAttribute, countExpression]
//                request.propertiesToGroupBy = [uniqueAttribute]
//                request.resultType = NSFetchRequestResultType.DictionaryResultType
//                
//                // RETURN AN ARRAY OF *DUPLICATE* ATTRIBUTE VALUES                
//                do {
//                    let fetchResults = try moc.executeFetchRequest(request)
//
//                    var duplicates:[String] = []
//                    if let duplicatesDictionaryArray = fetchResults as? [Dictionary<String, AnyObject>] {
//                        for duplicatesDictionary:Dictionary<String, AnyObject> in duplicatesDictionaryArray {
//                            if let instanceCount = duplicatesDictionary["count"] as? Int {
//                                if instanceCount > 1 {
//                                    if let instanceName = duplicatesDictionary[uniqueAttributeName] as? String {
//                                        duplicates.append(instanceName)
//                                    } else {print("\(#function) FAILED to prepare instanceName")}
//                                }
//                            } else {print("\(#function) FAILED to prepare instanceCount")}
//                        }
//                    } else {print("\(#function) FAILED to prepare duplicatesDictionaryArray")}
//                    if duplicates.count > 0 {
//                        print("FOUND DUPLICATES: \(duplicates)")
//                        return duplicates
//                    }
//                } catch {
//                    print("\(#function) FAILED to fetch objects: \(error)")}
//            } else {print("\(#function) FAILED to prepare uniqueAttribute")}
//        } else {print("\(#function) FAILED to get persistentStoreCoordinator from moc")}
//        return nil
//    }
//    class func deDuplicateEntityWithName (entityName:String, uniqueAttributeName:String, backgroundMoc moc:NSManagedObjectContext) {
//            
//        moc.performBlock {
//            
//            if let duplicates = CDDeduplicator.duplicatesForEntityWithName(entityName, uniqueAttributeName: uniqueAttributeName, moc: moc) as? [String] {
//            
//                // FETCH DUPLICATE OBJECTS
//                let filter = NSPredicate(format:"%K IN (%@)", uniqueAttributeName,duplicates)
//                let sort = [NSSortDescriptor(key:uniqueAttributeName, ascending:true)]
//                if let duplicateObjects = CDOperation.objectsForEntity(entityName, context: moc, filter: filter, sort: sort) as? [NSManagedObject] {
//            
//                    var _lastObject:NSManagedObject?
//                    for object in duplicateObjects {
//            
//                        // DELETE DUPLICATE OBJECTS
//                        if let lastObject = _lastObject {
//                            if object.valueForKey(uniqueAttributeName) as? String == lastObject.valueForKey(uniqueAttributeName) as? String {
//            
//                                // DE-DUPLICATE LOCATIONS 
//                                /*
//                                    This Groceries specific code is not required in your application.
//                                    Add your own deduplication logic here.
//                                    Read "Learning Core Data with Swift for iOS" by Tim Roadley for full details.
//                                */
//                                //if LocationAtHome.deduplicate(objectA:object, objectB: lastObject) {return}
//                                //if LocationAtShop.deduplicate(objectA:object, objectB: lastObject) {return}
//                                
//                                // DELETION LOGIC
//                                if let date1 = object.valueForKey("modified") as? NSDate {
//                                    if let date2 = lastObject.valueForKey("modified") as? NSDate {
//                                                
//                                        // DELETE OLDEST DUPLICATE...
//                                        if date1.compare(date2) == NSComparisonResult.OrderedAscending {
//                                          print("De-duplicating \(entityName) '\(object.valueForKey(uniqueAttributeName)!)'")
//                                          CDCloudSync.shared.setCacheStatusForObject(object, requestedStatus: DELETING)
//                                        } else if date1.compare(date2) == NSComparisonResult.OrderedDescending {
//                                          print("De-duplicating \(entityName) '\(object.valueForKey(uniqueAttributeName)!)'")
//                                          CDCloudSync.shared.setCacheStatusForObject(object, requestedStatus: DELETING)
//                                        }
//                                                        
//                                        // ..or.. DELETE DUPLICATE WITH LESS ATTRIBUTE VALUES (if dates match)
//                                        else if object.committedValuesForKeys(nil).count > lastObject.committedValuesForKeys(nil).count {
//                                          print("De-duplicating \(entityName) '\(object.valueForKey(uniqueAttributeName)!)'")
//                                          CDCloudSync.shared.setCacheStatusForObject(object, requestedStatus: DELETING)
//                                        } else if object.committedValuesForKeys(nil).count < lastObject.committedValuesForKeys(nil).count{
//                                          print("De-duplicating \(entityName) '\(object.valueForKey(uniqueAttributeName)!)'")
//                                          CDCloudSync.shared.setCacheStatusForObject(object, requestedStatus: DELETING)
//                                        } else {
//                                          print("Skipped De-duplication, dates and value counts match")
//                                        }
//                                        CDHelper.save(moc)
//                                    }
//                                }
//                            }
//                        } 
//                        _lastObject = object
//                    }
//                    for object in duplicateObjects {
//                        CDFaulter.faultObject(object, moc: moc)
//                    }
//                }
//            }
//        }
//    }
//    
//}
