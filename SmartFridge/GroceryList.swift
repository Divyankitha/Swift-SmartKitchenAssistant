//
//  GroceryList.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/27/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class GroceryList: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    @IBOutlet weak var GroceryTable: UITableView!
    
    @IBOutlet weak var CustomGroceryTable: UITableView!
    
    var row = 0
    
    var Names = Array<String>()
    var ID = Array<Int>()
    
    var CNames = Array<String>()
    var CID = Array<Int>()
    
    /*var Names = ["Apple","Bread","Corn"]
    var ID = [1,2,3]
    
    var CNames = ["Chocolate"]
    var CID = [1]*/
    
    var UserID = String()
    
    var DeleteName = String ()
    
    var GroceryItems = Array<GroceryItemModel>()
    
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        print("User id from defaults")
        print(preferences.object(forKey: "UserId") ?? "no UID")
        UserID = preferences.object(forKey: "UserId") as! String
        
        fetchGroceryList()
        
        GroceryTable.delegate = self
        GroceryTable.dataSource = self
        
        CustomGroceryTable.delegate = self
        CustomGroceryTable.dataSource = self
        
        //GroceryTable.backgroundView = UIImageView(image: UIImage(named: "notepad.jpg"))
        //CustomGroceryTable.backgroundView = UIImageView(image: UIImage(named: "notepad2.jpg"))
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        //fetchGroceryList()
    }
    override func viewDidAppear(_ animated: Bool)
    {
        //self.GroceryTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == self.GroceryTable
        {
          return Names.count; //retun the number of items
        }
        else if tableView == self.CustomGroceryTable
        {
            print("Inside table row count")
            print(CNames.count)
            return CNames.count
        }
        else
        {
          return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //print(tableView)
        
        if tableView == self.GroceryTable
        {
            let cell = GroceryTable.dequeueReusableCell(withIdentifier: "GroceryListCell") as! GroceryListTableViewCell
            print(Names)
            cell.GroceryLabel.text = Names[indexPath.row]
            cell.GroceryID.text = String(ID[indexPath.row])
            return cell
        }
        else if tableView == self.CustomGroceryTable
        {
            print("Inside else condition")
            let cell = CustomGroceryTable.dequeueReusableCell(withIdentifier: "CustomGroceryListCell") as! CustomGroceryListCell
            print(CNames)
            cell.CustomName.text = CNames[indexPath.row]
            cell.CustomID.text = String(CID[indexPath.row])
            return cell
        }
        else
        {
            let cell = CustomGroceryTable.dequeueReusableCell(withIdentifier: "CustomGroceryListCell") as! CustomGroceryListCell
            return cell
        }
        
    }
   
    func fetchGroceryList()
    {
        print("Inside fetch grocery")
        
        let DNS = RestApiUrl()
        
        var request = URLRequest(url: URL(string: DNS.aws + "/SmartFridgeBackend/groceryList/"+UserID)!)
        request.httpMethod = "GET"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [] ,options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        
        //let session = URLSession.shared
        
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in print( response ?? "Error connecting to Rest API - GET Grocery List")
            if error != nil
            {
                print("Failed to connect to Grocery List API")
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
                    print("Retrived grocery list")
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    print("Failed to retrive grocery list")
                }
            }
            
            DispatchQueue.main.async
            {
                self.GroceryTable.reloadData()
                self.CustomGroceryTable.reloadData()
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
            
            let GroceryItem = GroceryItemModel()
            
            let id = jsonElement["ListID"] as? Int
            let uid = jsonElement["UserID"] as? Int
            let name = jsonElement["FoodItemName"] as? String
            let type = jsonElement["Type"] as? String
            
            print(id ?? 0)
            
            GroceryItem.name = name
            GroceryItem.id = id
            GroceryItem.uid = uid
            GroceryItem.type = type
            
            GroceryItems.append(GroceryItem)
            if(GroceryItem.type == "Recommended")
            {
             Names.append(GroceryItem.name ?? "Item")
             ID.append(GroceryItem.id ?? 1)
            }
            else if (GroceryItem.type == "Custom")
            {
                CNames.append(GroceryItem.name ?? "Item")
                CID.append(GroceryItem.id ?? 1)
            }
            
        }
        /*print(Names)
        print(ID)
        
        print(CNames)
        print(CID)*/
        //self.GroceryTable.reloadData()
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
            DeleteName = Names[indexPath.row]
            deleteItem(ItemName: DeleteName)
            
            Names.remove(at: indexPath.row)
            ID.remove(at: indexPath.row)
            GroceryTable.reloadData()
        }
    }
    
    func deleteItem(ItemName : String)
    {
        print("Inside delete fridge item")
        
        
        let DNS = RestApiUrl()
        
        var request = URLRequest(url: URL(string: DNS.aws + "/SmartFridgeBackend/groceryList/delete/1/"+ItemName)!)
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
    
    
    @IBAction func Refresh(_ sender: UIButton)
    {
        Names = Array<String>()
        ID = Array<Int>()
        
        CNames = Array<String>()
        CID = Array<Int>()
        
        fetchGroceryList()
    }
    
    
    
}
