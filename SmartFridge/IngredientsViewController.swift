//
//  IngredientsViewController.swift
//  SmartFridge
//
//  Created by Divyankitha Raghava Urs on 12/8/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit

class IngredientsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var foodName: UILabel!
    var Names = ["abc","ada","Asd"]
    @IBOutlet weak var ingredientsTable: UITableView!
    
    var foodLabel = String()
    var ingredients = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ingredientsTable.delegate = self
        ingredientsTable.dataSource = self
        print("Inside ingredient view controller")
        print(foodLabel)
        foodName.text = foodLabel
        print(ingredients)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ingredients.count; //retun the number of items
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = ingredientsTable.dequeueReusableCell(withIdentifier: "ingredientsCell") as! IngredientsTableViewCell
        
       // print(Names)
        //row = Names.count
        cell.ingredientLabel.text = ingredients[indexPath.row]
        return cell
    }
    
    
    
}
