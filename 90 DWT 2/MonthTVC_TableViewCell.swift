//
//  MonthTVC_TableViewCell.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 1/26/17.
//  Copyright © 2017 Grant, Jared. All rights reserved.
//

import UIKit

class MonthTVC_TableViewCell: UITableViewCell {

    @IBOutlet weak var weekOfMonthTextField: UITextField!
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
