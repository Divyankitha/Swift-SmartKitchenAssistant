//
//  AddToGroceryList.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 11/29/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit
import Speech

class AddToGroceryList: UIViewController, SFSpeechRecognizerDelegate
{

    @IBOutlet weak var DisplayItemName: UITextField!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    
    private var recognitionRequest : SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask : SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var speech = String("")
    
    var speechFinal = String("")
    
    var str = String("")
    
    var UserID = String()
    
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        print("User id from defaults")
        print(preferences.object(forKey: "UserId") ?? "no UID")
        UserID = preferences.object(forKey: "UserId") as! String
        
        recordButton.isEnabled = false
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override public func viewDidAppear(_ animated: Bool)
    {
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    @IBAction func Record(_ sender: UIButton)
    {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            //recordButton.setTitle("Stopping", for: .disabled)
        } else {
            try! startRecording()
            //recordButton.setTitle("Stop recording", for: [])
        }
    }
    
    @IBAction func SaveItem(_ sender: UIButton)
    {
        print("Inside save item")
        print(speechFinal)
        
        str = DisplayItemName.text ?? "Dummy"
        
        DisplayItemName.endEditing(true)
        
        let DNS = RestApiUrl ()
        
        let params = ["UserId":UserID, "FoodItemName":str,"Type": "Custom"] as Dictionary<String,String>
        
        
        var request = URLRequest(url: URL(string: DNS.aws + "/SmartFridgeBackend/groceryList/addGroceryListItem")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        print("Printing response next")
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print( response ?? "Error connecting to Rest API - Add Items to Grocery list")
            if error != nil
            {
                print("Failed to connect to Add Item Grocery list API")
                print(error!)
            }
            else
            {
                print("Connected to Add Grocery list Item API")
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    print("Inserted!")
                    let alert = UIAlertController(title: "Smart Refrigerator", message: "Item Added To Grocery List", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    let alert = UIAlertController(title: "Smart Refrigerator", message: "Item Not Added To Grocery List, Retry!" , preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        })
        
        task.resume()
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            //recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
           // recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.DisplayItemName.text = result.bestTranscription.formattedString
                self.speech = result.bestTranscription.formattedString
                //print(self.speech)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal
            {
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
                print(self.DisplayItemName.text)
                self.speechFinal = self.DisplayItemName.text!
                print(self.speechFinal)
                //self.AddToDB()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        DisplayItemName.text = "(Go ahead, We're listening)"
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
