////
////  CDImporter.swift
////  Groceries
////
////  Created by Tim Roadley on 5/10/2015.
////  Copyright © 2015 Tim Roadley. All rights reserved.
////
//
//import Foundation
//import CoreData
//import UIKit
//
//private let _sharedCDImporter = CDImporter()
//class CDImporter : NSObject, NSXMLParserDelegate {
//
//    // MARK: - SHARED INSTANCE
//    class var shared : CDImporter {
//        return _sharedCDImporter
//    }
//    
//    // MARK: - DATA IMPORT
//    class func isDefaultDataAlreadyImportedForStoreWithURL (url:NSURL, type:String) -> Bool {
//        
//        do {
//            var metadata:[String : AnyObject]?
//            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: url, options: nil)
//            if let dictionary = metadata {
//                
//                if let defaultDataAlreadyImported = dictionary["DefaultDataImported"] as? NSNumber {
//                    if defaultDataAlreadyImported.boolValue == false {
//                        print("Default Data has not been imported yet")
//                        return false
//                    } else {
//                        print("Default Data import is not required")
//                        return true
//                    }
//                } else {
//                    print("Default Data has not been imported yet")
//                    return false
//                }
//            } else {print("\(#function) FAILED to get metadata")}
//        } catch {
//            print("ERROR getting metadata from \(url) \(error)")
//        }
//        return true // default to true to prevent a default data import when an error occurs
//    }  
//    func checkIfDefaultDataNeedsImporting (url:NSURL, type:String) {
//        if CDImporter.isDefaultDataAlreadyImportedForStoreWithURL(url, type: type) == false {
//
//            let alert = UIAlertController(title: "Import Default Data?", message: "If you've never used this application before then some default data might help you understand how to use it. Tap 'Import' to import default data. Tap 'Cancel' to skip the import, especially if you've done this before on your other devices.", preferredStyle: .Alert)
//
//            let importButton = UIAlertAction(title: "Import", style: .Destructive, handler: { (action) -> Void in
//                
//                // Import data
//                if let url = NSBundle.mainBundle().URLForResource("DefaultData", withExtension: "xml") {
//                    
//                    CDHelper.shared.importContext.performBlock {
//                        print("Attempting DefaultData.xml Import...")
//                        self.importFromXML(url)
//                        //print("Attempting DefaultData.sqlite Import...")
//                        //CDImporter.triggerDeepCopy(CDHelper.shared.sourceContext, targetContext: CDHelper.shared.importContext, mainContext: CDHelper.shared.context)
//                    }
//                } else {print("DefaultData.xml not found")}
//                
//                // Set the data as imported
//                if let store = CDHelper.shared.localStore {
//                    self.setDefaultDataAsImportedForStore(store)
//                }
//            })
//
//            let skipButton = UIAlertAction(title: "Skip", style: .Default, handler: { (action) -> Void in
//        
//                // Set the data as imported
//                if let store = CDHelper.shared.localStore {
//                    self.setDefaultDataAsImportedForStore(store)
//                }            
//            })
//            alert.addAction(importButton)
//            alert.addAction(skipButton)
//
//            // PRESENT
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                if let initialVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
//                    initialVC.presentViewController(alert, animated: true, completion: nil)
//                } else {NSLog("ERROR getting the initial view controller in %@",#function)}
//            })
//        }  
//    }
//    func setDefaultDataAsImportedForStore (store:NSPersistentStore) {
//
//        if let coordinator = store.persistentStoreCoordinator {
//            var metadata = store.metadata
//            metadata["DefaultDataImported"] = NSNumber(bool: true)
//            coordinator.setMetadata(metadata, forPersistentStore: store)
//            print("Store metadata after setDefaultDataAsImportedForStore \(store.metadata)")
//        }
//    }
//    
//    // MARK: - XML PARSER
//    var parser:NSXMLParser?
//    func importFromXML (url:NSURL) {
//            
//        self.parser = NSXMLParser(contentsOfURL: url)
//        if let _parser = self.parser {
//            _parser.delegate = self
//                
//            NSLog("START PARSE OF %@",url)
//            _parser.parse()
//            NSNotificationCenter.defaultCenter().postNotificationName("SomethingChanged", object: nil)
//            NSLog("END PARSE OF %@",url)
//        }
//    }     
//    
//    // MARK: - DELEGATE: NSXMLParser
//    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
//        NSLog("ERROR PARSING: %@",parseError.localizedDescription)
//    }
//    // NOTE: - The code in the didStartElement function is customized for 'Groceries'
////    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
////            
////        let importContext = CDHelper.shared.importContext
////        importContext.performBlockAndWait {
////     
////            // Process only the 'Item' element in the XML file
////            if elementName == "Item" {
////                    
////                // STEP 1a: Insert a unique 'Item' object
////                var item:Item?
////                if let itemName = attributeDict["name"] {
////                    item = CDOperation.insertUniqueObject("Item", context: importContext, uniqueAttributes: ["name":itemName], additionalAttributes: nil) as? Item
////                    if let _item = item {_item.name = itemName}
////                }
////                    
////                // STEP 1b: Insert a unique 'Unit' object
////                var unit:Unit?
////                if let unitName = attributeDict["unit"] {
////                    unit = CDOperation.insertUniqueObject("Unit", context: importContext, uniqueAttributes: ["name":unitName], additionalAttributes: nil) as? Unit
////                    if let _unit = unit {_unit.name = unitName}
////                }
////                    
////                // STEP 1c: Insert a unique 'LocationAtHome' object
////                var locationAtHome:LocationAtHome?
////                if let storedIn = attributeDict["locationAtHome"] {
////                    locationAtHome = CDOperation.insertUniqueObject("LocationAtHome", context: importContext, uniqueAttributes: ["storedIn":storedIn], additionalAttributes: nil) as? LocationAtHome
////                    if let _locationAtHome = locationAtHome {_locationAtHome.storedIn = storedIn}
////                }
////                    
////                // STEP 1d: Insert a unique 'LocationAtShop' object
////                var locationAtShop:LocationAtShop?
////                if let aisle = attributeDict["locationAtShop"] {
////                    locationAtShop = CDOperation.insertUniqueObject("LocationAtShop", context: importContext, uniqueAttributes: ["aisle":aisle], additionalAttributes: nil) as? LocationAtShop
////                    if let _locationAtShop = locationAtShop {_locationAtShop.aisle = aisle}
////                }
////                    
////                // STEP 2: Manually add extra attribute values.
////                if let _item = item {_item.listed = NSNumber(bool: false)}
////                    
////                // STEP 3: Create relationships
////                if let _item = item {
////                        
////                    _item.unit = unit
////                    _item.locationAtHome = locationAtHome
////                    _item.locationAtShop = locationAtShop
////                }
////                    
////                // STEP 4: Save new objects to the persistent store.
////                CDHelper.save(importContext)
////                    
////                // STEP 5: Turn objects into faults to save memory
////                if let _item = item { CDFaulter.faultObject(_item, moc: importContext)}
////                if let _unit = unit { CDFaulter.faultObject(_unit, moc: importContext)}
////                if let _locationAtHome = locationAtHome { CDFaulter.faultObject(_locationAtHome, moc: importContext)}
////                if let _locationAtShop = locationAtShop { CDFaulter.faultObject(_locationAtShop, moc: importContext)}
////            }
////        }
////    }
//    
//    // MARK: - DEEP COPY
//    class func selectedUniqueAttributesForEntity (entityName:String) -> [String]? {
//        
//        // Return an array of attribute names to be considered unique for an entity.
//        // Multiple unique attributes are supported.
//        // Only use attributes whose values are alphanumeric.
//            
//        switch (entityName) {
//            case "AutoLock"             :return ["date"]
//            case "Email"                :return ["date"]
//            case "Measurement"          :return ["date"]
//            case "Photo"                :return ["date"]
//            case "Routine"              :return ["date"]
//            case "Session"              :return ["date"]
//            case "Workout"              :return ["date"]
//            case "WorkoutCompleteDate"  :return ["date"]
//            
//            default:
//                break;
//        }
//        return nil
//    }
//    class func objectInfo (object:NSManagedObject) -> String {
//        
//        if let entityName = object.entity.name {
//
//            var attributes:NSString = ""
//                
//            if let uniqueAttributes = CDImporter.selectedUniqueAttributesForEntity(entityName) {
//                    
//                for attribute in uniqueAttributes {
//                    if let valueForKey = object.valueForKey(attribute) as? NSObject {
//                        attributes = "\(attributes)\(attribute) \(valueForKey) "
//                    }
//                }
//                    
//                // trim trailing space
//                attributes = attributes.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//                    
//                return "\(entityName) with \(attributes)"
//            } else {print("ERROR: \(#function) could not find any uniqueAttributes")}
//        } else {print("ERROR: \(#function) could not find an entityName")}
//        return ""
//    }
//    class func copyUniqueObject (sourceObject:NSManagedObject, targetContext:NSManagedObjectContext) -> NSManagedObject? {
//            
//        if let entityName = sourceObject.entity.name {
//                
//            if let uniqueAttributes = CDImporter.selectedUniqueAttributesForEntity(entityName) {
//
//                // PREPARE unique attributes to copy
//                var uniqueAttributesFromSource:[String:AnyObject] = [:]
//                for uniqueAttribute in uniqueAttributes {
//                    uniqueAttributesFromSource[uniqueAttribute] = sourceObject.valueForKey(uniqueAttribute)
//                }
//            
//                // PREPARE additional attributes to copy
//                var additionalAttributesFromSource:[String:AnyObject] = [:]
//                if let attributesByName:[String:AnyObject] = sourceObject.entity.attributesByName {
//                    for (additionalAttribute, _) in attributesByName {
//                        additionalAttributesFromSource[additionalAttribute] = sourceObject.valueForKey(additionalAttribute)
//                    }
//                }
//            
//                // COPY attributes to new object
//                let copiedObject = CDOperation.insertUniqueObject(entityName, context: targetContext, uniqueAttributes: uniqueAttributesFromSource, additionalAttributes: additionalAttributesFromSource)
//
//                // Update modified date as appropriate
//                for (additionalAttribute, _) in sourceObject.entity.attributesByName {
//                    if additionalAttribute == "modified" {
//                    copiedObject.setValue(NSDate(timeIntervalSinceNow: -999999999), forKey: "modified")
//                    }
//                }
//                
//                return copiedObject
//            } else {print("ERROR: \(#function) could not find any selected unique attributes for the '\(entityName)' entity")}
//        } else {print("ERROR: \(#function) could not find an entity name for the given object '\(sourceObject)'")}
//        return nil
//    }
//    class func establishToOneRelationship (relationshipName:String,from object:NSManagedObject, to relatedObject:NSManagedObject) {
//            
//        // SKIP establishing an existing relationship
//        if object.valueForKey(relationshipName) != nil {
//            print("SKIPPED \(#function) because the relationship already exists")
//            return
//        }
//            
//        if let targetContext = object.managedObjectContext {
//                
//            // ESTABLISH the relationship
//            object.setValue(relatedObject, forKey: relationshipName)
//            print("    A copy of \(CDImporter.objectInfo(object)) is related via To-One \(relationshipName) relationship to \(CDImporter.objectInfo(relatedObject))")
//                
//            // REMOVE the relationship from memory after it is committed to disk
//            CDHelper.save(targetContext)
//            targetContext.refreshObject(object, mergeChanges: false)
//            targetContext.refreshObject(relatedObject, mergeChanges: false)
//        } else {print("ERROR: \(#function) could not get a targetContext")}
//    }
//    class func establishToManyRelationship (relationshipName:String,from object:NSManagedObject, sourceSet:NSMutableSet) {
//            
//        // SKIP establishing an existing relationship
//        if object.valueForKey(relationshipName) != nil {
//            print("SKIPPED \(#function) because the relationship already exists")
//            return
//        }
//
//        if let targetContext = object.managedObjectContext {
//             
//            let targetSet = object.mutableSetValueForKey(relationshipName)
//                
//            targetSet.enumerateObjectsUsingBlock({ (relatedObject, stop) -> Void in
//                    
//                if let theRelatedObject = relatedObject as? NSManagedObject {
//                     
//                    if let copiedRelatedObject = CDImporter.copyUniqueObject(theRelatedObject, targetContext: targetContext) {
//                         
//                        targetSet.addObject(copiedRelatedObject)
//                        print("    A copy of \(CDImporter.objectInfo(object)) is related via To-Many \(relationshipName) relationship to \(CDImporter.objectInfo(copiedRelatedObject))")
//                            
//                        // REMOVE the relationship from memory after it is committed to disk
//                        CDHelper.save(targetContext)
//                        targetContext.refreshObject(object, mergeChanges: false)
//                        targetContext.refreshObject(theRelatedObject, mergeChanges: false)
//                    } else {print("ERROR: \(#function) could not get a copiedRelatedObject")}
//                } else {print("ERROR: \(#function) could not get theRelatedObject")}
//            })
//        } else {print("ERROR: \(#function) could not get a targetContext")}
//    } 
//    class func establishOrderedToManyRelationship (relationshipName:String,from object:NSManagedObject, sourceSet:NSMutableOrderedSet) {
//
//        // SKIP establishing an existing relationship
//        if object.valueForKey(relationshipName) != nil {
//            print("SKIPPED \(#function) because the relationship already exists")
//            return
//        }
//            
//        if let targetContext = object.managedObjectContext {
//                
//            let targetSet = object.mutableOrderedSetValueForKey(relationshipName)
//               
//            targetSet.enumerateObjectsUsingBlock { (relatedObject, index, stop) -> Void in
//
//                if let theRelatedObject = relatedObject as? NSManagedObject {
//                    
//                    if let copiedRelatedObject = CDImporter.copyUniqueObject(theRelatedObject, targetContext: targetContext) {
//                            
//                        targetSet.addObject(copiedRelatedObject)
//                        print("    A copy of \(CDImporter.objectInfo(object)) is related via Ordered To-Many \(relationshipName) relationship to \(CDImporter.objectInfo(copiedRelatedObject))'")
//                            
//                        // REMOVE the relationship from memory after it is committed to disk
//                        CDHelper.save(targetContext)
//                        targetContext.refreshObject(object, mergeChanges: false)
//                        targetContext.refreshObject(theRelatedObject, mergeChanges: false)
//                    } else {print("ERROR: \(#function) could not get a copiedRelatedObject")}
//                } else {print("ERROR: \(#function) could not get theRelatedObject")}
//            }
//        } else {print("ERROR: \(#function) could not get a targetContext")}
//    }
//    class func copyRelationshipsFromObject(sourceObject:NSManagedObject, to targetContext:NSManagedObjectContext) {
//            
//        if let copiedObject = CDImporter.copyUniqueObject(sourceObject, targetContext: targetContext) {
//                
//            let relationships = sourceObject.entity.relationshipsByName // [String : NSRelationshipDescription]
//                
//            for (_, relationship) in relationships {
//            
//                if relationship.toMany && relationship.ordered {
//                        
//                    // COPY To-Many Ordered Relationship
//                    let sourceSet = sourceObject.mutableOrderedSetValueForKey(relationship.name)
//                    CDImporter.establishOrderedToManyRelationship(relationship.name, from: copiedObject, sourceSet: sourceSet)
//                        
//                } else if relationship.toMany && relationship.ordered == false {
//                        
//                    // COPY To-Many Relationship
//                    let sourceSet = sourceObject.mutableSetValueForKey(relationship.name)
//                    CDImporter.establishToManyRelationship(relationship.name, from: copiedObject, sourceSet: sourceSet)
//                        
//                } else {
//                        
//                    // COPY To-One Relationship
//                    if let relatedSourceObject = sourceObject.valueForKey(relationship.name) as? NSManagedObject {
//                            
//                        if let relatedCopiedObject = CDImporter.copyUniqueObject(relatedSourceObject, targetContext: targetContext) {
//                                
//                            CDImporter.establishToOneRelationship(relationship.name, from: copiedObject, to: relatedCopiedObject)
//                                
//                        } else {print("ERROR: \(#function) could not get a relatedCopiedObject")}
//                    } else {print("ERROR: \(#function) could not get a relatedSourceObject")}
//                }
//            }
//        } else {print("ERROR: \(#function) could not find or create an object to copy relationships to.")}
//    }
//    class func deepCopyEntities(entities:[String], from sourceContext:NSManagedObjectContext, to targetContext:NSManagedObjectContext) {
//            
//        for entityName in entities {
//            print("DEEP COPYING '\(entityName)' objects to target context...")
//            if let sourceObjects = CDOperation.objectsForEntity(entityName, context: sourceContext, filter: nil, sort: nil) as? [NSManagedObject] {
//                    
//                for sourceObject in sourceObjects {
//                     print("DEEP COPYING OBJECT: \(CDImporter.objectInfo(sourceObject))")
//                     CDImporter.copyUniqueObject(sourceObject, targetContext: targetContext)
//                     CDImporter.copyRelationshipsFromObject(sourceObject, to: targetContext)                    
//                }
//            } else {print("ERROR: \(#function) could not find any sourceObjects")}
//            NSNotificationCenter.defaultCenter().postNotificationName("SomethingChanged", object: nil)
//        }
//    }
//    class func triggerDeepCopy (sourceContext:NSManagedObjectContext, targetContext:NSManagedObjectContext, mainContext:NSManagedObjectContext) {
//        
//        sourceContext.performBlock {
//                
//            CDImporter.deepCopyEntities(["Item","Unit","LocationAtHome", "LocationAtShop"], from: sourceContext, to: targetContext)
//                
//            mainContext.performBlock {
//                // Trigger interface refresh
//                NSNotificationCenter.defaultCenter().postNotificationName("SomethingChanged", object: nil)
//            }
//            print("*** FINISHED DEEP COPY FROM DEFAULT DATA PERSISTENT STORE ***")
//        }
//    }
//}
