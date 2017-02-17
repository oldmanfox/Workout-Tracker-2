//
//  CDOperation.swift
//
//  Created by Tim Roadley on 1/10/2015.
//  Copyright © 2015 Tim Roadley. All rights reserved.
//

import Foundation
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CDOperation {
 
    class func objectCountForEntity (_ entityName:String, context:NSManagedObjectContext) -> Int {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //var error:NSError? = nil
        
        do {
            
            let count = try context.count(for: request)
            print("There are \(count) \(entityName) object(s) in \(context)")
            return count
            
        } catch let error as NSError {
            
            print("\(#function) Error: \(error.localizedDescription)")
            return 0
        }
        
        //        let count = context.count(for: request, error: &error)
        //
        //        if let _error = error {
        //            print("\(#function) Error: \(_error.localizedDescription)")
        //        } else {
        //            print("There are \(count) \(entityName) object(s) in \(context)")
        //        }
        //        return count
    }
    
    class func objectsForEntity(_ entityName:String, context:NSManagedObjectContext, filter:NSPredicate?, sort:[NSSortDescriptor]?) -> [AnyObject]? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName:entityName)
        request.predicate = filter
        request.sortDescriptors = sort

        do {
            return try context.fetch(request)
        } catch {
            print("\(#function) FAILED to fetch objects for \(entityName) entity")
            return nil
        }
    }
    
    class func objectName(_ object:NSManagedObject) -> String {
        
        if let name = object.value(forKey: "name") as? String {
            return name
        }
        return object.description
    }
    
    class func objectDeletionIsValid(_ object:NSManagedObject) -> Bool {
        
        do {
            try object.validateForDelete()
            return true // object can be deleted
        } catch let error as NSError {
            print("'\(objectName(object))' can't be deleted. \(error.localizedDescription)")
            return false // object can't be deleted
        }
    }
    
    class func objectWithAttributeValueForEntity(_ entityName:String, context:NSManagedObjectContext, attribute:String, value:String) -> NSManagedObject? {
        
        let predicate = NSPredicate(format: "%K == %@", attribute, value)
        let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicate, sort: nil)
        if let object = objects?.first as? NSManagedObject {
            return object
        }
        return nil
    }
    
    class func predicateForAttributes (_ attributes:[AnyHashable: Any], type:NSCompoundPredicate.LogicalType ) -> NSPredicate? {
            
        // Create an array of predicates, which will be later combined into a compound predicate.
        var predicates:[NSPredicate]?
            
        // Iterate unique attributes in order to create a predicate for each
        for (attribute, value) in attributes {
                
            var predicate:NSPredicate?
                
            // If the value is a string, create the predicate based on a string value
            if let stringValue = value as? String {
                predicate = NSPredicate(format: "%K == %@", attribute as CVarArg, stringValue)
            }
                
            // If the value is a number, create the predicate based on a numerical value
            if let numericalValue = value as? NSNumber {
                predicate = NSPredicate(format: "%K == %@", attribute as CVarArg, numericalValue)
            }
            
            // If the value is a date, create the predicate based on a date value
            if let dateValue = value as? Date {
                predicate = NSPredicate(format: "%K == %@", attribute as CVarArg, dateValue as CVarArg)
            }
                
            // Append new predicate to predicate array, or create it if it doesn't exist yet
            if let newPredicate = predicate {
                if var _predicates = predicates {
                    _predicates.append(newPredicate)
                } else {predicates = [newPredicate]}
            }
        }
            
        // Combine all predicates into a compound predicate
        if let _predicates = predicates {
            return NSCompoundPredicate(type: type, subpredicates: _predicates)
        }
        return nil
    }
    
    class func uniqueObjectWithAttributeValuesForEntity(_ entityName:String, context:NSManagedObjectContext, uniqueAttributes:[AnyHashable: Any]) -> NSManagedObject? {
            
        let predicate = CDOperation.predicateForAttributes(uniqueAttributes, type: .and)
        let objects = CDOperation.objectsForEntity(entityName, context: context, filter: predicate, sort: nil)
            
        if objects?.count > 0 {
            if let object = objects?[0] as? NSManagedObject {
                return object
            }
        }
        return nil
    }
    class func insertUniqueObject(_ entityName:String, context:NSManagedObjectContext, uniqueAttributes:[String:AnyObject], additionalAttributes:[String:AnyObject]?) -> NSManagedObject {
            
        // Return existing object after adding the additional attributes.
        if let existingObject = CDOperation.uniqueObjectWithAttributeValuesForEntity(entityName, context: context, uniqueAttributes: uniqueAttributes) {            
            if let _additionalAttributes = additionalAttributes {
                 existingObject.setValuesForKeys(_additionalAttributes)
            }
            return existingObject
        }
        
        // Create object with given attribute value
        let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        newObject.setValuesForKeys(uniqueAttributes)
        if let _additionalAttributes = additionalAttributes {
            newObject.setValuesForKeys(_additionalAttributes)
        }
        return newObject 
    }
    
    class func saveRepsWithPredicate(_ session: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, reps: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.exercise = exercise
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.reps = reps
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.reps = reps
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.reps = reps
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }

    class func saveWeightWithPredicate(_ session: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, weight: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 workout,
                                 exercise,
                                 index,
                                 round)

        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.exercise = exercise
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.weight = weight
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.weight = weight
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.weight = weight
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func saveNoteWithPredicate(_ session: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, note: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.exercise = exercise
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.notes = note
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.notes = note
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.notes = note
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func saveNoteWithPredicateNoExercise(_ session: String, workout: String, month: String, week: String, index: NSNumber, note: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND index = %@ AND round == %@",
                                 session,
                                 workout,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataHelper.shared().context) as! Workout
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.workout = workout
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.week = week
                    insertWorkoutInfo.round = round
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.notes = note
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutObjects[0]
                    
                    updateWorkoutInfo.notes = note
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutObjects.count {
                        
                        if (index == workoutObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutObjects[index]
                            
                            updateWorkoutInfo.notes = note
                            updateWorkoutInfo.date = Date() as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func getRepWeightTextForExercise(_ session: String, workout: String, exercise: String, index: NSNumber) -> [NSManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortRound, sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise == %@ AND index = %@",
                                 session,
                                 workout,
                                 exercise,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                var workoutArray = [NSManagedObject]()
                
                for outerIndex in 0...2 {
                    
                    var objectsAtIndexArray = [NSManagedObject]()
                    
                    for object in workoutObjects {
                        
                        if self.renameRoundStringToInt(object.round!) == outerIndex {
                            objectsAtIndexArray.append(object)
                        }
                    }
                    
                    if objectsAtIndexArray.count != 0 {
                        
                        workoutArray.append(objectsAtIndexArray.last!)
                    }
                    
                }
                
                return workoutArray
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return []
    }
    
    class func getRepsTextForExerciseRound(_ session: String, workout: String, exercise: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Reps with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round = %@",
                                 session,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    
                    return "0.0"
                    
                case 1:
                    let matchedWorkoutInfo = workoutObjects[0]
                    
                    if matchedWorkoutInfo.reps == nil || matchedWorkoutInfo.reps == ""  {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo.reps
                    }
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    let matchedWorkoutInfo = workoutObjects.last
                    
                    if matchedWorkoutInfo?.reps == nil || matchedWorkoutInfo?.reps == ""  {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo?.reps
                    }
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "0.0"
    }
    
    class func getWeightTextForExerciseRound(_ session: String, workout: String, exercise: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round = %@",
                                 session,
                                 workout,
                                 exercise,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    
                    return "0.0"
                    
                case 1:
                    let matchedWorkoutInfo = workoutObjects[0]
                    
                    if matchedWorkoutInfo.weight == nil || matchedWorkoutInfo.weight == "" {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo.weight
                    }
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    let matchedWorkoutInfo = workoutObjects.last
                    
                    if matchedWorkoutInfo?.weight == nil || matchedWorkoutInfo?.weight == "" {
                        
                        return "0.0"
                    }
                    else {
                        
                        return matchedWorkoutInfo?.weight
                    }
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "0.0"
    }
    
    class func getNotesTextForRound(_ session: String, workout: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND index = %@ AND round = %@",
                                 session,
                                 workout,
                                 index,
                                 round)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                switch workoutObjects.count {
                case 0:
                    // No matches for this object.
                    
                    return ""
                    
                case 1:
                    let matchedWorkoutInfo = workoutObjects[0]
                    
                    return matchedWorkoutInfo.notes
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    let matchedWorkoutInfo = workoutObjects.last
                    
                    return matchedWorkoutInfo!.notes
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return ""
    }
    
    class func getNoteObjects(_ session: NSString, workout: NSString, index: NSNumber) -> [Workout] {
        
        let tempWorkoutCompleteArray = [Workout]()
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND index = %@",
                                 session,
                                 workout,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutNoteObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                // print("workoutNoteObjects.count = \(workoutNoteObjects.count)")
                
                return workoutNoteObjects
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return tempWorkoutCompleteArray
    }
    
    class func getCurrentSession() -> String {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Session")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let sessionObjects = try CoreDataHelper.shared().context.fetch(request) as? [Session] {
                
                // print("sessionObjects.count = \(sessionObjects.count)")
                
                switch sessionObjects.count {
                case 0:
                    // No matches for this object.
                    // Create a new record with the default session - 1
                    let insertSessionInfo = NSEntityDescription.insertNewObject(forEntityName: "Session", into: CoreDataHelper.shared().context) as! Session
                    
                    insertSessionInfo.currentSession = "1"
                    insertSessionInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                    // Return the default session.
                    // Will be 1 until the user changes it in settings tab.
                    return "1"
                    
                case 1:
                    // Found an existing record
                    let matchedSessionInfo = sessionObjects[0]
                    
                    return matchedSessionInfo.currentSession!
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    var sessionString = ""
                    for index in 0..<sessionObjects.count {
                        
                        if (index == sessionObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            
                            let matchedSessionInfo = sessionObjects[index]
                            sessionString = matchedSessionInfo.currentSession!
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(sessionObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    return sessionString
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "1"
    }
    
    class func saveWorkoutCompleteDate(_ session: NSString, workout: NSString, index: NSNumber, useDate: Date) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND index = %@",
                                 session,
                                 workout,
                                 index)
        
        request.predicate = filter

        do {
            if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                
                // print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                
                switch workoutCompleteDateObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "WorkoutCompleteDate", into: CoreDataHelper.shared().context) as! WorkoutCompleteDate
                    
                    insertWorkoutInfo.session = session as String
                    insertWorkoutInfo.workout = workout as String
                    insertWorkoutInfo.index = index
                    insertWorkoutInfo.workoutCompleted = true
                    insertWorkoutInfo.date = useDate as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = workoutCompleteDateObjects[0]
                    
                    updateWorkoutInfo.workoutCompleted = true
                    updateWorkoutInfo.date = useDate as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<workoutCompleteDateObjects.count {
                        
                        if (index == workoutCompleteDateObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = workoutCompleteDateObjects[index]
                            
                            updateWorkoutInfo.workoutCompleted = true
                            updateWorkoutInfo.date = useDate as NSDate?
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(workoutCompleteDateObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()

                }
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func getWorkoutCompletedObjects(_ session: NSString, workout: NSString, index: NSNumber) -> [WorkoutCompleteDate] {
        
        let tempWorkoutCompleteArray = [WorkoutCompleteDate]()
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND index = %@",
                                 session,
                                 workout,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                
                // print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                
                return workoutCompleteDateObjects
                
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return tempWorkoutCompleteArray
    }
    
    class func deleteDate(_ session: NSString, workout: NSString, index: NSNumber) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND workout == %@ AND index = %@",
                                 session,
                                 workout,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutCompleteDateObjects = try CoreDataHelper.shared().context.fetch(request) as? [WorkoutCompleteDate] {
                
                // print("workoutCompleteDateObjects.count = \(workoutCompleteDateObjects.count)")
                
                if workoutCompleteDateObjects.count != 0 {
                    
                    for object in workoutCompleteDateObjects {
                        
                        // Delete all date records for the index.
                        CoreDataHelper.shared().context.delete(object)
                    }
                    CoreDataHelper.shared().backgroundSaveContext()

                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }
    
    class func getMeasurementObjects(_ session: NSString, month: NSString) -> [NSManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Measurement")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND month == %@",
                                 session,
                                 month)
        
        request.predicate = filter
        
        do {
            if let measurementObjects = try CoreDataHelper.shared().context.fetch(request) as? [Measurement] {
                
                // print("measurementObjects.count = \(measurementObjects.count)")
                
                return measurementObjects
                
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return []
    }
    
    class func saveMeasurements(_ session: String, month: String, weight: String, chest: String, waist: String, hips: String, leftArm: String, rightArm: String, leftThigh: String, rightThigh: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Measurement")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND month == %@",
                                 session,
                                 month)
        
        request.predicate = filter
        
        do {
            if let measurementObjects = try CoreDataHelper.shared().context.fetch(request) as? [Measurement] {
                
                // print("measurementObjects.count = \(measurementObjects.count)")
                
                switch measurementObjects.count {
                case 0:
                    // No matches for this object.
                    // Insert a new record
                    // print("No Matches")
                    let insertWorkoutInfo = NSEntityDescription.insertNewObject(forEntityName: "Measurement", into: CoreDataHelper.shared().context) as! Measurement
                    
                    insertWorkoutInfo.session = session
                    insertWorkoutInfo.month = month
                    insertWorkoutInfo.date = Date() as NSDate?
                    
                    if weight != "" {
                        insertWorkoutInfo.weight = weight
                    }
                    
                    if chest != "" {
                        insertWorkoutInfo.chest = chest
                    }
                    
                    if waist != "" {
                        insertWorkoutInfo.waist = waist
                    }
                    
                    if hips != "" {
                        insertWorkoutInfo.hips = hips
                    }
                    
                    if leftArm != "" {
                        insertWorkoutInfo.leftArm = leftArm
                    }
                    
                    if rightArm != "" {
                        insertWorkoutInfo.rightArm = rightArm
                    }
                    
                    if leftThigh != "" {
                        insertWorkoutInfo.leftThigh = leftThigh
                    }
                    
                    if rightThigh != "" {
                        insertWorkoutInfo.rightThigh = rightThigh
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                case 1:
                    // Update existing record
                    
                    let updateWorkoutInfo = measurementObjects[0]
                    
                    updateWorkoutInfo.session = session
                    updateWorkoutInfo.month = month
                    updateWorkoutInfo.date = Date() as NSDate?
                    
                    if weight != "" {
                        updateWorkoutInfo.weight = weight
                    }
                    
                    if chest != "" {
                        updateWorkoutInfo.chest = chest
                    }
                    
                    if waist != "" {
                        updateWorkoutInfo.waist = waist
                    }
                    
                    if hips != "" {
                        updateWorkoutInfo.hips = hips
                    }
                    
                    if leftArm != "" {
                        updateWorkoutInfo.leftArm = leftArm
                    }
                    
                    if rightArm != "" {
                        updateWorkoutInfo.rightArm = rightArm
                    }
                    
                    if leftThigh != "" {
                        updateWorkoutInfo.leftThigh = leftThigh
                    }
                    
                    if rightThigh != "" {
                        updateWorkoutInfo.rightThigh = rightThigh
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                default:
                    // More than one match
                    // Sort by most recent date and delete all but the newest
                    // print("More than one match for object")
                    for index in 0..<measurementObjects.count {
                        
                        if (index == measurementObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            let updateWorkoutInfo = measurementObjects[index]
                            
                            updateWorkoutInfo.session = session
                            updateWorkoutInfo.month = month
                            updateWorkoutInfo.date = Date() as NSDate?
                            
                            if weight != "" {
                                updateWorkoutInfo.weight = weight
                            }
                            
                            if chest != "" {
                                updateWorkoutInfo.chest = chest
                            }
                            
                            if waist != "" {
                                updateWorkoutInfo.waist = waist
                            }
                            
                            if hips != "" {
                                updateWorkoutInfo.hips = hips
                            }
                            
                            if leftArm != "" {
                                updateWorkoutInfo.leftArm = leftArm
                            }
                            
                            if rightArm != "" {
                                updateWorkoutInfo.rightArm = rightArm
                            }
                            
                            if leftThigh != "" {
                                updateWorkoutInfo.leftThigh = leftThigh
                            }
                            
                            if rightThigh != "" {
                                updateWorkoutInfo.rightThigh = rightThigh
                            }
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(measurementObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                }
            }
            
        } catch { print(" ERROR executing a fetch request: \( error)") }
    }

    class func loadWorkoutNameArray() -> [[String]] {
        
        // Normal
        let normal_Week1_WorkoutNameArray = ["Core Fitness",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Complete Fitness & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Strength + Stability",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week2_WorkoutNameArray = ["Core Fitness",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Complete Fitness & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Strength + Stability",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week3_WorkoutNameArray = ["Core Fitness",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Complete Fitness & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Strength + Stability",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week4_WorkoutNameArray = ["Core Fitness",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Complete Fitness & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Strength + Stability",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week5_WorkoutNameArray = ["Chest + Back + Stability & Ab Workout",
                                             "Ab Workout",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Shoulder + Bi + Tri & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Legs + Back & Ab Workout",
                                             "Ab Workout",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week6_WorkoutNameArray = ["Chest + Back + Stability & Ab Workout",
                                             "Ab Workout",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Shoulder + Bi + Tri & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Legs + Back & Ab Workout",
                                             "Ab Workout",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week7_WorkoutNameArray = ["Chest + Back + Stability & Ab Workout",
                                             "Ab Workout",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Shoulder + Bi + Tri & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Legs + Back & Ab Workout",
                                             "Ab Workout",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week8_WorkoutNameArray = ["Chest + Back + Stability & Ab Workout",
                                             "Ab Workout",
                                             "Plyometrics",
                                             "Stretch",
                                             "Rest",
                                             "Shoulder + Bi + Tri & Ab Workout",
                                             "Ab Workout",
                                             "Yoga",
                                             "Legs + Back & Ab Workout",
                                             "Ab Workout",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week9_WorkoutNameArray = ["Lower Agility",
                                             "Upper Agility",
                                             "Yoga",
                                             "Stretch",
                                             "Rest",
                                             "Lower Agility",
                                             "Upper Agility",
                                             "Stretch",
                                             "Rest"]
        
        let normal_Week10_WorkoutNameArray = ["Lower Agility",
                                              "Upper Agility",
                                              "Yoga",
                                              "Stretch",
                                              "Rest",
                                              "Lower Agility",
                                              "Upper Agility",
                                              "Stretch",
                                              "Rest"]
        
        let normal_Week11_WorkoutNameArray = ["Lower Agility",
                                              "Upper Agility",
                                              "Yoga",
                                              "Stretch",
                                              "Rest",
                                              "Lower Agility",
                                              "Upper Agility",
                                              "Stretch",
                                              "Rest"]
        
        let normal_Week12_WorkoutNameArray = ["Lower Agility",
                                              "Upper Agility",
                                              "Yoga",
                                              "Stretch",
                                              "Rest",
                                              "Lower Agility",
                                              "Upper Agility",
                                              "Stretch",
                                              "Rest"]
        
        let normal_Week13_WorkoutNameArray = ["Lower Agility",
                                              "Upper Agility",
                                              "Yoga",
                                              "Stretch",
                                              "Rest",
                                              "Lower Agility",
                                              "Upper Agility",
                                              "Stretch",
                                              "Rest"]
        
        let normal_WorkoutNameArray = [normal_Week1_WorkoutNameArray,
                                       normal_Week2_WorkoutNameArray,
                                       normal_Week3_WorkoutNameArray,
                                       normal_Week4_WorkoutNameArray,
                                       normal_Week5_WorkoutNameArray,
                                       normal_Week6_WorkoutNameArray,
                                       normal_Week7_WorkoutNameArray,
                                       normal_Week8_WorkoutNameArray,
                                       normal_Week9_WorkoutNameArray,
                                       normal_Week10_WorkoutNameArray,
                                       normal_Week11_WorkoutNameArray,
                                       normal_Week12_WorkoutNameArray,
                                       normal_Week13_WorkoutNameArray]
        
        return normal_WorkoutNameArray
    }
    
    class func loadWorkoutIndexArray() -> [[Int]] {
        
        // Normal
        let normal_Week1_WorkoutIndexArray = [1,
                                              1,
                                              1,
                                              1,
                                              1,
                                              1,
                                              1,
                                              1,
                                              2,
                                              2]
        
        let normal_Week2_WorkoutIndexArray = [2,
                                              2,
                                              3,
                                              3,
                                              2,
                                              2,
                                              2,
                                              2,
                                              4,
                                              4]
        
        let normal_Week3_WorkoutIndexArray = [3,
                                              3,
                                              5,
                                              5,
                                              3,
                                              3,
                                              3,
                                              3,
                                              6,
                                              6]
        
        let normal_Week4_WorkoutIndexArray = [4,
                                              4,
                                              7,
                                              7,
                                              4,
                                              4,
                                              4,
                                              4,
                                              8,
                                              8]
        
        let normal_Week5_WorkoutIndexArray = [1,
                                              5,
                                              5,
                                              9,
                                              9,
                                              1,
                                              6,
                                              5,
                                              1,
                                              7,
                                              10,
                                              10]
        
        let normal_Week6_WorkoutIndexArray = [2,
                                              8,
                                              6,
                                              11,
                                              11,
                                              2,
                                              9,
                                              6,
                                              2,
                                              10,
                                              12,
                                              12]
        
        let normal_Week7_WorkoutIndexArray = [3,
                                              11,
                                              7,
                                              13,
                                              13,
                                              3,
                                              12,
                                              7,
                                              3,
                                              13,
                                              14,
                                              14]
        
        let normal_Week8_WorkoutIndexArray = [4,
                                              14,
                                              8,
                                              15,
                                              15,
                                              4,
                                              15,
                                              8,
                                              4,
                                              16,
                                              16,
                                              16]
        
        let normal_Week9_WorkoutIndexArray = [1,
                                              1,
                                              9,
                                              17,
                                              17,
                                              2,
                                              2,
                                              18,
                                              18]
        
        let normal_Week10_WorkoutIndexArray = [3,
                                               3,
                                               10,
                                               19,
                                               19,
                                               4,
                                               4,
                                               20,
                                               20]
        
        let normal_Week11_WorkoutIndexArray = [5,
                                               5,
                                               11,
                                               21,
                                               21,
                                               6,
                                               6,
                                               22,
                                               22]
        
        let normal_Week12_WorkoutIndexArray = [7,
                                               7,
                                               12,
                                               23,
                                               23,
                                               8,
                                               8,
                                               24,
                                               24]
        
        let normal_Week13_WorkoutIndexArray = [9,
                                               9,
                                               13,
                                               25,
                                               25,
                                               10,
                                               10,
                                               26,
                                               26]
        
        let normal_WorkoutIndexArray = [normal_Week1_WorkoutIndexArray,
                                        normal_Week2_WorkoutIndexArray,
                                        normal_Week3_WorkoutIndexArray,
                                        normal_Week4_WorkoutIndexArray,
                                        normal_Week5_WorkoutIndexArray,
                                        normal_Week6_WorkoutIndexArray,
                                        normal_Week7_WorkoutIndexArray,
                                        normal_Week8_WorkoutIndexArray,
                                        normal_Week9_WorkoutIndexArray,
                                        normal_Week10_WorkoutIndexArray,
                                        normal_Week11_WorkoutIndexArray,
                                        normal_Week12_WorkoutIndexArray,
                                        normal_Week13_WorkoutIndexArray]
        
        return normal_WorkoutIndexArray
    }
    
    class func allWorkoutTitleArray() -> [String] {
        
        let workoutTitleArray = ["Core Fitness",
                                 "Plyometrics",
                                 "Complete Fitness & Ab Workout",
                                 "Yoga",
                                 "Strength + Stability",
                                 "Chest + Back + Stability & Ab Workout",
                                 "Shoulder + Bi + Tri & Ab Workout",
                                 "Legs + Back & Ab Workout",
                                 "Lower Agility",
                                 "Upper Agility",
                                 "Ab Workout",
                                 "Stretch",
                                 "Rest"]
        
        return workoutTitleArray
    }
    
    class func allExerciseTitleArray() -> [[String]] {
        
        // Get all the exercise names for each workout
        
        let core_Fitness = ["Sphinx Plank Crunches",
                            "Balance Crunches",
                            "1 Leg Balance to Sphinx",
                            "Side Leg Arm Raises",
                            "V Holds",
                            "Ball Push-Ups",
                            "1 Leg Side to Side Squats",
                            "Sphinx Med Ball Circles",
                            "Jump Lunges",
                            "Weighted Squat Jumps",
                            "Plank Burpees",
                            "Rotating Ball Crunches",
                            "Squat Presses",
                            "Sphinx Med Ball Crunches",
                            "Push-Up to Standing",
                            "Side Sphinx Crunch",
                            "1 Leg Burpee"]

        let plyometrics = [String]()
        
        let complete_Fitness_Ab_Workout = ["Chest Presses",
                                           "4-Way Pull-Ups",
                                           "Push-Up to Arm Balance",
                                           "Lunge Presses",
                                           "Balance Tricep Extensions",
                                           "Balance Curls",
                                           "Stability Ball Push-Ups",
                                           "Pull-Up Crunches",
                                           "Burpee Crunches",
                                           "Balanced Bicep Curl to Shoulder Presses",
                                           "Stability Ball Tricep Extensions",
                                           "Preacher Curls"]
        
        let yoga = [String]()
        
        let strength_Stability = ["Plyometric Sphinx",
                                  "Balanced Plyometric Squats",
                                  "Weighted Crunches",
                                  "Sphinx to Plank",
                                  "4 Square",
                                  "Side Sphinx",
                                  "Decline Sphinx",
                                  "Jump Lunges",
                                  "Plank Crunches",
                                  "Rowing Forearm Balance",
                                  "Hamstring Curls",
                                  "V Crunches",
                                  "Balanced Row to Press",
                                  "Lunges",
                                  "Stability Ball Elbow Presses",
                                  "Side to Side Plyometric Push-Ups",
                                  "Lunge Presses",
                                  "Side Plank Crunches",
                                  "Side Plank Rows",
                                  "Weighted Burpees",
                                  "Plank Crunches on Med Ball"]
        
        let chest_Back_Stability_Ab_Workout = ["Pull-Ups",
                                               "Plyometric Large Ball Push-Ups",
                                               "Underhand Pull-Up Crunches",
                                               "Push-Up to Side Plank",
                                               "Horizontal Pull-Ups",
                                               "4 Point Push-Ups",
                                               "Underhand Pull-Ups",
                                               "2 Point Push-Ups",
                                               "V Pull-Ups",
                                               "3 Point Plyometric Push-Ups",
                                               "Opposite Grip Pull-Ups",
                                               "Balance Push-Ups",
                                               "Wide to Narrow Pull-Ups",
                                               "2 Point Plank Push-Ups",
                                               "4-Way Pull-Ups",
                                               "Wide Push-Ups",
                                               "Wide Pull-Ups",
                                               "Sphinx Push-Ups",
                                               "Uneven Pull-Ups",
                                               "Plyometric Small Ball Push-Ups"]
        
        let shoulder_Bi_Tri_Ab_Workout = ["Pull-Ups",
                                          "Alternating Shoulder Presses",
                                          "Overhead Tricep Extensions",
                                          "Straight Arm Shoulder Flys",
                                          "1 Leg Static Bicep Curls",
                                          "Shoulder Flys",
                                          "Tricep Extensions"]
        
        let legs_Back_Ab_Workout = ["Board Pull-Ups",
                                    "Deep Squat Jumps",
                                    "Close Underhand Pull-Ups",
                                    "Squat Jumps",
                                    "Underhand Pull-Ups",
                                    "Jump Presses",
                                    "Pull-Ups",
                                    "180's",
                                    "Fast Pull-Ups",
                                    "Elbow Touch Jump Squats"]
        
        let lower_Agility = [String]()
        
        let upper_Agility = [String]()
        
        let ab_Workout = [String]()
        
        let stretch = [String]()
        
        let rest = [String]()

        let exerciseTitleArray = [core_Fitness,
                                  plyometrics,
                                  complete_Fitness_Ab_Workout,
                                  yoga,
                                  strength_Stability,
                                  chest_Back_Stability_Ab_Workout,
                                  shoulder_Bi_Tri_Ab_Workout,
                                  legs_Back_Ab_Workout,
                                  lower_Agility,
                                  upper_Agility,
                                  ab_Workout,
                                  stretch,
                                  rest]
        
        return exerciseTitleArray
    }
    
    class func allSessionStringForEmail() -> String {
        
        // Get Data from the database.
        let allWorkoutTitlesArray = self.allWorkoutTitleArray()
        let allExerciseTitlesArray = self.allExerciseTitleArray()
        let writeString = NSMutableString()
        
        // Get the highest session value stored in the database
        let maxSession = Int(self.findMaxSessionValue())
        
        // For each session, list each workouts data.
        // Sessions start at 1.  Cannot have a 0 session.
        for sessionCounter in 1...maxSession! {
            
            // Get session value.
            let currentSessionString = String(sessionCounter)
            
            // Workout
            for i in 0..<allWorkoutTitlesArray.count {
                
                let tempExerciseTitlesArray = allExerciseTitlesArray[i]
                
                // Get workout data with the current session.  Sort by INDEX.
                let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                let sortIndex = NSSortDescriptor( key: "index", ascending: true)
                let sortDate = NSSortDescriptor( key: "date", ascending: true)
                request.sortDescriptors = [sortIndex, sortDate]
                
                let filter = NSPredicate(format: "session == %@ AND workout == %@",
                                         currentSessionString,
                                         allWorkoutTitlesArray[i])
                
                request.predicate = filter
                
                do {
                    if let workoutObjects1 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                        
                        // print("workoutObjects1.count = \(workoutObjects1.count)")
                        
                        var maxIndex = 0
                        
                        if workoutObjects1.count != 0 {
                            
                            maxIndex = Int((workoutObjects1.last?.index)!)
                            
                            var localSession = ""
                            var localWeek = ""
                            var localWorkout = ""
                            var localDate = Date()
                            var dateString = ""
                            
                            var tempExerciseName = ""
                            var tempWeightData = ""
                            var tempRepData = ""
                            var tempNotesData = ""
                            var roundConvertedToString = ""
                            
                            // Get the values for each index that was found for this workout.
                            // Workout indexes start at 1.  Cannot have a 0 index.
                            for index in 1...maxIndex {
                                
                                let convertedIndex = NSNumber(value: index as Int)
                                
                                // Get workout data with workout index
                                let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                                
                                var filter = NSPredicate(format: "session == %@ AND workout == %@ AND index == %@",
                                                         currentSessionString,
                                                         allWorkoutTitlesArray[i],
                                                         convertedIndex)
                                
                                request.predicate = filter
                                
                                do {
                                    if let workoutObjects2 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                        
                                        //print("workoutObjects.count = \(workoutObjects.count)")
                                        
                                        // Check if there are any matches for the given index.  If none skip the index.
                                        if workoutObjects2.count == 0 {
                                            
                                            // No Matches for this workout with index
                                        }
                                        else {
                                            
                                            // Matches found
                                            
                                            // Add column headers
                                            for a in 0..<1 {
                                                
                                                //  Add the column headers for Month, Week, Workout, and Date to the string
                                                writeString.append("Session,Week,Try,Workout,Date\n")
                                                
                                                localSession = workoutObjects2[a].session!
                                                localWeek = workoutObjects2[a].week!
                                                localWorkout = workoutObjects2[a].workout!
                                                localDate = workoutObjects2[a].date! as Date
                                                
                                                dateString = DateFormatter.localizedString(from: localDate, dateStyle: .short, timeStyle: .none)
                                                
                                                // Add column headers for indivialual workouts based on workout index number
                                                writeString.append("\(localSession),\(localWeek),\(index),\(self.trimStringForWorkoutName(localWorkout)),\(dateString)\n")
                                            }
                                            
                                            let workoutIndex = NSNumber(value: index as Int)
                                            
                                            //  Add the exercise name, reps and weight
                                            for b in 0..<tempExerciseTitlesArray.count {
                                                
                                                tempExerciseName = tempExerciseTitlesArray[b]
                                                
                                                //  Add the exercise title to the string
                                                writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Notes\n")
                                                
                                                // Add the "Reps" to the row
                                                writeString.append("Reps,")
                                                
                                                //  Add the reps and notes to the string
                                                for round in 0..<3 {
                                                    
                                                    roundConvertedToString = self.renameRoundIntToString(round)
                                                    tempRepData = ""
                                                    tempNotesData = ""
                                                    
                                                    filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                         currentSessionString,
                                                                         localWorkout,
                                                                         tempExerciseName,
                                                                         roundConvertedToString,
                                                                         workoutIndex)
                                                    
                                                    request.predicate = filter
                                                    
                                                    do {
                                                        if let workoutObjects3 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                            
                                                            //print("workoutObjects.count = \(workoutObjects.count)")
                                                            
                                                            if workoutObjects3.count >= 1 {
                                                                
                                                                // Match found
                                                                
                                                                // Reps is not nil
                                                                if workoutObjects3.last?.reps != nil {
                                                                    
                                                                    tempRepData = (workoutObjects3.last?.reps)!
                                                                    
                                                                    //  Inserts a "" into the string
                                                                    writeString.append("\(tempRepData),")
                                                                }
                                                                else {
                                                                    
                                                                    // There was a record found, but only had data for the weight or notes and not the reps.
                                                                    //  Inserts a "" into the string
                                                                    writeString.append("\(tempRepData),")
                                                                }
                                                            }
                                                            else {
                                                                // No match found
                                                                
                                                                //  Inserts a "" into the string
                                                                writeString.append("\(tempRepData),")
                                                            }
                                                        }
                                                    } catch { print(" ERROR executing a fetch request: \( error)") }
                                                    
                                                    //  Notes
                                                    if round == 2 {
                                                        
                                                        filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                             currentSessionString,
                                                                             localWorkout,
                                                                             tempExerciseName,
                                                                             "Round 1",
                                                                             workoutIndex)
                                                        
                                                        request.predicate = filter
                                                        
                                                        do {
                                                            if let workoutObjectsNotes = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                                
                                                                if workoutObjectsNotes.count >= 1 {
                                                                    
                                                                    //  Match found
                                                                    
                                                                    //  Weight is not nil
                                                                    if workoutObjectsNotes.last?.notes != nil {
                                                                        
                                                                        tempNotesData = (workoutObjectsNotes.last?.notes)!
                                                                        
                                                                        writeString.append("\(tempNotesData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempNotesData)\n")
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    //  No match found
                                                                    
                                                                    writeString.append("\(tempNotesData)\n")
                                                                }
                                                            }
                                                        } catch { print(" ERROR executing a fetch request: \( error)") }
                                                    }
                                                }
                                                
                                                // Add the "Weight" to the row
                                                writeString.append("Weight,")
                                                
                                                //  Add the weight line from the database
                                                for round in 0..<3 {
                                                    
                                                    roundConvertedToString = self.renameRoundIntToString(round)
                                                    tempWeightData = ""
                                                    
                                                    filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                         currentSessionString,
                                                                         localWorkout,
                                                                         tempExerciseName,
                                                                         roundConvertedToString,
                                                                         workoutIndex)
                                                    
                                                    request.predicate = filter
                                                    
                                                    do {
                                                        if let workoutObjects4 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                            
                                                            //print("workoutObjects.count = \(workoutObjects.count)")
                                                            
                                                            if workoutObjects4.count >= 1 {
                                                                
                                                                //  Match found
                                                                
                                                                //  Weight is not nil
                                                                if workoutObjects4.last?.weight != nil {
                                                                    
                                                                    tempWeightData = (workoutObjects4.last?.weight)!
                                                                    
                                                                    if round == 2 {
                                                                        
                                                                        writeString.append("\(tempWeightData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempWeightData),")
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    //  There was a record found, but only had data for the reps or notes and not the weight.
                                                                    if round == 2 {
                                                                        
                                                                        writeString.append("\(tempWeightData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempWeightData),")
                                                                    }
                                                                }
                                                            }
                                                            else {
                                                                
                                                                //  No Weight
                                                                //  Inserts a "" into the string
                                                                if round == 2 {
                                                                    
                                                                    writeString.append("\(tempWeightData)\n")
                                                                }
                                                                else {
                                                                    
                                                                    writeString.append("\(tempWeightData),")
                                                                }
                                                            }
                                                        }
                                                    } catch { print(" ERROR executing a fetch request: \( error)") }
                                                }
                                            }
                                        }
                                        
                                        //  Ends the workout with a return mark \n before starting the next workout
                                        writeString.append(",\n")
                                        
                                    }
                                } catch { print(" ERROR executing a fetch request: \( error)") }
                            }
                        }
                    }
                } catch { print(" ERROR executing a fetch request: \( error)") }
            }
        }
        
        //  Return the string
        return writeString as String
    }
    
    class func currentSessionStringForEmail() -> String {
        
        // Get Data from the database.
        let allWorkoutTitlesArray = self.allWorkoutTitleArray()
        let allExerciseTitlesArray = self.allExerciseTitleArray()
        let writeString = NSMutableString()
        
        // Get the current session value stored in the database
        let currentSessionString = self.getCurrentSession()
            
        // Workout
        for i in 0..<allWorkoutTitlesArray.count {
            
            let tempExerciseTitlesArray = allExerciseTitlesArray[i]
            
            // Get workout data with the current session.  Sort by INDEX.
            let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
            let sortIndex = NSSortDescriptor( key: "index", ascending: true)
            let sortDate = NSSortDescriptor( key: "date", ascending: true)
            request.sortDescriptors = [sortIndex, sortDate]
            
            let filter = NSPredicate(format: "session == %@ AND workout == %@",
                                     currentSessionString,
                                     allWorkoutTitlesArray[i])
            
            request.predicate = filter
            
            do {
                if let workoutObjects1 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                    
                    // print("workoutObjects1.count = \(workoutObjects1.count)")
                    
                    var maxIndex = 0
                    
                    if workoutObjects1.count != 0 {
                        
                        maxIndex = Int((workoutObjects1.last?.index)!)
                        
                        var localSession = ""
                        var localWeek = ""
                        var localWorkout = ""
                        var localDate = Date()
                        var dateString = ""
                        
                        var tempExerciseName = ""
                        var tempWeightData = ""
                        var tempRepData = ""
                        var tempNotesData = ""
                        var roundConvertedToString = ""
                        
                        // Get the values for each index that was found for this workout.
                        // Workout indexes start at 1.  Cannot have a 0 index.
                        for index in 1...maxIndex {
                            
                            let convertedIndex = NSNumber(value: index as Int)
                            
                            // Get workout data with workout index
                            let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                            
                            var filter = NSPredicate(format: "session == %@ AND workout == %@ AND index == %@",
                                                     currentSessionString,
                                                     allWorkoutTitlesArray[i],
                                                     convertedIndex)
                            
                            request.predicate = filter
                            
                            do {
                                if let workoutObjects2 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                    
                                    //print("workoutObjects.count = \(workoutObjects.count)")
                                    
                                    // Check if there are any matches for the given index.  If none skip the index.
                                    if workoutObjects2.count == 0 {
                                        
                                        // No Matches for this workout with index
                                    }
                                    else {
                                        
                                        // Matches found
                                        
                                        // Add column headers
                                        for a in 0..<1 {
                                            
                                            //  Add the column headers for Month, Week, Workout, and Date to the string
                                            writeString.append("Session,Week,Try,Workout,Date\n")
                                            
                                            localSession = workoutObjects2[a].session!
                                            localWeek = workoutObjects2[a].week!
                                            localWorkout = workoutObjects2[a].workout!
                                            localDate = workoutObjects2[a].date! as Date
                                            
                                            dateString = DateFormatter.localizedString(from: localDate, dateStyle: .short, timeStyle: .none)
                                            
                                            // Add column headers for indivialual workouts based on workout index number
                                            writeString.append("\(localSession),\(localWeek),\(index),\(self.trimStringForWorkoutName(localWorkout)),\(dateString)\n")
                                        }
                                        
                                        let workoutIndex = NSNumber(value: index as Int)
                                        
                                        //  Add the exercise name, reps and weight
                                        for b in 0..<tempExerciseTitlesArray.count {
                                            
                                            tempExerciseName = tempExerciseTitlesArray[b]
                                            
                                            //  Add the exercise title to the string
                                            writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Notes\n")
                                            
                                            // Add the "Reps" to the row
                                            writeString.append("Reps,")
                                            
                                            //  Add the reps and notes to the string
                                            for round in 0..<3 {
                                                
                                                roundConvertedToString = self.renameRoundIntToString(round)
                                                tempRepData = ""
                                                tempNotesData = ""
                                                
                                                filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                     currentSessionString,
                                                                     localWorkout,
                                                                     tempExerciseName,
                                                                     roundConvertedToString,
                                                                     workoutIndex)
                                                
                                                request.predicate = filter
                                                
                                                do {
                                                    if let workoutObjects3 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                        
                                                        //print("workoutObjects.count = \(workoutObjects.count)")
                                                        
                                                        if workoutObjects3.count >= 1 {
                                                            
                                                            // Match found
                                                            
                                                            // Reps is not nil
                                                            if workoutObjects3.last?.reps != nil {
                                                                
                                                                tempRepData = (workoutObjects3.last?.reps)!
                                                                
                                                                //  Inserts a "" into the string
                                                                writeString.append("\(tempRepData),")
                                                                }
                                                            else {
                                                                
                                                                // There was a record found, but only had data for the weight or notes and not the reps.
                                                                //  Inserts a "" into the string
                                                                writeString.append("\(tempRepData),")
                                                            }
                                                        }
                                                        else {
                                                            // No match found
                                                            
                                                            //  Inserts a "" into the string
                                                            writeString.append("\(tempRepData),")
                                                        }
                                                    }
                                                } catch { print(" ERROR executing a fetch request: \( error)") }
                                                
                                                //  Notes
                                                if round == 2 {
                                                    
                                                    filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                         currentSessionString,
                                                                         localWorkout,
                                                                         tempExerciseName,
                                                                         "Round 1",
                                                                         workoutIndex)
                                                    
                                                    request.predicate = filter
                                                    
                                                    do {
                                                        if let workoutObjectsNotes = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                            
                                                            if workoutObjectsNotes.count >= 1 {
                                                                
                                                                //  Match found
                                                                
                                                                //  Weight is not nil
                                                                if workoutObjectsNotes.last?.notes != nil {
                                                                    
                                                                    tempNotesData = (workoutObjectsNotes.last?.notes)!
                                                                    
                                                                    writeString.append("\(tempNotesData)\n")
                                                                }
                                                                else {
                                                                    
                                                                    writeString.append("\(tempNotesData)\n")
                                                                }
                                                            }
                                                            else {
                                                                
                                                                //  No match found
                                                                
                                                                writeString.append("\(tempNotesData)\n")
                                                            }
                                                        }
                                                    } catch { print(" ERROR executing a fetch request: \( error)") }
                                                }
                                            }
                                            
                                            // Add the "Weight" to the row
                                            writeString.append("Weight,")
                                            
                                            //  Add the weight line from the database
                                            for round in 0..<3 {
                                                
                                                roundConvertedToString = self.renameRoundIntToString(round)
                                                tempWeightData = ""
                                                
                                                filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                     currentSessionString,
                                                                     localWorkout,
                                                                     tempExerciseName,
                                                                     roundConvertedToString,
                                                                     workoutIndex)
                                                
                                                request.predicate = filter
                                                
                                                do {
                                                    if let workoutObjects4 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                                        
                                                        //print("workoutObjects.count = \(workoutObjects.count)")
                                                        
                                                        if workoutObjects4.count >= 1 {
                                                            
                                                            //  Match found
                                                            
                                                            //  Weight is not nil
                                                            if workoutObjects4.last?.weight != nil {
                                                                
                                                                tempWeightData = (workoutObjects4.last?.weight)!
                                                                
                                                                if round == 2 {
                                                                    
                                                                    writeString.append("\(tempWeightData)\n")
                                                                }
                                                                else {
                                                                    
                                                                    writeString.append("\(tempWeightData),")
                                                                }
                                                            }
                                                            else {
                                                                
                                                                //  There was a record found, but only had data for the reps or notes and not the weight.
                                                                if round == 2 {
                                                                    
                                                                    writeString.append("\(tempWeightData)\n")
                                                                }
                                                                else {
                                                                    
                                                                    writeString.append("\(tempWeightData),")
                                                                }
                                                            }
                                                        }
                                                        else {
                                                            
                                                            //  No Weight
                                                            //  Inserts a "" into the string
                                                            if round == 2 {
                                                                
                                                                writeString.append("\(tempWeightData)\n")
                                                            }
                                                            else {
                                                                
                                                                writeString.append("\(tempWeightData),")
                                                            }
                                                        }
                                                    }
                                                } catch { print(" ERROR executing a fetch request: \( error)") }
                                            }
                                        }
                                    }
                                    
                                    //  Ends the workout with a return mark \n before starting the next workout
                                    writeString.append(",\n")
                                    
                                }
                            } catch { print(" ERROR executing a fetch request: \( error)") }
                        }
                    }
                }
            } catch { print(" ERROR executing a fetch request: \( error)") }
        }
        
        //  Return the string
        return writeString as String
    }
    
    class func singleWorkoutStringForEmail(_ workoutName: String, index: Int) -> String {
        
        let writeString = NSMutableString()
        
        let localAllWorkoutTitleArray = self.allWorkoutTitleArray()
        let localAllExerciseTitleArray = self.allExerciseTitleArray()
        var exerciseTitleArray = [String]()
        
        for arrayIndex in 0..<localAllWorkoutTitleArray.count {
            
            if workoutName == localAllWorkoutTitleArray[arrayIndex] {
                
                exerciseTitleArray = localAllExerciseTitleArray[arrayIndex]
            }
        }
        
        // Get the current session value stored in the database
        let currentSessionString = self.getCurrentSession()

        // Convert the index Int into an NSNumber
        let convertedIndex = NSNumber(value: index as Int)
        
        // Get workout data with workout index
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        
        var filter = NSPredicate(format: "session == %@ AND workout == %@ AND index == %@",
                                 currentSessionString,
                                 workoutName,
                                 convertedIndex)
        
        request.predicate = filter
        
        do {
            if let workoutObjects2 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                // Check if there are any matches for the given index.  If none skip the index.
                if workoutObjects2.count == 0 {
                    
                    // No Matches for this workout with index
                }
                else {
                    
                    // Matches found
                    
                    // Add column headers
                    for a in 0..<1 {
                        
                        //  Add the column headers for Month, Week, Workout, and Date to the string
                        writeString.append("Session,Week,Try,Workout,Date\n")
                        
                        let localSession = workoutObjects2[a].session!
                        let localWeek = workoutObjects2[a].week!
                        let localWorkout = self.trimStringForWorkoutName(workoutObjects2[a].workout!) 
                        let localDate = workoutObjects2[a].date!
                        
                        let dateString = DateFormatter.localizedString(from: localDate as Date, dateStyle: .short, timeStyle: .none)
                        
                        // Add column headers for indivialual workouts based on workout index number
                        writeString.append("\(localSession),\(localWeek),\(index),\(localWorkout),\(dateString)\n")
                    }
                    
                    //  Add the exercise name, reps and weight
                    for b in 0..<exerciseTitleArray.count {
                        
                        let tempExerciseName = exerciseTitleArray[b] 
                        
                        //  Add the exercise title to the string
                        writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, Round 3, Notes\n")
                        
                        // Add the "Reps" to the row
                        writeString.append("Reps,")
                        
                        //  Add the reps and notes to the string
                        for round in 0..<3 {
                            
                            let roundConvertedToString = self.renameRoundIntToString(round)
                            var tempRepData = ""
                            var tempNotesData = ""
                            
                            filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                 currentSessionString,
                                                 workoutName,
                                                 tempExerciseName,
                                                 roundConvertedToString,
                                                 convertedIndex)
                            
                            request.predicate = filter
                            
                            do {
                                if let workoutObjects3 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                    
                                    //print("workoutObjects.count = \(workoutObjects.count)")
                                    
                                    if workoutObjects3.count >= 1 {
                                        
                                        // Match found
                                        
                                        // Reps is not nil
                                        if workoutObjects3.last?.reps != nil {
                                            
                                            tempRepData = (workoutObjects3.last?.reps)!
                                            
                                            //  Inserts a "" into the string
                                            writeString.append("\(tempRepData),")
                                        }
                                        else {
                                            
                                            // There was a record found, but only had data for the weight or notes and not the reps.
                                            
                                            //  Inserts a "" into the string
                                            writeString.append("\(tempRepData),")
                                        }
                                    }
                                    else {
                                        // No match found
                                        // Inserts a "" into the string
                                        writeString.append("\(tempRepData),")
                                    }
                                }
                            } catch { print(" ERROR executing a fetch request: \( error)") }
                            
                            //  Notes
                            if round == 2 {
                                
                                filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                     currentSessionString,
                                                     workoutName,
                                                     tempExerciseName,
                                                     "Round 1",
                                                     convertedIndex)
                                
                                request.predicate = filter
                                
                                do {
                                    if let workoutObjectsNotes = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                        
                                        if workoutObjectsNotes.count >= 1 {
                                            
                                            //  Match found
                                            
                                            //  Weight is not nil
                                            if workoutObjectsNotes.last?.notes != nil {
                                                
                                                tempNotesData = (workoutObjectsNotes.last?.notes)!
                                                
                                                writeString.append("\(tempNotesData)\n")
                                            }
                                            else {
                                                
                                                writeString.append("\(tempNotesData)\n")
                                            }
                                        }
                                        else {
                                            
                                            //  No match found
                                            
                                            writeString.append("\(tempNotesData)\n")
                                        }
                                    }
                                } catch { print(" ERROR executing a fetch request: \( error)") }
                            }
                        }
                        
                        // Add the "Weight" to the row
                        writeString.append("Weight,")
                        
                        //  Add the weight line from the database
                        for round in 0..<3 {
                            
                            let roundConvertedToString = self.renameRoundIntToString(round)
                            var tempWeightData = ""
                            
                            filter = NSPredicate(format: "session == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                 currentSessionString,
                                                 workoutName,
                                                 tempExerciseName,
                                                 roundConvertedToString,
                                                 convertedIndex)
                            
                            request.predicate = filter
                            
                            do {
                                if let workoutObjects4 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                                    
                                    //print("workoutObjects.count = \(workoutObjects.count)")
                                    
                                    if workoutObjects4.count >= 1 {
                                        
                                        //  Match found
                                        
                                        //  Weight is not nil
                                        if workoutObjects4.last?.weight != nil {
                                            
                                            tempWeightData = (workoutObjects4.last?.weight)!
                                            
                                            if round == 2 {
                                                
                                                writeString.append("\(tempWeightData)\n")
                                            }
                                            else {
                                                
                                                writeString.append("\(tempWeightData),")
                                            }
                                        }
                                        else {
                                            
                                            //  There was a record found, but only had data for the reps or notes and not the weight.
                                            if round == 2 {
                                                
                                                writeString.append("\(tempWeightData)\n")
                                            }
                                            else {
                                                
                                                writeString.append("\(tempWeightData),")
                                            }
                                        }
                                    }
                                    else {
                                        
                                        //  No Weight
                                        //  Inserts a "" into the string
                                        if round == 2 {
                                            
                                            writeString.append("\(tempWeightData)\n")
                                        }
                                        else {
                                            
                                            writeString.append("\(tempWeightData),")
                                        }
                                    }
                                }
                            } catch { print(" ERROR executing a fetch request: \( error)") }
                        }
                    }
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        //  Return the string
        return writeString as String
    }

    class func findMaxSessionValue() -> String {
        
        // Workout Entity
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortSession = NSSortDescriptor( key: "session", ascending: true)
        
        request.sortDescriptors = [sortSession]
        
        var maxSessionString = "1"
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                maxSessionString = (workoutObjects.last?.session)!
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return maxSessionString
    }
    
    class func trimStringForWorkoutName(_ originalString: String) -> String {
        
        switch originalString {
            
        case originalString where originalString.hasSuffix(" & Ab Workout"):
            
            return (originalString as NSString).substring(to: (originalString as NSString).length - 13)
            
        case originalString where originalString.hasSuffix(" or Rest"):
            
            return (originalString as NSString).substring(to: (originalString as NSString).length - 8)
            
        default:
            return originalString
            
        }
    }
    
    class func renameRoundIntToString(_ roundInt: Int) -> String {
        
        switch roundInt {
        case 0:
            return "Round 1"
            
        case 1:
            return "Round 2"
            
        default:
            // Round 3
            return "Round 3"
        }
    }
    
    class func renameRoundStringToInt(_ roundString: String) -> Int {
        
        switch roundString {
        case "Round 1":
            return 0
            
        case "Round 2":
            return 1
            
        default:
            // Round 3
            return 2
        }
    }
}
