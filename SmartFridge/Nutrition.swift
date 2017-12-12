//
//  Nutrition.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 12/7/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit
import Charts

class Nutrition: UIViewController
{
    @IBOutlet weak var calorieHeading: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    let surveyData = ["cat": 30, "dog": 30, "both": 55, "neither": 45]
    var ingredientsList = [String]()
    
    let pieChart: PieChartView =
    {
        let p = PieChartView()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.noDataText = "No Nutrition Details to display"
        p.chartDescription?.text = "Nutrition Details in grams"
        return p
    }()
    
    var recipeName = String()
    //var recipeID = String()
    var recipeID = "1c69db7338963701e07eb309896b7c79"
    var nutrients = [String:Double] ()
    var calories = Double()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        getNutrition(recipe_id: recipeID)
        //getRecipeID(recipe_name: recipeName)
        print(recipeName)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    func getRecipeID(recipe_name:String)
    {
        //get the recipie ID
        //call get nutrition
        let api = RestApiUrl().aws+"/SmartFridgeBackend/recipe/"+recipe_name
        
        var request = URLRequest(url: URL(string: api)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        //sessionConfig.timeoutIntervalForRequest = 100.0
        //sessionConfig.timeoutIntervalForResource = 100.0
        
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in print( response ?? "Error connecting to Rest API - GET Recipe ID")
            if error != nil
            {
                print("Failed to connect")
                print(error!)
            }
            else
            {
                print("Data Obtained")
                
                //self.parseJSON(data!)
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    var jsonResult = NSDictionary()
                    
                    do{
                        
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                        print(jsonResult)
                        
                    } catch let error as NSError
                    {
                        print(error)
                    }
                    
                    self.recipeID = (jsonResult["Id"] as? String)!
                    print(self.recipeID)
                    
                    DispatchQueue.main.async
                    {
                        self.getNutrition(recipe_id: self.recipeID)
                    }
                    
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    print("Failed to retrive recipie ID")
                }
            }
            
        })
        
        task.resume()
        
    }
    
    func getNutrition(recipe_id: String)
    {
        let api = RestApiUrl()
        let finalURL1 = api.nutritionAPI + recipe_id
        let finalURL2 = "&app_id=" + api.appID
        let finalURL3 = "&app_key=" + api.apiKey
        let finalURL = finalURL1 + finalURL2 + finalURL3
        print(finalURL)
        
        var request = URLRequest(url: URL(string: finalURL)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 100.0
        sessionConfig.timeoutIntervalForResource = 100.0
        
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in print( response ?? "Error connecting to Rest API - GET Nutrition values")
            if error != nil
            {
                print("Failed to connect to Nutrition API")
                print(error!)
            }
            else
            {
                print("Nutrition Data Obtained")
                
                self.parseJSON(data!)
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    print("Retrived Nutrition information")
                    
                    DispatchQueue.main.async
                    {
                            self.view.backgroundColor = UIColor(white: 1, alpha: 1)
                            self.calorieHeading.text = "Calorie Count:"
                            self.calorieLabel.text = String(format:"%f", self.calories)
                            self.setupPieChart()
                            self.fillChart()
                    }
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    print("Failed to retrive nutrition information")
                }
            }
            
        })
        
        task.resume()
    }
    
    func parseJSON(_ data:Data)
    {
        
        
        var json: [Any]?
        do {
            json = try JSONSerialization.jsonObject(with: data) as? [Any]
            //print(json ?? "error json")
             guard let item = json?.first as? [String: Any],
                let cal = item["calories"] as? Double,
                let nutrients = item["totalNutrients"] as? [String: Any],
                let fat = nutrients["FAT"] as? [String: Any],
                let fat_quantity = fat["quantity"] as? Double,
            let chole = nutrients["CHOLE"] as? [String: Any],
            let choles_quantity = chole["quantity"] as? Double,
            let carbs = nutrients["CHOCDF"] as? [String:Any],
            let carbs_quantity = carbs["quantity"] as? Double,
                let fiber = nutrients["FIBTG"] as? [String:Any],
                let fiber_quantity = fiber["quantity"] as? Double,
                let sugar = nutrients["SUGAR"] as? [String:Any],
                let sugar_quantity = sugar["quantity"] as? Double,
                let protein = nutrients["PROCNT"] as? [String:Any],
                let protein_quantity = protein["quantity"] as? Double,
                let vita = nutrients["VITA_RAE"] as? [String:Any],
                let vita_quantity = vita["quantity"] as? Double,
                let vitc = nutrients["VITC"] as? [String:Any],
                let vitc_quantity = vitc["quantity"] as? Double,
                let ingredients = item["ingredientLines"] as? [String]
                else{
            return
            }
            
            self.calories = cal
            self.nutrients["Fat"] = fat_quantity
            self.nutrients["cholestrol"] = choles_quantity
            self.nutrients["carbs"] = carbs_quantity
            self.nutrients["Fiber"] = fiber_quantity
            self.nutrients["Sugar"] = sugar_quantity
            self.nutrients["Protein"] = protein_quantity
            self.nutrients["Vitamin A"] = vita_quantity
            //self.nutrients["Vitamin C"] = vitc_quantity
            print(ingredients)
            ingredientsList = ingredients
            //loop over nutrients
            /*for (key, value) in self.nutrients {
                print("\(key): \(value)")
            }*/
            
        } catch {
            print("Error deserializing JSON: \(error)")
        }
        
    }
    
    func setupPieChart()
    {
        view.addSubview(pieChart)
        
        pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        pieChart.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        pieChart.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        pieChart.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        
    }
    
    func fillChart()
    {
        var dataEntries = [PieChartDataEntry]()
        var DE = [PieChartDataEntry]()
        var colorPieChart = [UIColor]()
        
        colorPieChart.append(UIColor.purple)
        colorPieChart.append(UIColor.green)
        colorPieChart.append(UIColor.yellow)
        colorPieChart.append(UIColor.red)
        colorPieChart.append(UIColor.cyan)
        colorPieChart.append(UIColor.orange)
        colorPieChart.append(UIColor.blue)
        colorPieChart.append(UIColor.magenta)
            

        for (key, val) in nutrients
        {
            let entry = PieChartDataEntry(value: Double(val), label: key)
            dataEntries.append(entry)
        }
        
        for (key, val) in nutrients
        {
            let e = PieChartDataEntry(value: Double(val), label: key)
            DE.append(e)
        }
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = colorPieChart //ChartColorTemplates.colorPieChart //joyful()//colorful()//pastel()//   material()
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 10
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        pieChart.data = chartData
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "gotoIngredients"
        {
            print("inside prepare for segue")
            let ingredientSegue = segue.destination as? IngredientsViewController
            ingredientSegue?.ingredients = ingredientsList
            ingredientSegue?.foodLabel = recipeName
            
        }
    }
    

}
