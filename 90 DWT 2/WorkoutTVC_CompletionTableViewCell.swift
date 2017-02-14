//
//  WorkoutTVC_CompletionTableViewCell.swift
//  90 DWT 1
//
//  Created by Jared Grant on 7/2/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class WorkoutTVC_CompletionTableViewCell: UITableViewCell {

    var session = ""
    var workoutRoutine = ""
    var selectedWorkout = ""
    var workoutIndex = 0
    var indexPath = IndexPath()
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var deleteDateButton: UIButton!
    @IBOutlet weak var todayDateButton: UIButton!
    @IBOutlet weak var previousDateButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func workoutCompletedDelete(_ sender: UIButton) {
        
        CDOperation.deleteDate(session as NSString, routine: workoutRoutine as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber)
        
        updateWorkoutCompleteCellUI()
    }
    
    @IBAction func workoutCompletedToday(_ sender: UIButton) {
        
        CDOperation.saveWorkoutCompleteDate(session as NSString, routine: workoutRoutine as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber, useDate: Date())
        
        updateWorkoutCompleteCellUI()
    }
    
    func updateWorkoutCompleteCellUI () {
        
        let workoutCompletedObjects = CDOperation.getWorkoutCompletedObjects(session as NSString, routine: workoutRoutine as NSString, workout: selectedWorkout as NSString, index: workoutIndex as NSNumber)
        
        switch  workoutCompletedObjects.count {
        case 0:
            // No match
            
            // Cell
            self.backgroundColor = UIColor.white
            
            // Label
            dateLabel.text = "Workout Completed: __/__/__";
            dateLabel.textColor = UIColor.black
            
        default:
            // Found a match.
            
            let object = workoutCompletedObjects.last
            let completedDate = DateFormatter .localizedString(from: (object?.date)! as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)

            // Cell
            self.backgroundColor = UIColor.darkGray
            
            // Label
            dateLabel.text? = "Workout Completed: \(completedDate)"
            dateLabel.textColor = UIColor.white
        }
    }
}
