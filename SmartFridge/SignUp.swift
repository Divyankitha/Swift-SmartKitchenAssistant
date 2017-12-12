//
//  SignUp.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/10/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class SignUp: UIViewController
{
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmailId: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtContactNum: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTage=textField.tag+1;
        // Try to find next responder
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    */
    
    
    @IBAction func addUser(_ sender: Any) {
        
        let DNS = RestApiUrl ()
        
        let firstName = txtFirstName.text
        let lastName = txtLastName.text
        let emailId = txtEmailId.text
        let addr = txtAddress.text
        let contact = txtContactNum.text
        let username = txtUsername.text
        let pwd = txtPassword.text
        
        
        if(username?.isEmpty)!{
            showAlert(title: "Register", message: "Please enter the username")
        }
        
        if(pwd?.isEmpty)!{
            showAlert(title: "Register", message: "Please enter the password")
        }
        
        
        let params = ["firstname":firstName,"lastname":lastName,"emailId":emailId,"username":username,"password":pwd,"address":addr,"contactNo":contact]
        
        var request = URLRequest(url:URL(string:DNS.aws+"//SmartFridgeBackend/user/addNewUser")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print( response ?? "Error connecting to Rest API - Sign up")
            if error != nil
            {
                print(error!)
            }
            else
            {
                print("Connected to Signup API")
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    
                    self.showAlert(title: "Register", message: "User registered successfully")
                    /*let defaults = UserDefaults.standard
                    
                    defaults.set(self.getUserId(data!), forKey: "UserId")
                    defaults.synchronize()*/
                    
                    self.clearFields()
                    
                    /*DispatchQueue.main.async{
                        self.performSegue(withIdentifier: "checkSignUp", sender: nil)
                    }*/
                    DispatchQueue.main.async
                        {
                            let defaults = UserDefaults.standard
                            defaults.set(self.getUserId(data!),forKey: "UserId")
                            defaults.synchronize()
                            self.performSegue(withIdentifier: "checkLogin", sender: nil)
                    }
                }
                else
                {
                    self.showAlert(title: "Register", message: "Registration failed. Try again")
                }
            }
            
        })
        
        task.resume()
        
    }
    
    func clearFields(){
        txtFirstName.text=""
        txtLastName.text=""
        txtEmailId.text=""
        txtAddress.text=""
        txtContactNum.text=""
        txtUsername.text=""
        txtPassword.text=""
    }
    
    func getUserId(_ data:Data) -> Int
    {
        
        var jsonResult = NSDictionary()
        
        do{
            
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            print(jsonResult)
            
        } catch let error as NSError
        {
            print(error)
        }
        
        let UID = jsonResult["UserId"] as? Int
        
        print(UID ?? "No UID")
        
        return UID!
    }
    
    func showAlert(title:NSString,message:NSString)
    {
        let alertController:UIAlertController=UIAlertController(title:title as String, message: message as String as String, preferredStyle: UIAlertControllerStyle.alert)
        let successAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
        }
        alertController.addAction(successAction)
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
