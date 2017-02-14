////
////  CDCloudSync.swift
////
////  Created by Tim Roadley on 8/11/2015.
////  Copyright © 2015 Tim Roadley. All rights reserved.
////
//
///*
//CDCloudSync Usage Instructions
//
//1) Link to the System Configuration Framework, the Core Data Framework, and the CloudKit Framework in the General tab of the application target
//2) Drag the Generic Core Data Classes folder into your project. Ensure that "Copy items if needed", "Create groups", and the application target are selected before clicking Finish.
//3) Create your data model as required.
//4) Add an Integer 16 attribute called cacheStatus and String attributes called cacheID, group, and groupKey to all entities.
//5) Create some data and then trigger a refresh by calling CDCloudSync.shared.syncEntities and passing appropriate entities, database & context.
//6) Log in to the CloudKit dashboard and set appropriate security for your data https://icloud.developer.apple.com/dashboard/
//7) If you're using group security, be sure to trigger a re-fetch if the group ever changes.
//8) Whenever you change or delete an NSManagedObject, call the following and then save.
//CDCloudSync.shared.setCacheStatusForObject(object, requestedStatus: CHANGED)
//CDCloudSync.shared.setCacheStatusForObject(object, requestedStatus: DELETING)
//9) Whenever you change a deleted object's status to DELETING, make sure all views filter out thes object types.
//
//Read Chapter 15 and 16 of "Learning Core Data with Swift for iOS" by Tim Roadley for full details. (Search Amazon.com to find it)
//
//Post some nice feedback on Twitter if you like this code, or, email me at timroadley@icloud.com if you find a bug.
//
//*/
//
//import UIKit
//import CoreData
//import CloudKit
//import SystemConfiguration
//
//// CACHE STATUS
//let NEW = 0, INSERTING = 1, RELATING = 2, CHANGED = 3, DELETING = 4, SYNCHRONIZED = 5
//
//private let _sharedCDCloudSync = CDCloudSync()
//class CDCloudSync: NSObject {
//    
//    // MARK: - SHARED INSTANCE
//    class var shared : CDCloudSync {
//        return _sharedCDCloudSync
//    }
//    
//    // MARK: - LEGIBILITY
//    func friendlyObjectName (object:NSManagedObject) -> String {
//        
//        if let entityName = object.entity.name, moc = object.managedObjectContext {
//            if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc) {
//                
//                for (attribute, _) in entity.attributesByName {
//                    
//                    if ["name","storedIn","aisle"].contains(attribute) {
//                        
//                        if let value = object.valueForKey(attribute) as? String {
//                            
//                            if let cacheID = object.valueForKey("cacheID") as? String {
//                                return "[\(entityName) object \"\(value)\" cacheID:\"\(cacheID)\"]"
//                            } else {
//                                return "[\(entityName) object \"\(value)\" cacheID:\"nil\")]"
//                            }
//                        }
//                    }
//                }
//            }
//            return "[\(entityName) object]"
//        }
//        return "[????]"
//    }
//    func friendlyRecordName (record:CKRecord) -> String {
//        
//        if let name = record.valueForKey("name") as? String {
//            return "[\(record.recordType) record \"\(name)\" recordID:\"\(record.recordID.recordName)\"]"
//        }
//        if let storedIn = record.valueForKey("storedIn") as? String {
//            return "[\(record.recordType) record \"\(storedIn)\" recordID:\"\(record.recordID.recordName)\"]"
//        }
//        if let aisle = record.valueForKey("aisle") as? String {
//            return "[\(record.recordType) record \"\(aisle)\" recordID:\"\(record.recordID.recordName)\"]"
//        }
//        return "[\(record.recordType) record recordID:\"\(record.recordID.recordName)\"]"
//    }
//    func friendlyRecordSummary (record:CKRecord) -> String {
//        
//        if let name = record.valueForKey("name") as? String {
//            return "\(name)"
//        }
//        if let storedIn = record.valueForKey("storedIn") as? String {
//            return "\(storedIn)"
//        }
//        if let aisle = record.valueForKey("aisle") as? String {
//            return "\(aisle)"
//        }
//        return "Data"
//    }
//    
//    // MARK: - GROUP
//    func group () -> String {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if let object = defaults.objectForKey("group") as? String {
//            return object
//        }
//        defaults.setObject("Public", forKey: "group")
//        return "Public"
//    }
//    func groupKey () -> String {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if let object = defaults.objectForKey("groupKey") as? String {
//            return object
//        }
//        defaults.setObject("Public", forKey: "groupKey")
//        return "Public"
//    }
//    class func addGroupInfo(object:NSManagedObject) {
//        object.setValue(CDCloudSync.shared.group(), forKey: "group")
//        object.setValue(CDCloudSync.shared.groupKey(), forKey: "groupKey")
//        
//        CDCloudSync.shared.setCacheStatusForObject(object, requestedStatus: CHANGED)
//    }
//    
//    // MARK: - CACHE STATUS
//    func cacheStatusName (cacheStatus:Int) -> String {
//        
//        switch (cacheStatus) {
//            
//        case NEW:          return "NEW"
//        case INSERTING:    return "INSERTING"
//        case RELATING:     return "RELATING"
//        case CHANGED:      return "CHANGED"
//        case DELETING:     return "DELETING"
//        case SYNCHRONIZED: return "SYNCHRONIZED"
//        default:           return "UNKNOWN"
//        }
//    }
//    func setCacheStatusForObject (object:NSManagedObject, requestedStatus:Int) {
//        
//        if let currentStatus = object.valueForKey("cacheStatus") as? NSNumber {
//            
//            if currentStatus == NEW && requestedStatus == CHANGED {
//                NSLog("%@ cannot move directly from NEW to CHANGED", self.friendlyObjectName(object))
//                return
//            }
//            
//            if currentStatus == INSERTING && requestedStatus == CHANGED {
//                NSLog("%@ cannot move directly from INSERTING to CHANGED", self.friendlyObjectName(object))
//                return
//            }
//            
//            let newStatus = NSNumber(integer: requestedStatus)
//            object.setValue(newStatus, forKey: "cacheStatus")
//            object.setValue(NSDate(), forKey: "modified")
//            if let context = object.managedObjectContext {CDHelper.save(context)}
//            
//        } else {NSLog("ERROR getting existing cacheStatus in %@",#function)}
//    }
//    func cacheStatusForAllObjects (entities:[String], context:NSManagedObjectContext) {
//        
//        var new          = [NSManagedObject]()
//        var inserting    = [NSManagedObject]()
//        var relating     = [NSManagedObject]()
//        var changed      = [NSManagedObject]()
//        var deleting     = [NSManagedObject]()
//        var synchronized = [NSManagedObject]()
//        
//        let predicateNew          = NSPredicate(format: "cacheStatus == %i", NEW)
//        let predicateInserting    = NSPredicate(format: "cacheStatus == %i", INSERTING)
//        let predicateRelating     = NSPredicate(format: "cacheStatus == %i", RELATING)
//        let predicateChanged      = NSPredicate(format: "cacheStatus == %i", CHANGED)
//        let predicateDeleting     = NSPredicate(format: "cacheStatus == %i", DELETING)
//        let predicateSynchronized = NSPredicate(format: "cacheStatus == %i", SYNCHRONIZED)
//        
//        
//        for entityName in entities {
//            
//            if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicateNew, sort: nil) as? [NSManagedObject] {
//                for object in objects {new.append(object)}
//            }
//            
//            if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicateInserting, sort: nil) as? [NSManagedObject] {
//                for object in objects {inserting.append(object)}
//            }
//            
//            if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicateRelating, sort: nil) as? [NSManagedObject] {
//                for object in objects {relating.append(object)}
//            }
//            
//            if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicateChanged, sort: nil) as? [NSManagedObject] {
//                for object in objects {changed.append(object)}
//            }
//            
//            if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicateDeleting, sort: nil) as? [NSManagedObject] {
//                for object in objects {deleting.append(object)}
//            }
//            
//            if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicateSynchronized, sort: nil) as? [NSManagedObject] {
//                for object in objects {synchronized.append(object)}
//            }
//        }
//        
//        if new.isEmpty == false {
//            NSLog("%i NEW:", new.count)
//            for object in new {NSLog("  --> %@", self.friendlyObjectName(object))}
//        }
//        if inserting.isEmpty == false {
//            NSLog("%i INSERTING:", inserting.count)
//            for object in inserting {NSLog("  --> %@", self.friendlyObjectName(object))}
//        }
//        if relating.isEmpty == false {
//            NSLog("%i RELATING:", relating.count)
//            for object in relating {NSLog("  --> %@", self.friendlyObjectName(object))}
//        }
//        if changed.isEmpty == false {
//            NSLog("%i CHANGED:", changed.count)
//            for object in changed {NSLog("  --> %@", self.friendlyObjectName(object))}
//        }
//        if deleting.isEmpty == false {
//            NSLog("%i DELETING:", deleting.count)
//            for object in deleting {NSLog("  --> %@", self.friendlyObjectName(object))}
//        }
//        if synchronized.isEmpty == false {
//            NSLog("%i SYNCHRONIZED:", synchronized.count)
//            for object in synchronized {NSLog("  --> %@", self.friendlyObjectName(object))}
//        }
//    }
//    
//    // MARK: - GENERAL
//    func syncMessage (message:String) {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            NSNotificationCenter.defaultCenter().postNotificationName("syncMessage", object: message)
//        })
//    }
//    func createRecordWithObject (object:NSManagedObject) -> CKRecord {
//        let record = CKRecord(recordType: object.entity.name!)
//        return updateRecord(record, withObject: object)
//    }
//    func updateRecord (record:CKRecord, withObject object:NSManagedObject) -> CKRecord {
//        
//        if let entityName = object.entity.name {
//            if record.recordType == entityName {
//                
//                for (attribute, description) in object.entity.attributesByName {
//                    if let type = description.attributeValueClassName {
//                        
//                        if attribute != "cacheID" && attribute != "cacheStatus" {
//                            
//                            switch (type) {
//                                
//                            case "NSNumber":
//                                if let value = object.valueForKey(attribute) as? NSNumber {
//                                    record.setObject(value, forKey: attribute)
//                                }
//                                
//                            case "NSDecimalNumber":
//                                if let value = object.valueForKey(attribute) as? NSDecimalNumber {
//                                    record.setObject(value, forKey: attribute)
//                                }
//                                
//                            case "NSString":
//                                if let value = object.valueForKey(attribute) as? NSString {
//                                    record.setObject(value, forKey: attribute)
//                                }
//                                
//                            case "NSDate":
//                                if let value = object.valueForKey(attribute) as? NSDate {
//                                    record.setObject(value, forKey: attribute)
//                                }
//                                
//                            case "NSData":
//                                if let value = object.valueForKey(attribute) as? NSData {
//                                    record.setObject(value, forKey: attribute)
//                                }
//                                
//                            default:
//                                NSLog("UNHANDLED type '%@' in %@", type, #function)
//                            }
//                        }
//                    }
//                }
//                
//                record.setObject(record.recordID.recordName, forKey: "cacheID")
//                record.setObject(self.group(), forKey: "group")
//                record.setObject(self.groupKey(), forKey: "groupKey")
//                
//            } else {NSLog("SKIPPED record update because the given object entity and record type don't match in %@", #function)}
//        } else {NSLog("SKIPPED record update because the entityName could not be determined in %@", #function)}
//        return record
//    }
//    func updateReferenceForRecord (record:CKRecord, withObject object:NSManagedObject) -> CKRecord {
//        
//        for (relationshipName, relationship) in object.entity.relationshipsByName {
//            
//            if relationship.toMany {
//                //NSLog("SKIPPED unsupported To-Many '%@' relationship for %@ (ManyToOne will be processed on the inverse ToOne relationship)", relationshipName, self.friendlyObjectName(object))
//            } else if relationship.ordered {
//                NSLog("SKIPPED Ordered '%@' relationship for %@ (Not supported)", relationshipName, self.friendlyObjectName(object))
//            } else {
//                
//                // ToOne relationship determined, find the related object's cacheID
//                if let relatedObject = object.valueForKey(relationshipName) as? NSManagedObject {
//                    if let relatedObjectCacheID = relatedObject.valueForKey("cacheID") as? String {
//                        
//                        let relatedObjectRecordID = CKRecordID(recordName: relatedObjectCacheID)
//                        let reference = CKReference(recordID: relatedObjectRecordID, action: .None)
//                        record.setObject(reference, forKey: relationshipName)
//                        NSLog("ESTABLISHED a To-One '%@' reference for %@ based on relationship from %@ to %@", relationshipName, self.friendlyRecordName(record),self.friendlyObjectName(object), self.friendlyObjectName(relatedObject))
//                    } else {
//                        NSLog("CRITICAL ERROR getting cacheID from related object %@. ObjectID = %@", self.friendlyObjectName(relatedObject),relatedObject.objectID.description)
//                    }
//                } else {
//                    NSLog("ESTABLISHED NIL %@ relationship for %@", relationshipName, self.friendlyObjectName(object))
//                    record.setObject(nil, forKey: relationshipName)
//                }
//            }
//        }
//        return record
//    }
//    func saveMappedRecords (mappedRecords:[CKRecord:NSManagedObject], context:NSManagedObjectContext, database:CKDatabase, successStatus:Int, fault:Bool, completion:(savedMappedRecords:[CKRecord:NSManagedObject]?) -> Void) {
//        
//        // Nothing to save
//        if mappedRecords.count == 0 {completion(savedMappedRecords: nil);return}
//        
//        // Split into batches to prevent "too many items" & "rate limited" errors
//        let batchSize = 300
//        let batchCountFloat:Float = Float(mappedRecords.count) / Float(batchSize)
//        var batchCountInt:Int = Int(round(batchCountFloat))
//        if batchCountFloat > Float(batchCountInt) {batchCountInt += 1} // Round Up
//        if batchCountInt == 0 {completion(savedMappedRecords: nil);return}
//        var batches = [[CKRecord]]()
//        let allKeys:[CKRecord] = Array(mappedRecords.keys)
//        var rangeStart = 0, rangeEnd = 0
//        NSLog("SAVING %i record(s) in %i batch(es) with a size of %i", mappedRecords.count, batchCountInt, batchSize)
//        for batchNumber in 1...batchCountInt {
//            rangeStart = rangeEnd
//            rangeEnd = rangeStart + batchSize
//            if rangeEnd > allKeys.count {rangeEnd = allKeys.count}
//            
//            // Pull a subset of mapped records into the "batch" sized dictionary.
//            let batchKeys = allKeys[rangeStart...(rangeEnd-1)]
//            var batch:[CKRecord] = []
//            for batchKey in batchKeys {batch.append(batchKey)}
//            batches.append(batch)
//            NSLog("PROCESSING save batch %i range %i to %i", batchNumber, rangeStart, rangeEnd - 1)
//        }
//        
//        var allSavedRecords = [CKRecord]()
//        var batchesRemaining = batches.count
//        for batch in batches {
//            
//            let operation = CKModifyRecordsOperation(recordsToSave: batch, recordIDsToDelete: [])
//            operation.savePolicy = CKRecordSavePolicy.AllKeys
//            operation.qualityOfService = .UserInteractive
//            operation.modifyRecordsCompletionBlock = {(savedRecords, deletedRecords, error) -> Void in
//                
//                if let _error = error {
//                    self.syncMessage("Sync Error 1. Try Later")
//                    NSLog("ERROR saving records: %@", _error)
//                    completion(savedMappedRecords: nil)
//                } else if let _savedRecords = savedRecords {
//                    // Reconstitute batch
//                    allSavedRecords.appendContentsOf(_savedRecords)
//                }
//                batchesRemaining -= 1
//                NSLog("%i save batch(es) remaining", batchesRemaining)
//                if batchesRemaining == 0 {
//                    var savedMappedRecords = [CKRecord:NSManagedObject]()
//                    for savedRecord in allSavedRecords {
//                        if let mappedObject = mappedRecords[savedRecord] {
//                            
//                            // Set cacheID if it's missing
//                            if mappedObject.valueForKey("cacheID") == nil {
//                                mappedObject.setValue(savedRecord.recordID.recordName, forKey: "cacheID")
//                            }
//                            self.syncMessage("Synchronized \(self.friendlyRecordSummary(savedRecord))")
//                            NSLog("SAVED record %@", self.friendlyRecordName(savedRecord))
//                            
//                            // Update Cache Status
//                            self.setCacheStatusForObject(mappedObject, requestedStatus: successStatus)
//                            savedMappedRecords[savedRecord] = mappedObject
//                            
//                            // Free up memory
//                            if fault {CDFaulter.faultObject(mappedObject, moc: context)}
//                        }
//                    }
//                    completion(savedMappedRecords: savedMappedRecords)
//                }
//            }
//            database.addOperation(operation)
//        }
//    }
//    func fetchRecordWithCacheID(cacheID:String, database:CKDatabase, completion:(fetchedRecord: CKRecord?, recordNotFound:Bool) -> Void) {
//        
//        let recordID = CKRecordID(recordName: cacheID)
//        database.fetchRecordWithID(recordID, completionHandler: { (record, error) -> Void in
//            if let _error = error {
//                
//                if let reason = _error.userInfo["ErrorDescription"] as? String {
//                    if reason == "Record not found" {
//                        completion(fetchedRecord: nil, recordNotFound: true) // Fail, record does not exist
//                        return
//                    }
//                }
//                NSLog("RETRY fetching record '%@' later %@", recordID.recordName, _error)
//                completion(fetchedRecord: nil, recordNotFound: false) // Fail, probably network related
//            } else {
//                completion(fetchedRecord: record, recordNotFound: false) // Success
//            }
//        })
//    }
//    func deleteRecordWithObject (object:NSManagedObject, database:CKDatabase) {
//        
//        if let context = object.managedObjectContext {
//            if let cacheID = object.valueForKey("cacheID") as? String {
//                
//                let recordID = CKRecordID(recordName: cacheID)
//                database.deleteRecordWithID(recordID, completionHandler: { (deletedRecordID, error) -> Void in
//                    
//                    if let _error = error {
//                        
//                        if let reason = _error.userInfo["ErrorDescription"] as? String {
//                            if reason == "Record not found" {
//                                NSLog("DELETED object %@. An associated record was not found in iCloud", self.friendlyObjectName(object))
//                                context.deleteObject(object)
//                                CDHelper.save(context)
//                                return
//                            }
//                        }
//                        NSLog("ERROR deleting record %@ - %@",cacheID, _error)
//                    } else {
//                        NSLog("DELETED object %@ and the associated record in iCloud", self.friendlyObjectName(object))
//                        context.deleteObject(object)
//                        CDHelper.save(context)
//                        return
//                    }
//                })
//            } else {
//                NSLog("DELETED object %@", #function)
//                context.deleteObject(object)
//                CDHelper.save(context)
//            }
//        } else {NSLog("ERROR getting context in %@",#function)}
//    }
//    func createRelationshipFromReference (reference:CKReference, database:CKDatabase, object:NSManagedObject, relationshipName:String) {
//        
//        if let moc = object.managedObjectContext {
//            
//            let destinationCacheID = reference.recordID.recordName
//            let uniqueAttributes = ["cacheID":destinationCacheID]
//            let relationshipDescriptions = object.entity.relationshipsByName
//            
//            // Get the appropriate record type or target entity
//            for (relationship, description) in relationshipDescriptions {
//                
//                if let targetEntityName = description.destinationEntity?.name {
//                    
//                    if relationshipName == description.name {
//                        
//                        if let targetObject = CDOperation.uniqueObjectWithAttributeValuesForEntity(targetEntityName, context: moc, uniqueAttributes: uniqueAttributes) {
//                            NSLog("CONNECTED %@ relationship from %@ to %@", relationship, friendlyObjectName(object), friendlyObjectName(targetObject))
//                            object.setValue(targetObject, forKey: relationshipName)
//                        } else {
//                            NSLog("WARNING: Can't create a relationship to a targetObject that does not exist!")
//                        }
//                    }
//                }
//            }
//        } else {NSLog("%@ failed to get moc",#function)}
//    }
//    func createOrUpdateObjectWithRecord (record:CKRecord, database:CKDatabase, context:NSManagedObjectContext, attributes:Bool) -> NSManagedObject {
//        
//        let cacheID = record.recordID.recordName
//        let entityName = record.recordType
//        let uniqueAttributes = ["cacheID":cacheID]
//        
//        // Find or insert unique object (insertUniqueObject handles both scenarios)
//        let object = CDOperation.insertUniqueObject(entityName, context: context, uniqueAttributes: uniqueAttributes, additionalAttributes: nil)
//        
//        // Nil out relationships missing from record
//        var expectedRelationships = Set<String>()
//        for (relationship, description) in object.entity.relationshipsByName {
//            if description.toMany == false {
//                expectedRelationships.insert(relationship)
//            }
//        }
//        for relationship in record.allKeys() {
//            expectedRelationships.remove(relationship)
//        }
//        for relationship in expectedRelationships {
//            // NSLog("Setting the %@ relationship to nil for %@", relationship, self.friendlyObjectName(object))
//            object.setValue(nil, forKey: relationship)
//        }
//        
//        // Set object attributes & relationships from CKRecord
//        for key in record.allKeys() {
//            if let reference = record.valueForKey(key) as? CKReference {
//                
//                // Set relationship
//                if attributes == false {
//                    self.createRelationshipFromReference(reference, database:database, object:object, relationshipName:key)
//                }
//                
//            } else {
//                // Set attributes
//                if attributes == true {
//                    object.setValue(record.valueForKey(key), forKey: key)
//                }
//            }
//        }
//        self.setCacheStatusForObject(object, requestedStatus: SYNCHRONIZED)
//        return object
//    }
//    
//    // MARK: - INSERTS
//    func uploadNewRecordsForEntities(entities:[String], context:NSManagedObjectContext, database:CKDatabase, completion:() -> Void) {
//        
//        // Prepare new records to insert
//        var recordsToInsert = [CKRecord:NSManagedObject]()
//        let predicate = NSPredicate(format: "cacheStatus == %i OR cacheStatus == %i", NEW, INSERTING)
//        for entityName in entities {
//            if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicate, sort: nil) as? [NSManagedObject] {
//                
//                // Set Cache Status to INSERTING for given records
//                for object in objects {
//                    self.setCacheStatusForObject(object, requestedStatus: INSERTING)
//                    let record = self.createRecordWithObject(object)
//                    recordsToInsert[record] = object
//                }
//                
//                // Ensure objects have a permanentID, which ensures that references to these objects via relationships work properly
//                do {
//                    
//                    try context.obtainPermanentIDsForObjects(objects)
//                    
//                } catch {
//                    NSLog("ERROR obtaining permanentIDsForObjects in %@",#function)
//                }
//                CDHelper.save(context)
//            }
//        }
//        if recordsToInsert.isEmpty {NSLog("No new objects need uploading.");completion();return}
//        
//        self.saveMappedRecords(recordsToInsert, context: context, database: database, successStatus: RELATING, fault: false) { (savedMappedRecords) -> Void in
//            
//            if let _savedMappedRecords = savedMappedRecords {
//                
//                self.uploadReferencesForRecords(_savedMappedRecords, context: context, database: database, completion: { () -> Void in
//                    completion()
//                })
//                
//            } else {
//                NSLog("FAILED to insert records, setting the cacheStatus back to New")
//                for (_, object) in recordsToInsert {
//                    self.setCacheStatusForObject(object, requestedStatus: NEW)
//                }
//                completion()
//            }
//        }
//    }
//    func uploadReferencesForRecords  (records:[CKRecord:NSManagedObject], context:NSManagedObjectContext, database:CKDatabase, completion:() -> Void) {
//        
//        var recordsToSave = [CKRecord:NSManagedObject]()
//        
//        // Upload references
//        for (record, object) in records {
//            let updatedRecord = self.updateReferenceForRecord(record, withObject: object)
//            recordsToSave[updatedRecord] = object
//        }
//        
//        self.saveMappedRecords(recordsToSave, context: context, database: database, successStatus: SYNCHRONIZED, fault: true) { (savedMappedRecords) -> Void in
//            CDHelper.save(context)
//            completion()
//        }
//    }
//    
//    // MARK: - CHANGES
//    var serverChanges = [String:Set<String>]()
//    func serverChangesOperation(queryOperation: CKQueryOperation, entityName:String, database:CKDatabase, completion:() -> Void) {
//        
//        queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
//            if let cacheID = record.objectForKey("cacheID") as? String {
//                if var entityCacheIDs = self.serverChanges[entityName] {
//                    entityCacheIDs.insert(cacheID)
//                    self.serverChanges[entityName] = entityCacheIDs
//                } else {print("ERROR in \(#function) getting entityCacheIDs")}
//            } else {print("ERROR in \(#function) getting cacheID")}
//        }
//        queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
//            if let queryCursor = cursor {
//                NSLog("WAITING for more %@ data...", entityName)
//                self.syncMessage("Looking For Changes")
//                let queryCursorOperation = CKQueryOperation(cursor: queryCursor)
//                self.serverChangesOperation(queryCursorOperation, entityName: entityName, database: database, completion: { () -> Void in
//                    completion()
//                })
//            } else {
//                if let _error = error {
//                    NSLog("ERROR in queryCompletionBlock: -> %@", _error)
//                }
//                completion()
//            }
//        }
//        database.addOperation(queryOperation)
//    }
//    func serverChangesSinceLastDownload (entities:[String], database:CKDatabase, completion:() -> Void) {
//        
//        // Reset
//        self.serverChanges = [String:Set<String>]()
//        for entityName in entities {
//            self.serverChanges[entityName] = Set<String>()
//        }
//        let lastDownload = dateKey("LAST DOWNLOAD FOR GROUP \"\(self.group())\":\"\(self.groupKey())\"")
//        var entitiesToProcess = entities.count
//        for entityName in entities {
//            let predicate = NSPredicate(format: "modified > %@ AND group == %@ AND groupKey == %@ AND cacheID != ''", lastDownload, self.group(), self.groupKey())
//            let query = CKQuery(recordType: entityName, predicate: predicate)
//            let operation = CKQueryOperation(query: query)
//            operation.qualityOfService = .UserInteractive
//            operation.desiredKeys = ["cacheID"]
//            operation.resultsLimit = CKQueryOperationMaximumResults
//            
//            self.serverChangesOperation(operation, entityName: entityName, database: database, completion: { () -> Void in
//                entitiesToProcess -= 1
//                if entitiesToProcess == 0 {completion()}
//            })
//        }
//    }
//    func downloadChangesForEntities (entities:[String], database:CKDatabase, context:NSManagedObjectContext, completion:() -> Void) {
//        
//        self.serverChangesSinceLastDownload(entities, database: database) { () -> Void in
//            
//            // Build changed RecordID array
//            var changedRecordIDs:[CKRecordID] = []
//            for entityName in entities {
//                if let changedCacheIDs = self.serverChanges[entityName] {
//                    for cacheID in changedCacheIDs {
//                        changedRecordIDs.append(CKRecordID(recordName: cacheID))
//                    }
//                } else {NSLog("ERROR in %@ getting changes for %@", #function, entityName)}
//            }
//            
//            // Split download into batches to prevent "too many items" & "rate limited" errors
//            let batchSize = 300
//            let batchCountFloat:Float = Float(changedRecordIDs.count) / Float(batchSize)
//            var batchCountInt:Int = Int(round(batchCountFloat))
//            if batchCountFloat > Float(batchCountInt) {batchCountInt += 1} // Round Up
//            if batchCountInt == 0 {completion();return}
//            var batches = [[CKRecordID]]()
//            var rangeStart = 0, rangeEnd = 0
//            
//            NSLog("DOWNLOADING %i record(s) in %i batch(es) with a size of %i", changedRecordIDs.count, batchCountInt, batchSize)
//            
//            for batchNumber in 1...batchCountInt {
//                
//                rangeStart = rangeEnd
//                rangeEnd = rangeStart + batchSize
//                if rangeEnd > changedRecordIDs.count {rangeEnd = changedRecordIDs.count}
//                
//                // Pull a subset of mapped records into the "batch" sized dictionary.
//                let batchKeys = changedRecordIDs[rangeStart...(rangeEnd-1)]
//                var batch:[CKRecordID] = []
//                for batchKey in batchKeys {batch.append(batchKey)}
//                batches.append(batch)
//                NSLog("PROCESSING download batch %i range %i to %i", batchNumber, rangeStart, rangeEnd - 1)
//            }
//            
//            // Download batch
//            var downloadedRecords = [CKRecord]()
//            var batchesRemaining = batches.count
//            for batch in batches {
//                
//                let operation = CKFetchRecordsOperation(recordIDs: batch)
//                operation.qualityOfService = .UserInteractive
//                operation.fetchRecordsCompletionBlock = { (recordDictionary, error) -> Void in
//                    
//                    if let _error = error {
//                        NSLog("ERROR in %@ - %@", #function, _error)
//                    } else if let _recordDictionary = recordDictionary {
//                        
//                        // Reconstitute batch
//                        for (_, record) in _recordDictionary {
//                            downloadedRecords.append(record)
//                        }
//                    } else {NSLog("ERROR in %@ getting _recordDictionary", #function)}
//                    
//                    batchesRemaining -= 1
//                    if batchesRemaining == 0 {
//                        
//                        // Create/update attributes
//                        for record in downloadedRecords {
//                            self.createOrUpdateObjectWithRecord(record, database: database, context: context, attributes: true)
//                        }
//                        
//                        // Create/update relationships
//                        for record in downloadedRecords {
//                            self.createOrUpdateObjectWithRecord(record, database: database, context: context, attributes: false)
//                        }
//                        
//                        // Update Last Download date for this group
//                        NSLog("All download batches have been processed.")
//                        self.setDateKey("LAST DOWNLOAD FOR GROUP \"\(self.group())\":\"\(self.groupKey())\"", date: NSDate())
//                        completion()
//                    } else {NSLog("%i download batch(es) remaining", batchesRemaining)}
//                }
//                database.addOperation(operation)
//            }
//        }
//    }
//    var updatedRecords = [String:[CKRecord:NSManagedObject]]()
//    func updatedRecordsOperation(queryOperation: CKQueryOperation, entityName:String, context:NSManagedObjectContext, database:CKDatabase, completion:() -> Void) {
//        
//        queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
//            
//            if var updatedRecords = self.updatedRecords[entityName] {
//                let cacheID = record.recordID.recordName
//                if let object = CDOperation.objectWithAttributeValueForEntity(entityName, context: context, attribute: "cacheID", value: cacheID) {
//                    var updatedRecord = self.updateRecord(record, withObject: object)
//                    updatedRecord = self.updateReferenceForRecord(updatedRecord, withObject: object)
//                    updatedRecords[record] = object
//                    self.updatedRecords[entityName] = updatedRecords
//                } else {NSLog("ERROR in %@ getting object", #function)}
//            } else {NSLog("ERROR in %@ getting entityRecords", #function)}
//        }
//        queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
//            if let queryCursor = cursor {
//                NSLog("WAITING for more %@ data...", entityName)
//                self.syncMessage("Processing Changes...")
//                let queryCursorOperation = CKQueryOperation(cursor: queryCursor)
//                self.updatedRecordsOperation(queryCursorOperation, entityName: entityName, context: context, database: database, completion: { () -> Void in
//                    completion()
//                })
//            } else {
//                if let _error = error {
//                    NSLog("ERROR in queryCompletionBlock: -> %@", _error)
//                }
//                completion()
//            }
//        }
//        database.addOperation(queryOperation)
//    }
//    func uploadChangesForEntities (entities:[String], database:CKDatabase, context:NSManagedObjectContext, completion:() -> Void) {
//        
//        // Reset
//        self.updatedRecords = [String:[CKRecord:NSManagedObject]]()
//        for entityName in entities {
//            self.updatedRecords[entityName] = [CKRecord:NSManagedObject]()
//        }
//        
//        var entitiesToProcess = entities.count
//        for entityName in entities {
//            
//            let predicate = NSPredicate(format: "cacheStatus == %i AND group == %@ AND groupKey == %@", CHANGED, self.group(), self.groupKey())
//            if let changedObjects = CDOperation.objectsForEntity(entityName, context: context, filter: predicate, sort: nil) as? [NSManagedObject] {
//                
//                // Create changed object cacheID array
//                var cacheIDs = [String]()
//                for changedObject in changedObjects {
//                    if let cacheID = changedObject.valueForKey("cacheID") as? String {
//                        // Prevent upload of more than 100 changes at once to work around server rejection of "IN" predicate "too many items". Additional changes will need to be uploaded later.
//                        if cacheIDs.count < 100 {cacheIDs.append(cacheID)}
//                    } else {print("ERROR in \(#function) getting cacheID")}
//                }
//                
//                // Log intended changes to console
//                if changedObjects.count == 0 {
//                    NSLog("No %@ changes need uploading.", entityName)
//                    entitiesToProcess -= 1
//                    if entitiesToProcess == 0 {completion()}
//                } else {
//                    NSLog("PREPARING to upload %i %@ changes", changedObjects.count, entityName)
//                    
//                    // Update records
//                    let queryPredicate = NSPredicate(format: "cacheID IN %@", cacheIDs)
//                    let query = CKQuery(recordType: entityName, predicate: queryPredicate)
//                    let operation = CKQueryOperation(query: query)
//                    operation.qualityOfService = .UserInteractive
//                    operation.desiredKeys = ["cacheID"]
//                    operation.resultsLimit = CKQueryOperationMaximumResults
//                    
//                    self.updatedRecordsOperation(operation, entityName: entityName, context: context, database: database, completion: { () -> Void in
//                        
//                        if let updatedRecords = self.updatedRecords[entityName] {
//                            
//                            self.saveMappedRecords(updatedRecords, context: context, database: database, successStatus: SYNCHRONIZED, fault: false, completion: { (savedMappedRecords) -> Void in
//                                entitiesToProcess -= 1
//                                NSLog("There are %i entities left to process.", entitiesToProcess)
//                                if entitiesToProcess == 0 {completion()}
//                            })
//                            
//                        } else {
//                            NSLog("ERROR in %@ getting updated %@ records", #function, entityName)
//                            if entitiesToProcess == 0 {completion()}
//                        }
//                    })
//                }
//            } else {NSLog("ERROR in %@ getting changedObjects",#function)}
//        }
//    }
//    
//    // MARK: - DELETIONS
//    var serverCacheIDs = [String:Set<String>]()
//    func existingServerCacheIDsOperation(queryOperation: CKQueryOperation, entityName:String, database:CKDatabase, completion:() -> Void) {
//        
//        queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
//            if let cacheID = record.objectForKey("cacheID") as? String {
//                if var entityCacheIDs = self.serverCacheIDs[entityName] {
//                    entityCacheIDs.insert(cacheID)
//                    self.serverCacheIDs[entityName] = entityCacheIDs
//                } else {print("ERROR in \(#function) preparing entityCacheIDs")}
//            } else {print("ERROR in \(#function) getting cacheID")}
//        }
//        
//        queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
//            if let queryCursor = cursor {
//                NSLog("WAITING for more %@ data...", entityName)
//                self.syncMessage("Comparing Server Data")
//                let queryCursorOperation = CKQueryOperation(cursor: queryCursor)
//                self.existingServerCacheIDsOperation(queryCursorOperation, entityName: entityName, database: database, completion: { () -> Void in
//                    completion()
//                })
//            } else {
//                if let _error = error {
//                    NSLog("ERROR in queryCompletionBlock: -> %@", _error)
//                }
//                completion()
//            }
//        }
//        database.addOperation(queryOperation)
//    }
//    func existingServerCacheIDs (entities:[String], database:CKDatabase, completion:() -> Void) {
//        
//        // Reset
//        self.serverCacheIDs = [String:Set<String>]()
//        for entityName in entities {
//            self.serverCacheIDs[entityName] = Set<String>()
//        }
//        
//        var entitiesToProcess = entities.count
//        for entityName in entities {
//            
//            let predicate = NSPredicate(format: "group == %@ AND groupKey == %@", self.group(), self.groupKey())
//            let query = CKQuery(recordType: entityName, predicate: predicate)
//            let operation = CKQueryOperation(query: query)
//            operation.qualityOfService = .UserInteractive
//            operation.desiredKeys = ["cacheID"]
//            operation.resultsLimit = CKQueryOperationMaximumResults
//            
//            self.existingServerCacheIDsOperation(operation, entityName: entityName, database: database, completion: { () -> Void in
//                entitiesToProcess -= 1
//                if entitiesToProcess == 0 {completion()}
//            })
//        }
//    }
//    func deleteOrphanedCacheObjects (entities:[String], database:CKDatabase, context:NSManagedObjectContext, completion:() -> Void) {
//        
//        self.existingServerCacheIDs(entities, database: database) { () -> Void in
//            
//            for entityName in entities {
//                
//                if let entityCacheIDs = self.serverCacheIDs[entityName] {
//                    
//                    let filter = NSPredicate(format: "(NOT(cacheID IN %@) AND (cacheStatus == %i OR cacheStatus == %i)) OR cacheStatus == %i OR group != %@ OR groupKey != %@", entityCacheIDs, SYNCHRONIZED, CHANGED, DELETING, self.group(), self.groupKey())
//                    
//                    if let objects = CDOperation.objectsForEntity(entityName, context: context, filter: filter, sort: nil) as? [NSManagedObject] {
//                        
//                        if objects.count > 0 {
//                            NSLog("%i DELETING:", objects.count)
//                        } else {
//                            NSLog("No orphaned %@ objects need deleting.", entityName)
//                        }
//                        for object in objects {
//                            NSLog("  --> %@", self.friendlyObjectName(object))
//                            self.deleteRecordWithObject(object, database: database)
//                        }
//                        CDHelper.save(context)
//                    } else {NSLog("FAILED to get objects array")}
//                    
//                } else { NSLog("ERROR in %@ getting entityCacheIDs", #function)}
//            }
//            completion()
//        }
//    }
//    
//    // MARK: - QUALITY ASSURANCE
//    func existingLocalCacheIDs (entityName:String) -> Set<String> {
//        
//        var _localCacheIDs = Set<String>()
//        
//        let request = NSFetchRequest(entityName:entityName)
//        request.includesPendingChanges = true
//        request.propertiesToFetch = ["cacheID"]
//        request.resultType = NSFetchRequestResultType.DictionaryResultType
//        
//        do {
//            let fetchResults = try CDHelper.shared.parentContext.executeFetchRequest(request)
//            if let dictionaryArray = fetchResults as? [Dictionary<String, AnyObject>] {
//                for dictionary:Dictionary<String, AnyObject> in dictionaryArray {
//                    if let cacheID = dictionary["cacheID"] as? String {
//                        _localCacheIDs.insert(cacheID)
//                    } else { NSLog("ERROR in %@ getting cacheID", #function)}
//                }
//            } else { NSLog("ERROR in %@ getting dictionaryArray", #function)}
//        } catch {print("\(#function) FAILED to fetch objects: \(error)")}
//        return _localCacheIDs
//    }
//    func missingLocalCacheIDs (entities:[String], database:CKDatabase, completion:(missingCacheIDs:Set<String>) -> Void) {
//        
//        var allMissingCacheIDs = Set<String>()
//        var entitiesToProcess = entities.count
//        for entityName in entities {
//            if let entityCacheIDs = self.serverCacheIDs[entityName] {
//                
//                var missingEntityCacheIDs = entityCacheIDs
//                for existingCacheID in self.existingLocalCacheIDs(entityName) {
//                    missingEntityCacheIDs.remove(existingCacheID)
//                }
//                for missingCacheID in missingEntityCacheIDs {
//                    allMissingCacheIDs.insert(missingCacheID)
//                }
//            } else { NSLog("ERROR in %@ getting entityCacheIDs", #function)}
//            
//            // Keep track of how many entities have been processed
//            entitiesToProcess -= 1
//            if entitiesToProcess == 0 {
//                if allMissingCacheIDs.count > 0 {NSLog("FOUND cacheID's in iCloud that are not on this device: %@", allMissingCacheIDs.description)}
//                completion(missingCacheIDs: allMissingCacheIDs)
//            }
//        }
//    }
//    func qualityCheckEntities (entities:[String], database:CKDatabase, context:NSManagedObjectContext, completion:() -> Void) {
//        
//        self.missingLocalCacheIDs(entities, database: database) { (missingCacheIDs) -> Void in
//            
//            NSLog("There are %i objects on the server that are not on this device.", missingCacheIDs.count)
//            if missingCacheIDs.count > 0 {
//                
//                // Build missing RecordID array
//                var missingRecordIDs:[CKRecordID] = []
//                for cacheID in missingCacheIDs {
//                    missingRecordIDs.append(CKRecordID(recordName: cacheID))
//                }
//                
//                // Split download into batches to prevent "too many items" & "rate limited" errors
//                let batchSize = 300
//                let batchCountFloat:Float = Float(missingRecordIDs.count) / Float(batchSize)
//                var batchCountInt:Int = Int(round(batchCountFloat))
//                if batchCountFloat > Float(batchCountInt) {batchCountInt += 1} // Round Up
//                if batchCountInt == 0 {completion();return}
//                var batches = [[CKRecordID]]()
//                var rangeStart = 0, rangeEnd = 0
//                
//                NSLog("DOWNLOADING %i missing record(s) in %i batch(es) with a size of %i", missingRecordIDs.count, batchCountInt, batchSize)
//                for batchNumber in 1...batchCountInt {
//                    
//                    rangeStart = rangeEnd
//                    rangeEnd = rangeStart + batchSize
//                    if rangeEnd > missingRecordIDs.count {rangeEnd = missingRecordIDs.count}
//                    
//                    // Pull a subset of mapped records into the "batch" sized dictionary.
//                    let batchKeys = missingRecordIDs[rangeStart...(rangeEnd-1)]
//                    var batch:[CKRecordID] = []
//                    for batchKey in batchKeys {batch.append(batchKey)}
//                    batches.append(batch)
//                    NSLog("PROCESSING download batch %i range %i to %i", batchNumber, rangeStart, rangeEnd - 1)
//                }
//                
//                // Download batch
//                var downloadedRecords = [CKRecord]()
//                var batchesRemaining = batches.count
//                for batch in batches {
//                    
//                    let operation = CKFetchRecordsOperation(recordIDs: batch)
//                    operation.qualityOfService = .UserInteractive
//                    operation.fetchRecordsCompletionBlock = { (recordDictionary, error) -> Void in
//                        
//                        if let _error = error {
//                            NSLog("ERROR in %@ - %@", #function, _error)
//                        } else if let _recordDictionary = recordDictionary {
//                            
//                            // Reconstitute batch
//                            for (_, record) in _recordDictionary {
//                                downloadedRecords.append(record)
//                            }
//                        } else {NSLog("ERROR in %@ getting _recordDictionary", #function)}
//                        
//                        batchesRemaining -= 1
//                        if batchesRemaining == 0 {
//                            
//                            // Create/update attributes
//                            for record in downloadedRecords {
//                                self.createOrUpdateObjectWithRecord(record, database: database, context: context, attributes: true)
//                            }
//                            
//                            // Create/update relationships
//                            for record in downloadedRecords {
//                                self.createOrUpdateObjectWithRecord(record, database: database, context: context, attributes: false)
//                            }
//                            
//                            // Update Last Download date for this group
//                            NSLog("All missing record download batches have been processed.")
//                            completion()
//                        } else {NSLog("There are %i download batch(es) remaining.", batchesRemaining)}
//                    }
//                    database.addOperation(operation)
//                }
//            } else {completion()}
//        }
//    }
//    
//    // MARK: - NETWORK CONNECTION
//    func connectedToNetwork () -> Bool {
//        
//        let connected = checkNetwork()
//        if connected == false {
//            self.syncMessage("Sync Skipped (Check Network)")
//        }
//        return connected
//    }
//    func checkNetwork() -> Bool {
//        
//        var zeroAddress = sockaddr_in()
//        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//        
//        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
//            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
//        }) else {
//            return false
//        }
//        
//        var flags : SCNetworkReachabilityFlags = []
//        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
//            return false
//        }
//        
//        let isReachable = flags.contains(.Reachable)
//        let needsConnection = flags.contains(.ConnectionRequired)
//        return (isReachable && !needsConnection)
//    }
//    
//    // MARK: - TRACKING
//    func setDateKey(key:String, date:NSDate) {
//        
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setObject(date, forKey: key)
//        NSLog("%@ has been set to %@", key, date)
//    }
//    func dateKey (key:String) -> NSDate {
//        
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if let object = defaults.objectForKey(key) as? NSDate {
//            return object
//        }
//        let object = NSDate(timeIntervalSince1970: 0) // Default
//        defaults.setObject(object, forKey: key)
//        return object
//    }
//    
//    // MARK: - SYNC
//    var syncRunning = false
//    func syncEntities (entities:[String], database:CKDatabase, context:NSManagedObjectContext) {
//        
//        // Check a sync is not already running
//        if self.syncRunning {
//            NSLog("\n\nSKIPPED SYNC - Sync is already running")
//            return
//        }
//        
//        // Check network before sync attempt
//        if connectedToNetwork() == false {
//            print("CloudKit Sync skipped (network error)")
//            return
//        }
//        
//        // Check iCloud ACcount
//        if CDHelper.shared.iCloudAccountIsSignedIn() == false {
//            NSLog("\n\nSKIPPED SYNC - iCloud Account is NOT signed in.")
//            self.syncMessage("Sync Skipped (Enable iCloud)")
//            return
//        }
//        
//        // Limit Sync calls to once per 10 seconds.
//        let syncLockout = dateKey("SYNC LOCKOUT")
//        if syncLockout.timeIntervalSince1970 > NSDate().timeIntervalSince1970 {
//            NSLog("\n\nSKIPPED SYNC - Sync was performed within the last 10 seconds")
//            self.syncMessage("Synchronized")
//            return
//        }
//        self.setDateKey("SYNC LOCKOUT", date: NSDate(timeIntervalSinceNow: 10))
//        
//        // Sync
//        context.performBlock {
//            context.reset()
//            self.syncRunning = true
//            
//            /*
//            These variables are used to ensure a sync step does not trigger multiple times.
//            This can otherwise happen if queryCompletion blocks return a cursor.
//            This is a fix implemented after the book was released.
//            */
//            var deletedOrphanedCacheObjects = false
//            var uploadedNewRecordsForEntities = false
//            var uploadedChangesForEntities = false
//            var downloadedChangesForEntities = false
//            var qualityCheckEntities = false
//            
//            NSLog("--- SYNC STARTED --- ")
//            self.syncMessage("Starting Sync")
//            self.deleteOrphanedCacheObjects(entities, database: database, context: context, completion: {
//                
//                if deletedOrphanedCacheObjects == true {return} else {deletedOrphanedCacheObjects = true}
//                self.syncMessage("Uploading New Items")
//                self.uploadNewRecordsForEntities(entities, context: context, database: database, completion: {
//                    
//                    if uploadedNewRecordsForEntities == true {return} else {uploadedNewRecordsForEntities = true}
//                    self.syncMessage("Uploading Changes")
//                    self.uploadChangesForEntities(entities, database: database, context: context, completion: {
//                        
//                        if uploadedChangesForEntities == true {return} else {uploadedChangesForEntities = true}
//                        self.syncMessage("Downloading Changes")
//                        self.downloadChangesForEntities(entities, database: database, context: context, completion: {
//                            
//                            if downloadedChangesForEntities == true {return} else {downloadedChangesForEntities = true}
//                            self.syncMessage("Quality Checking")
//                            self.qualityCheckEntities(entities, database: database, context: context, completion: { () -> Void in
//                                
//                                if qualityCheckEntities == true {return} else {qualityCheckEntities = true}
//                                NSLog("--- SYNC FINISHED ---")
//                                
//                                self.cacheStatusForAllObjects(entities, context: context)
//                                self.syncMessage("Synchronized")
//                                self.syncRunning = false
//                                //Item.ensureLocationsAreNotNilForAllItems()
//                                CDHelper.save(CDHelper.shared.importContext)
//                                CDDeduplicator.deDuplicateEntityWithName("Item", uniqueAttributeName: "name", backgroundMoc: CDHelper.shared.importContext)
//                                CDDeduplicator.deDuplicateEntityWithName("Unit", uniqueAttributeName: "name", backgroundMoc: CDHelper.shared.importContext)
//                                CDDeduplicator.deDuplicateEntityWithName("LocationAtHome", uniqueAttributeName: "storedIn", backgroundMoc: CDHelper.shared.importContext)
//                                CDDeduplicator.deDuplicateEntityWithName("LocationAtShop", uniqueAttributeName: "aisle",    backgroundMoc: CDHelper.shared.importContext)
//                                CDThumbnailer.createMissingThumbnails("Item", thumbnailAttribute: "thumbnail", photoRelationship: "photo", photoAttribute: "data", sort: nil, size:CGSizeMake(66, 66), moc: CDHelper.shared.importContext)
//                            })
//                        })
//                    })
//                })
//            })
//        }
//    }
//}
