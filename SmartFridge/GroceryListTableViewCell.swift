//
//  GroceryListTableViewCell.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/27/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class GroceryListTableViewCell: UITableViewCell
{
    @IBOutlet weak var GroceryLabel: UILabel!
    
    @IBOutlet weak var GroceryID: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }

}
