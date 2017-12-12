//
//  Dashboard.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/7/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class Dashboard: UIViewController,UITableViewDelegate, UITableViewDataSource
{
    
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var itemTableView: UITableView!
    
    var row = 0
    var FridgeItems = Array<FridgeItemsModel>()
    var Names = Array<String>()
    var ID = Array<Int>()
    var UserID = String()
    var DeleteID = Int()

    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        print("User id from defaults")
        print(preferences.object(forKey: "UserId") ?? "no UID")
        UserID = preferences.object(forKey: "UserId") as! String
        
        fetchItemList()

        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.backgroundView = UIImageView(image: UIImage(named: "background.jpg"))
        
        //cell.backgroundView = UIImageView(image: UIImage(named: "background.jpg")!)
        
        
    }
    
   
    
    override func viewDidAppear(_ animated: Bool)
    {
        //self.itemTableView.reloadData()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Names.count; //retun the number of items
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemDisplay") as! DashboardTableViewCell
        
        /*var imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width: 100, height: 200))
        
        let image = UIImage(named: "background.png")
        
        cell.backgroundColor = UIColor.clear
        
        imageView = UIImageView(image:image)
        
        cell.backgroundView = imageView*/

        print(Names)
        row = Names.count
        cell.itemLabel.text = Names[indexPath.row]
        cell.itemImage.image = UIImage(named: Names[indexPath.row])
        cell.itemIDLabel.text = String(ID[indexPath.row])
        cell.backgroundView = UIImageView(image: UIImage(named: "background.jpg")!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        print("Inside edit cell")
        //cell.backgroundColor = UIColor.clear
        print(cell)
        cell.backgroundView = UIImageView(image: UIImage(named: "background.jpg")!)
    }
    
    @objc func fetchItemList()
    {
        print("Inside fetch list")
        
        let DNS = RestApiUrl()
        
        //print(DNS.aws + "/SmartFridgeBackend/user/fridgeItems/"+UserID)
        
        var request = URLRequest(url: URL(string: DNS.aws + "/SmartFridgeBackend/user/fridgeItems/"+UserID)!)
        request.httpMethod = "GET"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [] ,options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        //let session = URLSession.shared
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in print( response ?? "Error connecting to Rest API - GET Items from fridge")
            
            if error != nil
            {
                print("Failed to connect to Fetch Item API")
                print(error!)
            }
            else
            {
                print("Data Obtained")
                
                self.parseJSON(data!)
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    print("Retrived items")
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    print("Failed to retrive data")
                }
            }
            
            DispatchQueue.main.async
                {
                    self.itemTableView.reloadData()
            }
        })
        
        task.resume()
        
    }
    
    func parseJSON(_ data:Data)
    {

        var jsonResult = NSArray()
       
        do{
            
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            print(jsonResult)
            
        } catch let error as NSError
        {
            print(error)
        }
        
        
        var jsonElement = NSDictionary()
        
        
        row = jsonResult.count
        
        
        for i in 0 ..< jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let FridgeItem = FridgeItemsModel()
                
            let name = jsonElement["Name"] as? String
            let MfgDate = jsonElement["MFGDate"] as? Date
            let ExpDate = jsonElement["EXPDate"] as? Date
            let Quantity = jsonElement["Quantity"] as? Float
            let Price = jsonElement["Price"] as? Float
            let ItemID = jsonElement["Item_Id"] as? Int
            
            
                FridgeItem.name = name
                FridgeItem.MfgDate = MfgDate
                FridgeItem.ExpDate = ExpDate
                FridgeItem.quantity = Quantity
                FridgeItem.price = Price
                FridgeItem.ID = ItemID
            
            FridgeItems.append(FridgeItem)
            Names.append(FridgeItem.name ?? "Item")
            ID.append(FridgeItem.ID ?? 1)
            
        }
        
        /*if self.refreshControl.isRefreshing
        {
            self.refreshControl.endRefreshing()
        }*/
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtindexPath indexPath: NSIndexPath!) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            
            print(Names[indexPath.row])
            print(ID[indexPath.row])
            DeleteID = ID[indexPath.row]
            deleteItem(ItemID: DeleteID)
            
            Names.remove(at: indexPath.row)
            ID.remove(at: indexPath.row)
            itemTableView.reloadData()
        }
    }
    
    
    /*@IBAction func Reload(_ sender: UIButton)
    {
        Names = Array<String>()
        ID = Array<Int>()
        fetchItemList()
        //itemTableView.reloadData()
    }*/
    
    func deleteItem(ItemID : Int)
    {
        print("Inside delete fridge item")
        
        let strID = String(ItemID)
        let DNS = RestApiUrl()
        
        var request = URLRequest(url: URL(string: DNS.aws + "/SmartFridgeBackend/fridge/delete/"+UserID+"/"+strID)!)
        request.httpMethod = "DELETE"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [] ,options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        
        //let session = URLSession.shared
        
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in print( response ?? "Error connecting to Rest API - Delete Items from fridge")
            
            if error != nil
            {
                print("Failed to connect to Delete Item API")
                print(error!)
            }
            else
            {
                print("Response obtained")
                
                self.parse(data!)
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    print("Deleted Item")
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    print("Failed to items")
                }
            }
        })
        
        task.resume()
    }
    
    func parse(_ data:Data)
    {
        var jsonResult = NSDictionary()
        
        do{
            
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            print(jsonResult)
            
        } catch let error as NSError
        {
            print(error)
        }
        
        let responseString = jsonResult["string"] as? String
        print(responseString ?? "No string")
    }
    
}
