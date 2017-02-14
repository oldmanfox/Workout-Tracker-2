//
//  WorkoutTVC_WorkoutTableViewCell.swift
//  90 DWT 1
//
//  Created by Jared Grant on 7/2/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
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


class WorkoutTVC_WorkoutTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var title: UILabel!
    
    // **********
    let debug = 0
    // **********
    
    var session = ""
    var workoutRoutine = ""
    var selectedWorkout = ""
    var workoutWeek = ""
    var month = ""
    var nonUpperCaseExerciseName = ""
    var workoutIndex = 0
        
    var originalCurrentRep1_Text = ""
    var originalCurrentWeight1_Text = ""
    
    var originalCurrentRep2_Text = ""
    var originalCurrentWeight2_Text = ""
    
//    var originalCurrentRep3_Text = ""
//    var originalCurrentWeight3_Text = ""
    
    var originalCurrentNotes_Text = ""
    
    var activeTextField = UITextField()
    
    @IBOutlet weak var roundLabel1: UILabel!
    @IBOutlet weak var roundLabel2: UILabel!
    
    @IBOutlet weak var repLabel1: UILabel!
    @IBOutlet weak var repLabel2: UILabel!
    
    @IBOutlet weak var weightLabel1: UILabel!
    @IBOutlet weak var weightLabel2: UILabel!
    
    @IBOutlet weak var previousRep1: UITextField!
    @IBOutlet weak var previousRep2: UITextField!
    
    @IBOutlet weak var previousWeight1: UITextField!
    @IBOutlet weak var previousWeight2: UITextField!
    
    @IBOutlet weak var currentRep1: UITextField!
    @IBOutlet weak var currentRep2: UITextField!
    
    @IBOutlet weak var currentWeight1: UITextField!
    @IBOutlet weak var currentWeight2: UITextField!
    
    @IBOutlet weak var previousNotes: UITextField!
    @IBOutlet weak var currentNotes: UITextField!
    
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var rewardVideoButton: UIButton!
    
    
    @IBAction func saveCurrentRep1(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if (sender.text?.characters.count > 0 && sender.text != "0.0" && sender.text != originalCurrentRep1_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveRepsWithPredicate(session, routine: workoutRoutine, workout: selectedWorkout, month: month, week: workoutWeek, exercise: nonUpperCaseExerciseName, index: workoutIndex as NSNumber, reps: sender.text!, round: "Round 1")
        }
        else {
            
            sender.text = originalCurrentRep1_Text
        }
    }
    
    @IBAction func saveCurrentWeight1(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if (sender.text?.characters.count > 0 && sender.text != "0.0" && sender.text != originalCurrentWeight1_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveWeightWithPredicate(session, routine: workoutRoutine, workout: selectedWorkout, month: month, week: workoutWeek, exercise: nonUpperCaseExerciseName, index: workoutIndex as NSNumber, weight: sender.text!, round: "Round 1")
        }
        else {
            
            sender.text = originalCurrentWeight1_Text
        }
    }
    
    @IBAction func saveCurrentRep2(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if (sender.text?.characters.count > 0 && sender.text != "0.0" && sender.text != originalCurrentRep2_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveRepsWithPredicate(session, routine: workoutRoutine, workout: selectedWorkout, month: month, week: workoutWeek, exercise: nonUpperCaseExerciseName, index: workoutIndex as NSNumber, reps: sender.text!, round: "Round 2")
        }
        else {
            
            sender.text = originalCurrentRep2_Text
        }
    }
    
    @IBAction func saveCurrentWeight2(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if (sender.text?.characters.count > 0 && sender.text != "0.0" && sender.text != originalCurrentWeight2_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveWeightWithPredicate(session, routine: workoutRoutine, workout: selectedWorkout, month: month, week: workoutWeek, exercise: nonUpperCaseExerciseName, index: workoutIndex as NSNumber, weight: sender.text!, round: "Round 2")
        }
        else {
            
            sender.text = originalCurrentWeight2_Text
        }
    }
    
    @IBAction func saveCurrentNotes(_ sender: UITextField) {
        
        // Only update the fields that have been changed.
        if (sender.text?.characters.count > 0 && sender.text != "CURRENT NOTES" && sender.text != originalCurrentNotes_Text) {
            
            if debug == 1 {
                
                print("String is: \(sender.text!)")
            }
            
            CDOperation.saveNoteWithPredicate(session, routine: workoutRoutine, workout: selectedWorkout, month: month, week: workoutWeek, exercise: nonUpperCaseExerciseName, index: workoutIndex as NSNumber, note: sender.text!, round: "Round 1")
        }
        else {
            
            sender.text = originalCurrentNotes_Text
        }
    }
    
    @IBAction func graphButtonPressed(_ sender: UIButton) {
        
        switch self.activeTextField.tag {
        case 0:
            saveCurrentRep1(currentRep1)
            
        case 1:
            saveCurrentWeight1(currentWeight1)
            
        case 2:
            saveCurrentRep2(currentRep2)
            
        case 3:
            saveCurrentWeight2(currentWeight2)
            
        case 4:
            saveCurrentNotes(currentNotes)
            
        default:
            break
        }
}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        currentRep1.delegate = self
        currentRep2.delegate = self
        
        currentWeight1.delegate = self
        currentWeight2.delegate = self
        
        currentNotes.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UITextFieldDelegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        currentRep1.resignFirstResponder()
        currentRep2.resignFirstResponder()
        
        currentWeight1.resignFirstResponder()
        currentWeight2.resignFirstResponder()
        
        currentNotes.resignFirstResponder()
        
        return true
    }
}
