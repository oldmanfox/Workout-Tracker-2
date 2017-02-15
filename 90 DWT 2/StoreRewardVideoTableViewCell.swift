//
//  StoreRewardVideoTableViewCell.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 1/10/17.
//  Copyright © 2017 Jared Grant. All rights reserved.
//

import UIKit

class StoreRewardVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func viewButtonPressed(_ sender: UIButton) {
        
        // viewButtonPressed.  Do nothing here.
    }
}
