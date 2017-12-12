//
//  HomeModel.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/2/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import Foundation

protocol HomeModelProtocol
{
    func ItemsInFridge(items: NSArray)
}

class HomeModel: NSObject, URLSessionDataDelegate {
    
    //properties
    
   var delegate: HomeModelProtocol!
    
    var data = Data()
    
    //API URL
    let urlPath: String = "http://iosquiz.com/service.php" //this will be changed to the path where service.php lives
    
    func downloadItems() {
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSON(data!)
            }
            
        }
        
        task.resume()
    }
    
    func parseJSON(_ data:Data) {
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement = NSDictionary()
        let FridgeItems = NSMutableArray()
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let FridgeItem = FridgeItemsModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let name = jsonElement["Name"] as? String,
                let MfgDate = jsonElement["MfgDate"] as? Date,
                let ExpDate = jsonElement["ExpDate"] as? Date,
                let Quantity = jsonElement["Quantity"] as? Float,
                let Price = jsonElement["Price"] as? Float
            {
                
                FridgeItem.name = name
                FridgeItem.MfgDate = MfgDate
                FridgeItem.ExpDate = ExpDate
                FridgeItem.quantity = Quantity
                FridgeItem.price = Price
                
            }
            
            FridgeItems.add(FridgeItem)
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.ItemsInFridge(items: FridgeItems)
            
        })
    }
}
