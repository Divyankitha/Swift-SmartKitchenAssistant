//
//  DashboardTableViewCell.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/7/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var itemCellView: UIView!
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemIDLabel: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }

}
