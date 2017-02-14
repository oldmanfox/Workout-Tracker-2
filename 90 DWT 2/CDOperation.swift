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
                    //insertWorkoutInfo.routine = routine
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

    class func saveWeightWithPredicate(_ session: String, routine: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, weight: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 routine,
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
                    insertWorkoutInfo.routine = routine
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
    
    class func saveNoteWithPredicate(_ session: String, routine: String, workout: String, month: String, week: String, exercise: String, index: NSNumber, note: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round == %@",
                                 session,
                                 routine,
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
                    insertWorkoutInfo.routine = routine
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
    
    class func saveNoteWithPredicateNoExercise(_ session: String, routine: String, workout: String, month: String, week: String, index: NSNumber, note: String, round: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortExercise = NSSortDescriptor(key: "exercise", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let sortWorkout = NSSortDescriptor(key: "workout", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sortWorkout, sortExercise, sortRound]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@ AND round == %@",
                                 session,
                                 routine,
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
                    insertWorkoutInfo.routine = routine
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
    
    class func getRepWeightTextForExercise(_ session: String, routine: String, workout: String, exercise: String, index: NSNumber) -> [NSManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortRound = NSSortDescriptor( key: "round", ascending: true)
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortRound, sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@",
                                 session,
                                 routine,
                                 workout,
                                 exercise,
                                 index)
        
        request.predicate = filter
        
        do {
            if let workoutObjects = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                
                //print("workoutObjects.count = \(workoutObjects.count)")
                
                var workoutArray = [NSManagedObject]()
                
                for outerIndex in 0...1 {
                    
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
    
    class func getRepsTextForExerciseRound(_ session: String, routine: String, workout: String, exercise: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Reps with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round = %@",
                                 session,
                                 routine,
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
                    
                    return matchedWorkoutInfo.reps
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    let matchedWorkoutInfo = workoutObjects.last
                    
                    return matchedWorkoutInfo!.reps
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }
        
        return "0.0"
    }
    
    class func getWeightTextForExerciseRound(_ session: String, routine: String, workout: String, exercise: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise == %@ AND index = %@ AND round = %@",
                                 session,
                                 routine,
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
    
    class func getNotesTextForRound(_ session: String, routine: String, workout: String, round: String, index: NSNumber) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        // Weight with index and round
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@ AND round = %@",
                                 session,
                                 routine,
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
    
    class func getNoteObjects(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber) -> [Workout] {
        
        let tempWorkoutCompleteArray = [Workout]()
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
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
    
    class func getCurrentRoutine() -> String {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Routine")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        do {
            if let routineObjects = try CoreDataHelper.shared().context.fetch(request) as? [Routine] {
                
                // print("routineObjects.count = \(routineObjects.count)")
                
                switch routineObjects.count {
                case 0:
                    // No matches for this object.
                    // Create a new record with the default routine - Normal
                    let insertRoutineInfo = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataHelper.shared().context) as! Routine
                    
                    insertRoutineInfo.defaultRoutine = "Normal"
                    insertRoutineInfo.date = Date() as NSDate?
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    
                    // Return the default routine.
                    // Will be Normal until the user changes it in settings tab.
                    return "Normal"
                    
                case 1:
                    // Found an existing record
                    let matchedRoutineInfo = routineObjects[0]
                    
                    return matchedRoutineInfo.defaultRoutine!
                    
                default:
                    // More than one match
                    // Sort by most recent date and pick the newest
                    // print("More than one match for object")
                    var routineString = ""
                    for index in 0..<routineObjects.count {
                        
                        if (index == routineObjects.count - 1) {
                            // Get data from the newest existing record.  Usually the last record sorted by date.
                            
                            let matchedRoutineInfo = routineObjects[index]
                            routineString = matchedRoutineInfo.defaultRoutine!
                        }
                        else {
                            // Delete duplicate records.
                            CoreDataHelper.shared().context.delete(routineObjects[index])
                        }
                    }
                    
                    CoreDataHelper.shared().backgroundSaveContext()
                    return routineString
                }
            }
        } catch { print(" ERROR executing a fetch request: \( error)") }

        return "Normal"
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
                    
                    // Return the default routine.
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
    
    class func saveWorkoutCompleteDate(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber, useDate: Date) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
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
                    insertWorkoutInfo.routine = routine as String
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
    
    class func getWorkoutCompletedObjects(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber) -> [WorkoutCompleteDate] {
        
        let tempWorkoutCompleteArray = [WorkoutCompleteDate]()
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
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
    
    class func deleteDate(_ session: NSString, routine: NSString, workout: NSString, index: NSNumber) {
        
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "WorkoutCompleteDate")
        let sortDate = NSSortDescriptor( key: "date", ascending: true)
        request.sortDescriptors = [sortDate]
        
        let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index = %@",
                                 session,
                                 routine,
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
        
        switch getCurrentRoutine() {
        case "Normal":
            // Normal
            let normal_Week1_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Plyometrics",
                                                 "Shoulders + Arms & Ab Workout",
                                                 "Ab Workout",
                                                 "Yoga",
                                                 "Legs + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week2_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Plyometrics",
                                                 "Shoulders + Arms & Ab Workout",
                                                 "Ab Workout",
                                                 "Yoga",
                                                 "Legs + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week3_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Plyometrics",
                                                 "Shoulders + Arms & Ab Workout",
                                                 "Ab Workout",
                                                 "Yoga",
                                                 "Legs + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week4_WorkoutNameArray = ["Yoga",
                                                 "Core Fitness",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Core Fitness",
                                                 "Yoga",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week5_WorkoutNameArray = ["Chest + Shoulders + Tri & Ab Workout",
                                                 "Ab Workout",
                                                 "Plyometrics",
                                                 "Back + Biceps & Ab Workout",
                                                 "Ab Workout",
                                                 "Yoga",
                                                 "Legs + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week6_WorkoutNameArray = ["Chest + Shoulders + Tri & Ab Workout",
                                                 "Ab Workout",
                                                 "Plyometrics",
                                                 "Back + Biceps & Ab Workout",
                                                 "Ab Workout",
                                                 "Yoga",
                                                 "Legs + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week7_WorkoutNameArray = ["Chest + Shoulders + Tri & Ab Workout",
                                                 "Ab Workout",
                                                 "Plyometrics",
                                                 "Back + Biceps & Ab Workout",
                                                 "Ab Workout",
                                                 "Yoga",
                                                 "Legs + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week8_WorkoutNameArray = ["Yoga",
                                                 "Core Fitness",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Core Fitness",
                                                 "Yoga",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week9_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Plyometrics",
                                                 "Shoulders + Arms & Ab Workout",
                                                 "Ab Workout",
                                                 "Yoga",
                                                 "Legs + Back & Ab Workout",
                                                 "Ab Workout",
                                                 "Judo Chop",
                                                 "Stretch or Rest",
                                                 "Rest"]
            
            let normal_Week10_WorkoutNameArray = ["Chest + Shoulders + Tri & Ab Workout",
                                                  "Ab Workout",
                                                  "Plyometrics",
                                                  "Back + Biceps & Ab Workout",
                                                  "Ab Workout",
                                                  "Yoga",
                                                  "Legs + Back & Ab Workout",
                                                  "Ab Workout",
                                                  "Judo Chop",
                                                  "Stretch or Rest",
                                                  "Rest"]
            
            let normal_Week11_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                  "Ab Workout",
                                                  "Plyometrics",
                                                  "Shoulders + Arms & Ab Workout",
                                                  "Ab Workout",
                                                  "Yoga",
                                                  "Legs + Back & Ab Workout",
                                                  "Ab Workout",
                                                  "Judo Chop",
                                                  "Stretch or Rest",
                                                  "Rest"]
            
            let normal_Week12_WorkoutNameArray = ["Chest + Shoulders + Tri & Ab Workout",
                                                  "Ab Workout",
                                                  "Plyometrics",
                                                  "Back + Biceps & Ab Workout",
                                                  "Ab Workout",
                                                  "Yoga",
                                                  "Legs + Back & Ab Workout",
                                                  "Ab Workout",
                                                  "Judo Chop",
                                                  "Stretch or Rest",
                                                  "Rest"]
            
            let normal_Week13_WorkoutNameArray = ["Yoga",
                                                  "Core Fitness",
                                                  "Judo Chop",
                                                  "Stretch or Rest",
                                                  "Core Fitness",
                                                  "Yoga",
                                                  "Stretch or Rest",
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
            
        case "Tone":
            // Tone
            let tone_Week1_WorkoutNameArray = ["Core Fitness",
                                               "Full on Cardio",
                                               "Shoulders + Arms & Ab Workout",
                                               "Ab Workout",
                                               "Yoga",
                                               "Legs + Back & Ab Workout",
                                               "Ab Workout",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week2_WorkoutNameArray = ["Core Fitness",
                                               "Full on Cardio",
                                               "Shoulders + Arms & Ab Workout",
                                               "Ab Workout",
                                               "Yoga",
                                               "Legs + Back & Ab Workout",
                                               "Ab Workout",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week3_WorkoutNameArray = ["Core Fitness",
                                               "Full on Cardio",
                                               "Shoulders + Arms & Ab Workout",
                                               "Ab Workout",
                                               "Yoga",
                                               "Legs + Back & Ab Workout",
                                               "Ab Workout",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week4_WorkoutNameArray = ["Yoga",
                                               "Core Fitness",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Core Fitness",
                                               "Yoga",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week5_WorkoutNameArray = ["Core Fitness",
                                               "Full on Cardio",
                                               "Chest + Shoulders + Tri & Ab Workout",
                                               "Ab Workout",
                                               "Yoga",
                                               "Legs + Back & Ab Workout",
                                               "Ab Workout",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week6_WorkoutNameArray = ["Core Fitness",
                                               "Full on Cardio",
                                               "Chest + Shoulders + Tri & Ab Workout",
                                               "Ab Workout",
                                               "Yoga",
                                               "Legs + Back & Ab Workout",
                                               "Ab Workout",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week7_WorkoutNameArray = ["Core Fitness",
                                               "Full on Cardio",
                                               "Chest + Shoulders + Tri & Ab Workout",
                                               "Ab Workout",
                                               "Yoga",
                                               "Legs + Back & Ab Workout",
                                               "Ab Workout",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week8_WorkoutNameArray = ["Yoga",
                                               "Core Fitness",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Full on Cardio",
                                               "Yoga",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week9_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                               "Ab Workout",
                                               "Full on Cardio",
                                               "Shoulders + Arms & Ab Workout",
                                               "Ab Workout",
                                               "Yoga",
                                               "Core Fitness",
                                               "Judo Chop",
                                               "Stretch or Rest",
                                               "Rest"]
            
            let tone_Week10_WorkoutNameArray = ["Chest + Shoulders + Tri & Ab Workout",
                                                "Ab Workout",
                                                "Full on Cardio",
                                                "Back + Biceps & Ab Workout",
                                                "Ab Workout",
                                                "Yoga",
                                                "Core Fitness",
                                                "Judo Chop",
                                                "Stretch or Rest",
                                                "Rest"]
            
            let tone_Week11_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                "Ab Workout",
                                                "Full on Cardio",
                                                "Shoulders + Arms & Ab Workout",
                                                "Ab Workout",
                                                "Yoga",
                                                "Core Fitness",
                                                "Judo Chop",
                                                "Stretch or Rest",
                                                "Rest"]
            
            let tone_Week12_WorkoutNameArray = ["Chest + Shoulders + Tri & Ab Workout",
                                                "Ab Workout",
                                                "Full on Cardio",
                                                "Back + Biceps & Ab Workout",
                                                "Ab Workout",
                                                "Yoga",
                                                "Core Fitness",
                                                "Judo Chop",
                                                "Stretch or Rest",
                                                "Rest"]
            
            let tone_Week13_WorkoutNameArray = ["Yoga",
                                                "Core Fitness",
                                                "Judo Chop",
                                                "Stretch or Rest",
                                                "Full on Cardio",
                                                "Yoga",
                                                "Stretch or Rest",
                                                "Rest"]
            
            let tone_WorkoutNameArray = [tone_Week1_WorkoutNameArray,
                                         tone_Week2_WorkoutNameArray,
                                         tone_Week3_WorkoutNameArray,
                                         tone_Week4_WorkoutNameArray,
                                         tone_Week5_WorkoutNameArray,
                                         tone_Week6_WorkoutNameArray,
                                         tone_Week7_WorkoutNameArray,
                                         tone_Week8_WorkoutNameArray,
                                         tone_Week9_WorkoutNameArray,
                                         tone_Week10_WorkoutNameArray,
                                         tone_Week11_WorkoutNameArray,
                                         tone_Week12_WorkoutNameArray,
                                         tone_Week13_WorkoutNameArray]
            
            return tone_WorkoutNameArray
            
        default:
            // 2-A-Days
            let two_A_Days_Week1_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Plyometrics",
                                                     "Shoulders + Arms & Ab Workout",
                                                     "Ab Workout",
                                                     "Yoga",
                                                     "Legs + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week2_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Plyometrics",
                                                     "Shoulders + Arms & Ab Workout",
                                                     "Ab Workout",
                                                     "Yoga",
                                                     "Legs + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week3_WorkoutNameArray = ["Chest + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Plyometrics",
                                                     "Shoulders + Arms & Ab Workout",
                                                     "Ab Workout",
                                                     "Yoga",
                                                     "Legs + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week4_WorkoutNameArray = ["Yoga",
                                                     "Core Fitness",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Core Fitness",
                                                     "Yoga",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week5_WorkoutNameArray = ["Full on Cardio",
                                                     "Chest + Shoulders + Tri & Ab Workout",
                                                     "Ab Workout",
                                                     "Plyometrics",
                                                     "Full on Cardio",
                                                     "Back + Biceps & Ab Workout",
                                                     "Ab Workout",
                                                     "Yoga",
                                                     "Full on Cardio",
                                                     "Legs + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week6_WorkoutNameArray = ["Full on Cardio",
                                                     "Chest + Shoulders + Tri & Ab Workout",
                                                     "Ab Workout",
                                                     "Plyometrics",
                                                     "Full on Cardio",
                                                     "Back + Biceps & Ab Workout",
                                                     "Ab Workout",
                                                     "Yoga",
                                                     "Full on Cardio",
                                                     "Legs + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week7_WorkoutNameArray = ["Full on Cardio",
                                                     "Chest + Shoulders + Tri & Ab Workout",
                                                     "Ab Workout",
                                                     "Plyometrics",
                                                     "Full on Cardio",
                                                     "Back + Biceps & Ab Workout",
                                                     "Ab Workout",
                                                     "Yoga",
                                                     "Full on Cardio",
                                                     "Legs + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week8_WorkoutNameArray = ["Yoga",
                                                     "Core Fitness",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Core Fitness",
                                                     "Yoga",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week9_WorkoutNameArray = ["Full on Cardio",
                                                     "Chest + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Full on Cardio",
                                                     "Plyometrics",
                                                     "Shoulders + Arms & Ab Workout",
                                                     "Ab Workout",
                                                     "Full on Cardio",
                                                     "Yoga",
                                                     "Full on Cardio",
                                                     "Legs + Back & Ab Workout",
                                                     "Ab Workout",
                                                     "Judo Chop",
                                                     "Stretch or Rest",
                                                     "Rest"]
            
            let two_A_Days_Week10_WorkoutNameArray = ["Full on Cardio",
                                                      "Chest + Shoulders + Tri & Ab Workout",
                                                      "Ab Workout",
                                                      "Full on Cardio",
                                                      "Plyometrics",
                                                      "Back + Biceps & Ab Workout",
                                                      "Ab Workout",
                                                      "Full on Cardio",
                                                      "Yoga",
                                                      "Full on Cardio",
                                                      "Legs + Back & Ab Workout",
                                                      "Ab Workout",
                                                      "Judo Chop",
                                                      "Stretch or Rest",
                                                      "Rest"]
            
            let two_A_Days_Week11_WorkoutNameArray = ["Full on Cardio",
                                                      "Chest + Back & Ab Workout",
                                                      "Ab Workout",
                                                      "Full on Cardio",
                                                      "Plyometrics",
                                                      "Shoulders + Arms & Ab Workout",
                                                      "Ab Workout",
                                                      "Full on Cardio",
                                                      "Yoga",
                                                      "Full on Cardio",
                                                      "Legs + Back & Ab Workout",
                                                      "Ab Workout",
                                                      "Judo Chop",
                                                      "Stretch or Rest",
                                                      "Rest"]
            
            let two_A_Days_Week12_WorkoutNameArray = ["Full on Cardio",
                                                      "Chest + Shoulders + Tri & Ab Workout",
                                                      "Ab Workout",
                                                      "Full on Cardio",
                                                      "Plyometrics",
                                                      "Back + Biceps & Ab Workout",
                                                      "Ab Workout",
                                                      "Full on Cardio",
                                                      "Yoga",
                                                      "Full on Cardio",
                                                      "Legs + Back & Ab Workout",
                                                      "Ab Workout",
                                                      "Judo Chop",
                                                      "Stretch or Rest",
                                                      "Rest"]
            
            let two_A_Days_Week13_WorkoutNameArray = ["Yoga",
                                                      "Core Fitness",
                                                      "Judo Chop",
                                                      "Stretch or Rest",
                                                      "Core Fitness",
                                                      "Yoga",
                                                      "Stretch or Rest",
                                                      "Rest"]
            
            let two_A_Days_WorkoutNameArray = [two_A_Days_Week1_WorkoutNameArray,
                                               two_A_Days_Week2_WorkoutNameArray,
                                               two_A_Days_Week3_WorkoutNameArray,
                                               two_A_Days_Week4_WorkoutNameArray,
                                               two_A_Days_Week5_WorkoutNameArray,
                                               two_A_Days_Week6_WorkoutNameArray,
                                               two_A_Days_Week7_WorkoutNameArray,
                                               two_A_Days_Week8_WorkoutNameArray,
                                               two_A_Days_Week9_WorkoutNameArray,
                                               two_A_Days_Week10_WorkoutNameArray,
                                               two_A_Days_Week11_WorkoutNameArray,
                                               two_A_Days_Week12_WorkoutNameArray,
                                               two_A_Days_Week13_WorkoutNameArray]

            return two_A_Days_WorkoutNameArray
        }
    }
    
    class func loadWorkoutIndexArray() -> [[Int]] {
        
        switch getCurrentRoutine() {
        case "Normal":
            // Normal
            let normal_Week1_WorkoutIndexArray = [1,
                                                  1,
                                                  1,
                                                  1,
                                                  2,
                                                  1,
                                                  1,
                                                  3,
                                                  1,
                                                  1,
                                                  1]
            
            let normal_Week2_WorkoutIndexArray = [2,
                                                  4,
                                                  2,
                                                  2,
                                                  5,
                                                  2,
                                                  2,
                                                  6,
                                                  2,
                                                  2,
                                                  2]
            
            let normal_Week3_WorkoutIndexArray = [3,
                                                  7,
                                                  3,
                                                  3,
                                                  8,
                                                  3,
                                                  3,
                                                  9,
                                                  3,
                                                  3,
                                                  3]
            
            let normal_Week4_WorkoutIndexArray = [4,
                                                  1,
                                                  4,
                                                  4,
                                                  2,
                                                  5,
                                                  5,
                                                  4]
            
            let normal_Week5_WorkoutIndexArray = [1,
                                                  10,
                                                  4,
                                                  1,
                                                  11,
                                                  6,
                                                  4,
                                                  12,
                                                  5,
                                                  6,
                                                  5]
            
            let normal_Week6_WorkoutIndexArray = [2,
                                                  13,
                                                  5,
                                                  2,
                                                  14,
                                                  7,
                                                  5,
                                                  15,
                                                  6,
                                                  7,
                                                  6]
            
            let normal_Week7_WorkoutIndexArray = [3,
                                                  16,
                                                  6,
                                                  3,
                                                  17,
                                                  8,
                                                  6,
                                                  18,
                                                  7,
                                                  8,
                                                  7]
            
            let normal_Week8_WorkoutIndexArray = [9,
                                                  3,
                                                  8,
                                                  9,
                                                  4,
                                                  10,
                                                  10,
                                                  8]
            
            let normal_Week9_WorkoutIndexArray = [4,
                                                  19,
                                                  7,
                                                  4,
                                                  20,
                                                  11,
                                                  7,
                                                  21,
                                                  9,
                                                  11,
                                                  9]
            
            let normal_Week10_WorkoutIndexArray = [4,
                                                   22,
                                                   8,
                                                   4,
                                                   23,
                                                   12,
                                                   8,
                                                   24,
                                                   10,
                                                   12,
                                                   10]
            
            let normal_Week11_WorkoutIndexArray = [5,
                                                   25,
                                                   9,
                                                   5,
                                                   26,
                                                   13,
                                                   9,
                                                   27,
                                                   11,
                                                   13,
                                                   11]
            
            let normal_Week12_WorkoutIndexArray = [5,
                                                   28,
                                                   10,
                                                   5,
                                                   29,
                                                   14,
                                                   10,
                                                   30,
                                                   12,
                                                   14,
                                                   12]
            
            let normal_Week13_WorkoutIndexArray = [15,
                                                   5,
                                                   13,
                                                   15,
                                                   6,
                                                   16,
                                                   16,
                                                   13]
            
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

            case "Tone":
                // TONE
                let tone_Week1_WorkoutIndexArray = [1,
                                                    1,
                                                    1,
                                                    1,
                                                    1,
                                                    1,
                                                    2,
                                                    1,
                                                    1,
                                                    1]
                
                let tone_Week2_WorkoutIndexArray = [2,
                                                    2,
                                                    2,
                                                    3,
                                                    2,
                                                    2,
                                                    4,
                                                    2,
                                                    2,
                                                    2]
                
                let tone_Week3_WorkoutIndexArray = [3,
                                                    3,
                                                    3,
                                                    5,
                                                    3,
                                                    3,
                                                    6,
                                                    3,
                                                    3,
                                                    3]
                
                let tone_Week4_WorkoutIndexArray = [4,
                                                    4,
                                                    4,
                                                    4,
                                                    5,
                                                    5,
                                                    5,
                                                    4]
                
                let tone_Week5_WorkoutIndexArray = [6,
                                                    4,
                                                    1,
                                                    7,
                                                    6,
                                                    4,
                                                    8,
                                                    5,
                                                    6,
                                                    5]
                
                let tone_Week6_WorkoutIndexArray = [7,
                                                    5,
                                                    2,
                                                    9,
                                                    7,
                                                    5,
                                                    10,
                                                    6,
                                                    7,
                                                    6]
                
                let tone_Week7_WorkoutIndexArray = [8,
                                                    6,
                                                    3,
                                                    11,
                                                    8,
                                                    6,
                                                    12,
                                                    7,
                                                    8,
                                                    7]
                
                let tone_Week8_WorkoutIndexArray = [9,
                                                    9,
                                                    8,
                                                    9,
                                                    7,
                                                    10,
                                                    10,
                                                    8]
                
                let tone_Week9_WorkoutIndexArray = [1,
                                                    13,
                                                    8,
                                                    4,
                                                    14,
                                                    11,
                                                    10,
                                                    9,
                                                    11,
                                                    9]
                
                let tone_Week10_WorkoutIndexArray = [4,
                                                     15,
                                                     9,
                                                     1,
                                                     16,
                                                     12,
                                                     11,
                                                     10,
                                                     12,
                                                     10]
                
                let tone_Week11_WorkoutIndexArray = [2,
                                                     17,
                                                     10,
                                                     5,
                                                     18,
                                                     13,
                                                     12,
                                                     11,
                                                     13,
                                                     11]
                
                let tone_Week12_WorkoutIndexArray = [5,
                                                     19,
                                                     11,
                                                     2,
                                                     20,
                                                     14,
                                                     13,
                                                     12,
                                                     14,
                                                     12]
                
                let tone_Week13_WorkoutIndexArray = [15,
                                                     14,
                                                     13,
                                                     15,
                                                     12,
                                                     16,
                                                     16,
                                                     13]
                
                let tone_WorkoutIndexArray = [tone_Week1_WorkoutIndexArray,
                                              tone_Week2_WorkoutIndexArray,
                                              tone_Week3_WorkoutIndexArray,
                                              tone_Week4_WorkoutIndexArray,
                                              tone_Week5_WorkoutIndexArray,
                                              tone_Week6_WorkoutIndexArray,
                                              tone_Week7_WorkoutIndexArray,
                                              tone_Week8_WorkoutIndexArray,
                                              tone_Week9_WorkoutIndexArray,
                                              tone_Week10_WorkoutIndexArray,
                                              tone_Week11_WorkoutIndexArray,
                                              tone_Week12_WorkoutIndexArray,
                                              tone_Week13_WorkoutIndexArray]
                
                return tone_WorkoutIndexArray

        default:
            // 2-A-Days
            let two_A_Days_Week1_WorkoutIndexArray = [1,
                                                      1,
                                                      1,
                                                      1,
                                                      2,
                                                      1,
                                                      1,
                                                      3,
                                                      1,
                                                      1,
                                                      1]
            
            let two_A_Days_Week2_WorkoutIndexArray = [2,
                                                      4,
                                                      2,
                                                      2,
                                                      5,
                                                      2,
                                                      2,
                                                      6,
                                                      2,
                                                      2,
                                                      2]
            
            let two_A_Days_Week3_WorkoutIndexArray = [3,
                                                      7,
                                                      3,
                                                      3,
                                                      8,
                                                      3,
                                                      3,
                                                      9,
                                                      3,
                                                      3,
                                                      3]
            
            let two_A_Days_Week4_WorkoutIndexArray = [4,
                                                      1,
                                                      4,
                                                      4,
                                                      2,
                                                      5,
                                                      5,
                                                      4]
            
            let two_A_Days_Week5_WorkoutIndexArray = [1,
                                                      1,
                                                      10,
                                                      4,
                                                      2,
                                                      1,
                                                      11,
                                                      6,
                                                      3,
                                                      4,
                                                      12,
                                                      5,
                                                      6,
                                                      5]
            
            let two_A_Days_Week6_WorkoutIndexArray = [4,
                                                      2,
                                                      13,
                                                      5,
                                                      5,
                                                      2,
                                                      14,
                                                      7,
                                                      6,
                                                      5,
                                                      15,
                                                      6,
                                                      7,
                                                      6]
            
            let two_A_Days_Week7_WorkoutIndexArray = [7,
                                                      3,
                                                      16,
                                                      6,
                                                      8,
                                                      3,
                                                      17,
                                                      8,
                                                      9,
                                                      6,
                                                      18,
                                                      7,
                                                      8,
                                                      7]
            
            let two_A_Days_Week8_WorkoutIndexArray = [9,
                                                      3,
                                                      8,
                                                      9,
                                                      4,
                                                      10,
                                                      10,
                                                      8]
            
            let two_A_Days_Week9_WorkoutIndexArray = [10,
                                                      4,
                                                      19,
                                                      11,
                                                      7,
                                                      4,
                                                      20,
                                                      12,
                                                      11,
                                                      13,
                                                      7,
                                                      21,
                                                      9,
                                                      11,
                                                      9]
            
            let two_A_Days_Week10_WorkoutIndexArray = [14,
                                                       4,
                                                       22,
                                                       15,
                                                       8,
                                                       4,
                                                       23,
                                                       16,
                                                       12,
                                                       17,
                                                       8,
                                                       24,
                                                       10,
                                                       12,
                                                       10]
            
            let two_A_Days_Week11_WorkoutIndexArray = [18,
                                                       5,
                                                       25,
                                                       19,
                                                       9,
                                                       5,
                                                       26,
                                                       20,
                                                       13,
                                                       21,
                                                       9,
                                                       27,
                                                       11,
                                                       13,
                                                       11]
            
            let two_A_Days_Week12_WorkoutIndexArray = [22,
                                                       5,
                                                       28,
                                                       23,
                                                       10,
                                                       5,
                                                       29,
                                                       24,
                                                       14,
                                                       25,
                                                       10,
                                                       30,
                                                       12,
                                                       14,
                                                       12]
            
            let two_A_Days_Week13_WorkoutIndexArray = [15,
                                                       5,
                                                       13,
                                                       15,
                                                       6,
                                                       16,
                                                       16,
                                                       13]
            
            let two_A_Days_WorkoutIndexArray = [two_A_Days_Week1_WorkoutIndexArray,
                                                two_A_Days_Week2_WorkoutIndexArray,
                                                two_A_Days_Week3_WorkoutIndexArray,
                                                two_A_Days_Week4_WorkoutIndexArray,
                                                two_A_Days_Week5_WorkoutIndexArray,
                                                two_A_Days_Week6_WorkoutIndexArray,
                                                two_A_Days_Week7_WorkoutIndexArray,
                                                two_A_Days_Week8_WorkoutIndexArray,
                                                two_A_Days_Week9_WorkoutIndexArray,
                                                two_A_Days_Week10_WorkoutIndexArray,
                                                two_A_Days_Week11_WorkoutIndexArray,
                                                two_A_Days_Week12_WorkoutIndexArray,
                                                two_A_Days_Week13_WorkoutIndexArray]
            
            return two_A_Days_WorkoutIndexArray
        }
    }
    
    class func allWorkoutTitleArray() -> [String] {
        
        let workoutTitleArray = ["Chest + Back & Ab Workout",
                                 "Plyometrics",
                                 "Shoulders + Arms & Ab Workout",
                                 "Yoga",
                                 "Legs + Back & Ab Workout",
                                 "Judo Chop",
                                 "Chest + Shoulders + Tri & Ab Workout",
                                 "Back + Biceps & Ab Workout",
                                 "Core Fitness",
                                 "Full on Cardio",
                                 "Ab Workout",
                                 "Stretch or Rest",
                                 "Rest"]
        
        return workoutTitleArray
    }
    
    class func allExerciseTitleArray() -> [[String]] {
        
        // Get all the exercise names for each workout
        
        let chest_Back_Ab_Workout = ["Push-Ups",
                                     "Wide Pull-Ups",
                                     "Shoulder Width Push-Ups",
                                     "Underhand Pull-Ups",
                                     "Wide Push-Ups",
                                     "Narrow Pull-Ups",
                                     "Decline Push-Ups",
                                     "Bent Over Rows",
                                     "Diamonds",
                                     "Single Arm Bent Over Rows",
                                     "Under The Wall",
                                     "Seated Back Flys"]

        let plyometrics = [String]()
        
        let shoulders_Arms_Ab_Workout = ["Shoulder Presses",
                                         "2-Way Bicep Curls",
                                         "Tricep Extensions",
                                         "Curl/Shoulder Presses",
                                         "Single Concentration Bicep Curls",
                                         "Dips",
                                         "Chin Rows",
                                         "Parallel Bicep Curls",
                                         "Twisting Tricep Extentions",
                                         "Seated Shoulder Flys",
                                         "Double Concentration Bicep Curls",
                                         "Overhead Tricep Extensions",
                                         "2-Way Shoulder Flys",
                                         "Hammer Bicep Curls",
                                         "Bodyweight Tricep Extensions"]
        
        let yoga = [String]()
        
        let legs_Back_Ab_Workout = ["Chair Lunges",
                                    "Squat to Calf Extensions",
                                    "Underhand Pull-Ups 1",
                                    "Single Leg Lunges",
                                    "Hold Parallel Squats",
                                    "Wide Pull-Ups 1",
                                    "Reverse Lunges",
                                    "Side Lunges",
                                    "Narrow Pull-Ups 1",
                                    "1 Leg Hold Parallel Squats",
                                    "Deadlifts",
                                    "2-Way Pull-Ups 1",
                                    "3-Way Lunges",
                                    "Toe Lunges",
                                    "Underhand Pull-Ups 2",
                                    "Chair Squats",
                                    "Lunge Calf Extensions",
                                    "Wide Pull-Ups 2",
                                    "Crouching Tiger",
                                    "Calf Raises",
                                    "Narrow Pull-Ups 2",
                                    "1 Leg Squats",
                                    "2-Way Pull-Ups 2"]
        
        let judo_Chop = [String]()
        
        let chest_Shoulders_Tri_Ab_Workout = ["3-Way Push-Ups",
                                              "2-Way Shoulder Flys",
                                              "Dips",
                                              "Push-Ups",
                                              "Upside Down Shoulder Presses",
                                              "Bodyweight Tricep Extensions",
                                              "Side Push-Ups",
                                              "Shoulder Rotations",
                                              "Tricep Extensions 1",
                                              "2-Way Push-Ups",
                                              "Shoulder Presses",
                                              "Tricep Extensions 2",
                                              "Lateral Push-Ups",
                                              "Lateral Shoulder Raises",
                                              "Tricep Extensions 3",
                                              "1-Arm Push-Ups",
                                              "Side Shoulder Circles",
                                              "Footballs",
                                              "Plyometric Push-Ups",
                                              "Front Shoulder Raises",
                                              "Tricep Extensions 4",
                                              "Side Plank Push-Ups",
                                              "3-Way Arms",
                                              "Chest Presses"]
        
        let back_Biceps_Ab_Workout = ["Wide Pull-Ups",
                                      "Single Arm Bent Over Rows 1",
                                      "Bicep Curls 1",
                                      "Bicep Curls 2",
                                      "2-Way Pull-Ups",
                                      "Single Arm Bent Over Rows 2",
                                      "Bicep Curls 3",
                                      "Concentration Curls",
                                      "Side to Side Pull-Ups",
                                      "Bent Over Rows",
                                      "Wide Arm Curls",
                                      "Parallel Bicep Curls",
                                      "Uneven Pull-Ups",
                                      "Alternating Bent Over Rows",
                                      "Double Concentration Bicep Curls",
                                      "Bicep Curls 4",
                                      "Underhand Pull-Ups",
                                      "Seated Back Flys",
                                      "Bicep Curls 5",
                                      "Hammer Curls",
                                      "Pull-Ups",
                                      "Lower Back Raises",
                                      "2-Way Hammer Curls",
                                      "Burnout Bicep Curls 1",
                                      "Burnout Bicep Curls 2",
                                      "Burnout Bicep Curls 3",
                                      "Burnout Bicep Curls 4"]
        
        let core_Fitness = ["Offset Push-Ups",
                            "Back to Stomach 1",
                            "Side Lunges",
                            "Runner Lunges",
                            "Push-Ups",
                            "Back to V",
                            "Deep Side Lunges",
                            "Top Shelf",
                            "Burpees",
                            "Side Sphinx Raises",
                            "Squat Press",
                            "Plank Crunches",
                            "Plank Crawls",
                            "Back to Stomach 2",
                            "Lunge to 3 Way Arms",
                            "Line Jumps",
                            "Half Plank Push-Ups",
                            "Standing Crunches",
                            "Squat Jumps",
                            "Plank Push-Ups",
                            "Tractor Tires",
                            "Dips"]
        
        let full_On_Cardio = [String]()
        
        let ab_Workout = [String]()
        
        let stretch_Or_Rest = [String]()
        
        let rest = [String]()

        let exerciseTitleArray = [chest_Back_Ab_Workout,
                                  plyometrics,
                                  shoulders_Arms_Ab_Workout,
                                  yoga,
                                  legs_Back_Ab_Workout,
                                  judo_Chop,
                                  chest_Shoulders_Tri_Ab_Workout,
                                  back_Biceps_Ab_Workout,
                                  core_Fitness,
                                  full_On_Cardio,
                                  ab_Workout,
                                  stretch_Or_Rest,
                                  rest]
        
        return exerciseTitleArray
    }
    
    class func allSessionStringForEmail() -> String {
        
        // Get Data from the database.
        let allWorkoutTitlesArray = self.allWorkoutTitleArray()
        let allExerciseTitlesArray = self.allExerciseTitleArray()
        let writeString = NSMutableString()
        
        let routineArray = ["Normal",
                            "Tone",
                            "2-A-Days"]
        
        // Get the highest session value stored in the database
        let maxSession = Int(self.findMaxSessionValue())
        
        // For each session, list each workouts data.  Normal then tone then 2-A-Days.
        // Sessions start at 1.  Cannot have a 0 session.
        for sessionCounter in 1...maxSession! {
            
            // Get session value.
            let currentSessionString = String(sessionCounter)
            
            // Routine
            for routineIndex in 0..<routineArray.count {
                
                // Workout
                for i in 0..<allWorkoutTitlesArray.count {
                    
                    let tempExerciseTitlesArray = allExerciseTitlesArray[i]
                    
                    // Get workout data with the current session.  Sort by INDEX.
                    let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                    let sortIndex = NSSortDescriptor( key: "index", ascending: true)
                    let sortDate = NSSortDescriptor( key: "date", ascending: true)
                    request.sortDescriptors = [sortIndex, sortDate]
                    
                    let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@",
                                             currentSessionString,
                                             routineArray[routineIndex],
                                             allWorkoutTitlesArray[i])
                    
                    request.predicate = filter
                    
                    do {
                        if let workoutObjects1 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                            
                            // print("workoutObjects1.count = \(workoutObjects1.count)")
                            
                            var maxIndex = 0
                            
                            if workoutObjects1.count != 0 {
                                
                                maxIndex = Int((workoutObjects1.last?.index)!)
                                
                                var localSession = ""
                                var localRoutine = ""
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
                                    
                                    var filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index == %@",
                                                             currentSessionString,
                                                             routineArray[routineIndex],
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
                                                    
                                                    //  Add the column headers for Routine, Month, Week, Workout, and Date to the string
                                                    writeString.append("Session,Routine,Week,Try,Workout,Date\n")
                                                    
                                                    localSession = workoutObjects2[a].session!
                                                    localRoutine = workoutObjects2[a].routine!
                                                    localWeek = workoutObjects2[a].week!
                                                    localWorkout = workoutObjects2[a].workout!
                                                    localDate = workoutObjects2[a].date! as Date
                                                    
                                                    dateString = DateFormatter.localizedString(from: localDate, dateStyle: .short, timeStyle: .none)
                                                    
                                                    // Add column headers for indivialual workouts based on workout index number
                                                    writeString.append("\(localSession),\(localRoutine),\(localWeek),\(index),\(self.trimStringForWorkoutName(localWorkout)),\(dateString)\n")
                                                }
                                                
                                                let workoutIndex = NSNumber(value: index as Int)
                                                
                                                //  Add the exercise name, reps and weight
                                                for b in 0..<tempExerciseTitlesArray.count {
                                                    
                                                    tempExerciseName = tempExerciseTitlesArray[b]
                                                    
                                                    //  Add the exercise title to the string
                                                    writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, ,Notes\n")
                                                    
                                                    // Add the "Reps" to the row
                                                    writeString.append("Reps,")
                                                    
                                                    //  Add the reps and notes to the string
                                                    for round in 0..<2 {
                                                        
                                                        roundConvertedToString = self.renameRoundIntToString(round)
                                                        tempRepData = ""
                                                        tempNotesData = ""
                                                        
                                                        filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                             currentSessionString,
                                                                             localRoutine,
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
                                                                        
                                                                        if round == 1 {
                                                                            
                                                                            //  Inserts a """" into the string
                                                                            writeString.append("\(tempRepData),,")
                                                                        }
                                                                        else {
                                                                            
                                                                            //  Inserts a "" into the string
                                                                            writeString.append("\(tempRepData),")
                                                                        }
                                                                    }
                                                                    else {
                                                                        
                                                                        // There was a record found, but only had data for the weight or notes and not the reps.
                                                                        if round == 1 {
                                                                            
                                                                            //  Inserts a """" into the string
                                                                            writeString.append("\(tempRepData),,")
                                                                        }
                                                                        else {
                                                                            
                                                                            //  Inserts a "" into the string
                                                                            writeString.append("\(tempRepData),")
                                                                        }
                                                                    }
                                                                }
                                                                else {
                                                                    // No match found
                                                                    if round == 1 {
                                                                        
                                                                        //  Inserts a """" into the string
                                                                        writeString.append("\(tempRepData),,")
                                                                    }
                                                                    else {
                                                                        
                                                                        //  Inserts a "" into the string
                                                                        writeString.append("\(tempRepData),")
                                                                    }
                                                                }
                                                            }
                                                        } catch { print(" ERROR executing a fetch request: \( error)") }
                                                        
                                                        //  Notes
                                                        if round == 1 {
                                                            
                                                            filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                                 currentSessionString,
                                                                                 localRoutine,
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
                                                    for round in 0..<2 {
                                                        
                                                        roundConvertedToString = self.renameRoundIntToString(round)
                                                        tempWeightData = ""
                                                        
                                                        filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                             currentSessionString,
                                                                             localRoutine,
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
                                                                        
                                                                        if round == 1 {
                                                                            
                                                                            writeString.append("\(tempWeightData)\n")
                                                                        }
                                                                        else {
                                                                            
                                                                            writeString.append("\(tempWeightData),")
                                                                        }
                                                                    }
                                                                    else {
                                                                        
                                                                        //  There was a record found, but only had data for the reps or notes and not the weight.
                                                                        if round == 1 {
                                                                            
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
                                                                    if round == 1 {
                                                                        
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
        }
        
        //  Return the string
        return writeString as String
    }
    
    class func currentSessionStringForEmail() -> String {
        
        // Get Data from the database.
        let allWorkoutTitlesArray = self.allWorkoutTitleArray()
        let allExerciseTitlesArray = self.allExerciseTitleArray()
        let writeString = NSMutableString()
        
        let routineArray = ["Normal",
                            "Tone",
                            "2-A-Days"]
        
        // Get the current session value stored in the database
        let currentSessionString = self.getCurrentSession()
        
        // Routine
        for routineIndex in 0..<routineArray.count {
            
            // Workout
            for i in 0..<allWorkoutTitlesArray.count {
                
                let tempExerciseTitlesArray = allExerciseTitlesArray[i]
                
                // Get workout data with the current session.  Sort by INDEX.
                let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
                let sortIndex = NSSortDescriptor( key: "index", ascending: true)
                let sortDate = NSSortDescriptor( key: "date", ascending: true)
                request.sortDescriptors = [sortIndex, sortDate]
                
                let filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@",
                                         currentSessionString,
                                         routineArray[routineIndex],
                                         allWorkoutTitlesArray[i])
                
                request.predicate = filter
                
                do {
                    if let workoutObjects1 = try CoreDataHelper.shared().context.fetch(request) as? [Workout] {
                        
                        // print("workoutObjects1.count = \(workoutObjects1.count)")
                        
                        var maxIndex = 0
                        
                        if workoutObjects1.count != 0 {
                            
                            maxIndex = Int((workoutObjects1.last?.index)!)
                            
                            var localSession = ""
                            var localRoutine = ""
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
                                
                                var filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index == %@",
                                                         currentSessionString,
                                                         routineArray[routineIndex],
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
                                                
                                                //  Add the column headers for Routine, Month, Week, Workout, and Date to the string
                                                writeString.append("Session,Routine,Week,Try,Workout,Date\n")
                                                
                                                localSession = workoutObjects2[a].session!
                                                localRoutine = workoutObjects2[a].routine!
                                                localWeek = workoutObjects2[a].week!
                                                localWorkout = workoutObjects2[a].workout!
                                                localDate = workoutObjects2[a].date! as Date
                                                
                                                dateString = DateFormatter.localizedString(from: localDate, dateStyle: .short, timeStyle: .none)
                                                
                                                // Add column headers for indivialual workouts based on workout index number
                                                writeString.append("\(localSession),\(localRoutine),\(localWeek),\(index),\(self.trimStringForWorkoutName(localWorkout)),\(dateString)\n")
                                            }
                                            
                                            let workoutIndex = NSNumber(value: index as Int)
                                            
                                            //  Add the exercise name, reps and weight
                                            for b in 0..<tempExerciseTitlesArray.count {
                                                
                                                tempExerciseName = tempExerciseTitlesArray[b]
                                                
                                                //  Add the exercise title to the string
                                                writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, ,Notes\n")
                                                
                                                // Add the "Reps" to the row
                                                writeString.append("Reps,")

                                                //  Add the reps and notes to the string
                                                for round in 0..<2 {
                                                    
                                                    roundConvertedToString = self.renameRoundIntToString(round)
                                                    tempRepData = ""
                                                    tempNotesData = ""
                                                    
                                                    filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                         currentSessionString,
                                                                         localRoutine,
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
                                                                    
                                                                    if round == 1 {
                                                                        
                                                                        //  Inserts a """" into the string
                                                                        writeString.append("\(tempRepData),,")
                                                                    }
                                                                    else {
                                                                        
                                                                        //  Inserts a "" into the string
                                                                        writeString.append("\(tempRepData),")
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    // There was a record found, but only had data for the weight or notes and not the reps.
                                                                    if round == 1 {
                                                                        
                                                                        //  Inserts a """" into the string
                                                                        writeString.append("\(tempRepData),,")
                                                                    }
                                                                    else {
                                                                        
                                                                        //  Inserts a "" into the string
                                                                        writeString.append("\(tempRepData),")
                                                                    }
                                                                }
                                                            }
                                                            else {
                                                                // No match found
                                                                if round == 1 {
                                                                    
                                                                    //  Inserts a """" into the string
                                                                    writeString.append("\(tempRepData),,")
                                                                }
                                                                else {
                                                                    
                                                                    //  Inserts a "" into the string
                                                                    writeString.append("\(tempRepData),")
                                                                }
                                                            }
                                                        }
                                                    } catch { print(" ERROR executing a fetch request: \( error)") }
                                                    
                                                    //  Notes
                                                    if round == 1 {
                                                        
                                                        filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                             currentSessionString,
                                                                             localRoutine,
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
                                                for round in 0..<2 {
                                                    
                                                    roundConvertedToString = self.renameRoundIntToString(round)
                                                    tempWeightData = ""
                                                    
                                                    filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                                         currentSessionString,
                                                                         localRoutine,
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
                                                                    
                                                                    if round == 1 {
                                                                        
                                                                        writeString.append("\(tempWeightData)\n")
                                                                    }
                                                                    else {
                                                                        
                                                                        writeString.append("\(tempWeightData),")
                                                                    }
                                                                }
                                                                else {
                                                                    
                                                                    //  There was a record found, but only had data for the reps or notes and not the weight.
                                                                    if round == 1 {
                                                                        
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
                                                                if round == 1 {
                                                                    
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
        
        // Get the current routine value stored in the database
        let currentRoutineString = self.getCurrentRoutine()

        // Convert the index Int into an NSNumber
        let convertedIndex = NSNumber(value: index as Int)
        
        // Get workout data with workout index
        let request = NSFetchRequest<NSFetchRequestResult>( entityName: "Workout")
        
        var filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND index == %@",
                                 currentSessionString,
                                 currentRoutineString,
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
                        
                        //  Add the column headers for Routine, Month, Week, Workout, and Date to the string
                        writeString.append("Session,Routine,Week,Try,Workout,Date\n")
                        
                        let localSession = workoutObjects2[a].session!
                        let localRoutine = workoutObjects2[a].routine!
                        let localWeek = workoutObjects2[a].week!
                        let localWorkout = self.trimStringForWorkoutName(workoutObjects2[a].workout!) 
                        let localDate = workoutObjects2[a].date!
                        
                        let dateString = DateFormatter.localizedString(from: localDate as Date, dateStyle: .short, timeStyle: .none)
                        
                        // Add column headers for indivialual workouts based on workout index number
                        writeString.append("\(localSession),\(localRoutine),\(localWeek),\(index),\(localWorkout),\(dateString)\n")
                    }
                    
                    //  Add the exercise name, reps and weight
                    for b in 0..<exerciseTitleArray.count {
                        
                        let tempExerciseName = exerciseTitleArray[b] 
                        
                        //  Add the exercise title to the string
                        writeString.append(",\n\(tempExerciseName)\n, Round 1, Round 2, ,Notes\n")
                        
                        // Add the "Reps" to the row
                        writeString.append("Reps,")
                        
                        //  Add the reps and notes to the string
                        for round in 0..<2 {
                            
                            let roundConvertedToString = self.renameRoundIntToString(round)
                            var tempRepData = ""
                            var tempNotesData = ""
                            
                            filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                 currentSessionString,
                                                 currentRoutineString,
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
                                            
                                            if round == 1 {
                                                
                                                //  Inserts a """" into the string
                                                writeString.append("\(tempRepData),,")
                                            }
                                            else {
                                                
                                                //  Inserts a "" into the string
                                                writeString.append("\(tempRepData),")
                                            }
                                        }
                                        else {
                                            
                                            // There was a record found, but only had data for the weight or notes and not the reps.
                                            if round == 1 {
                                                
                                                //  Inserts a """" into the string
                                                writeString.append("\(tempRepData),,")
                                            }
                                            else {
                                                
                                                //  Inserts a "" into the string
                                                writeString.append("\(tempRepData),")
                                            }
                                        }
                                    }
                                    else {
                                        // No match found
                                        if round == 1 {
                                            
                                            //  Inserts a """" into the string
                                            writeString.append("\(tempRepData),,")
                                        }
                                        else {
                                            
                                            //  Inserts a "" into the string
                                            writeString.append("\(tempRepData),")
                                        }
                                    }
                                }
                            } catch { print(" ERROR executing a fetch request: \( error)") }
                            
                            //  Notes
                            if round == 1 {
                                
                                filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                     currentSessionString,
                                                     currentRoutineString,
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
                        for round in 0..<2 {
                            
                            let roundConvertedToString = self.renameRoundIntToString(round)
                            var tempWeightData = ""
                            
                            filter = NSPredicate(format: "session == %@ AND routine == %@ AND workout == %@ AND exercise = %@ AND round = %@ AND index == %@",
                                                 currentSessionString,
                                                 currentRoutineString,
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
                                            
                                            if round == 1 {
                                                
                                                writeString.append("\(tempWeightData)\n")
                                            }
                                            else {
                                                
                                                writeString.append("\(tempWeightData),")
                                            }
                                        }
                                        else {
                                            
                                            //  There was a record found, but only had data for the reps or notes and not the weight.
                                            if round == 1 {
                                                
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
                                        if round == 1 {
                                            
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
