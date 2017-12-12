//
//  Profile.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/28/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class Profile: UIViewController {

    @IBOutlet weak var Fname: UITextField!
    @IBOutlet weak var Lname: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Contact: UITextField!
    @IBOutlet weak var Uname: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var EmailId = String()
    var ContactNo = String()
    var Address = String()
    var Username = String()
    var Lastname = String()
    var FirstName = String()
    
    var UserID = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        print("User id from defaults")
        print(preferences.object(forKey: "UserId") ?? "no UID")
        UserID = preferences.object(forKey: "UserId") as! String
        
        SaveButton.setTitleColor(UIColor.gray, for: .disabled)
        
        displayProfile()
        
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    func loadData()
    {
        Fname.text = FirstName
        Lname.text = Lastname
        Email.text = EmailId
        Uname.text = Username
    }
    
    func displayProfile()
    {
        print("Inside fetch list")
        
        let DNS = RestApiUrl()
        
        var request = URLRequest(url: URL(string: DNS.aws + "/SmartFridgeBackend/user/"+UserID)!)
        request.httpMethod = "GET"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [] ,options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in print( response ?? "Error connecting to Rest API - GET user profile")
            
            if error != nil
            {
                print("Failed to connect to get user profile API")
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
                    print("Retrived profile")
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    print("Failed to retrive profile")
                }
            }
            
            DispatchQueue.main.async
            {
                    self.loadData()
            }
        })
        
        task.resume()
        
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
        
        let E = jsonResult["EmailId"] as? String
        //let C = jsonResult["ContactNo"] as? String
        //let A = jsonResult["Address"] as? String
        let U = jsonResult["Username"] as? String
        let L = jsonResult["LastName"] as? String
        let F = jsonResult["FirstName"] as? String
        
        EmailId = E!
        //ContactNo = C!
        //Address = A!
        Username = U!
        Lastname = L!
        FirstName = F!
        
    }
        
        
    @IBAction func Edit(_ sender: UIButton)
    {
        Fname.isUserInteractionEnabled = true
        Fname.becomeFirstResponder()
    
        Lname.isUserInteractionEnabled = true
        Lname.becomeFirstResponder()
        
        Email.isUserInteractionEnabled = true
        Email.becomeFirstResponder()
        
        Contact.isUserInteractionEnabled = true
        Contact.becomeFirstResponder()
        
        Uname.isUserInteractionEnabled = true
        Uname.becomeFirstResponder()
        
        SaveButton.isUserInteractionEnabled = true
    }
    
    @IBAction func Save(_ sender: UIButton)
    {
        
    }
    
    @IBAction func logout(_ sender: UIButton)
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "UserId")
        defaults.synchronize()
        self.performSegue(withIdentifier: "logout", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
