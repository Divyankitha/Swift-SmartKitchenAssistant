//
//  FridgeItemsModel.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/2/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import Foundation

class FridgeItemsModel: NSObject {
    
    //properties
    
    var name: String?
    var quantity: Float?
    var price: Float?
    var MfgDate: Date?
    var ExpDate: Date?
    var ID: Int?
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with parameters
    
    init(name: String, MfgDate: Date, ExpDate: Date, quantity: Float, price: Float, ID: Int)
    {
        
        self.name = name
        self.MfgDate = MfgDate
        self.ExpDate = ExpDate
        self.quantity = quantity
        self.price = price
        self.ID = ID
        
    }
    
    
    //prints object's current state
    
    /*override var description: String {
        return "Name: \(name), Mfg.Date: \(MfgDate), Exp.Date: \(ExpDate), quantity: \(quantity), Price:\(price) "
        
    }*/
    
    
}
