//
//  GroceryListModel.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/28/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import Foundation

class GroceryItemModel: NSObject
{
    var name: String?
    var id: Int?
    var uid: Int?
    var type: String?
    
    override init()
    {
        
    }
    
    //construct with parameters
    
    init(name: String, id: Int, uid: Int, type: String)
    {
        
        self.name = name
        self.id = id
        self.uid = uid
        self.type = type
        
    }
}
