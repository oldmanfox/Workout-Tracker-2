//
//  WeekTVC_TableViewCell.swift
//  90 DWT 1
//
//  Created by Jared Grant on 6/26/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class WeekTVC_TableViewCell: UITableViewCell {

    @IBOutlet weak var dayOfWeekTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
