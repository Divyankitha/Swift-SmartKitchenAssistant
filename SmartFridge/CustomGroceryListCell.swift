//
//  CustomGroceryListCell.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 12/1/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class CustomGroceryListCell: UITableViewCell {

    @IBOutlet weak var CustomID: UILabel!
    @IBOutlet weak var CustomName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
