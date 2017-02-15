//
//  WorkoutTVC_ShuffleTableViewCell.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 2/10/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import UIKit

class WorkoutTVC_ShuffleTableViewCell: UITableViewCell {
    
    var segmentedControlTap: ((UITableViewCell) -> Void)?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var roundSegmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func shuffleWorkoutNames(_ sender: UISegmentedControl) {
        
        segmentedControlTap?(self)
    }
}
