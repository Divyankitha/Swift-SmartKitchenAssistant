//
//  Login.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/19/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class Login: UIViewController {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    var userID = Int()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButton(_ sender: UIButton)
    {
        
        print("From log in function" )
        print(usernameTextfield.text ?? "username Error")
        print(passwordTextfield.text ?? "password Error")
        
        let DNS = RestApiUrl ()
        
        let username = usernameTextfield.text
        let password = passwordTextfield.text
        
        
        //POST Request to Add items to fridge
        let params = ["username":username, "password":password] as! Dictionary<String,String>
        
        //print(params)
        
        var request = URLRequest(url: URL(string: DNS.aws + "/SmartFridgeBackend/user/userCredentials/verify")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        print("Printing response next")
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print( response ?? "Error connecting to Rest API - Verify user")
            if error != nil
            {
                print("Failed to connect to verify user API")
                print(error!)
            }
            else
            {
                print("Connected to Verify User API")
                print(data ?? "data")
                self.parseJSON(data!)
                
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    print("Verified!")
                    /*let alert = UIAlertController(title: "Smart Refrigerator", message: "Login successful", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)*/
                    
                    print("User ID")
                    print(self.userID)
                    
                    
                    DispatchQueue.main.async
                    {
                        let defaults = UserDefaults.standard
                        defaults.set(String(self.userID),forKey: "UserId")
                        defaults.synchronize()
                        self.performSegue(withIdentifier: "checkLogin", sender: nil)
                    }
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    /*let alert = UIAlertController(title: "Smart Refrigerator", message: "Verification Failed, Retry!" , preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)*/
                }
            }
            
        })
        
        task.resume()
        //self.performSegue(withIdentifier: "checkLogin", sender: nil)
    }
    
    
    
    func parseJSON(_ data:Data)
    {
        
        var jsonResult = NSDictionary()
        
        do{
            
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            print(jsonResult)
            
        } catch let error as NSError
        {
            print(error)
        }
        
        let UID = jsonResult["User ID"] as? Int
        userID = UID!
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "checkLogin"
        {
            print("inside prepare for segue")
            let dashboardSegue = segue.destination as? Dashboard
            dashboardSegue?.UserId = userID
            print(dashboardSegue?.UserId ?? 100)
        }
    }*/
    
    /*override func performSegue(withIdentifier identifier: String, sender: Any?)
    {
        let segue = UIStoryboardSegue
        let dashboardSegue = segue.destination as? Dashboard
        dashboardSegue?.id = userID
     
    }*/
    

}
