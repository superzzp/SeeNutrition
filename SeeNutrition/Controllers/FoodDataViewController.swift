//
//  FoodDataViewController.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2019-01-15.
//  Copyright © 2022 Alex Zhang. All rights reserved.
//

import Foundation
import UIKit

class FoodDataViewController: UIViewController, UINavigationControllerDelegate {
    
    var nutritionD: NutritionData!
    
    @IBOutlet weak var foodDataTextView: UITextView!
    
    override func viewDidLoad() {
        
        foodDataTextView.text = "\n\n\(nutritionD.food_name)\n" + "\(nutritionD.serving_qty) \(nutritionD.serving_unit)\n" + "(each \(nutritionD.serving_weight_grams) grams)\n" + "\n" + "calories: \(nutritionD.nf_calories)\n" + "fat: \(nutritionD.nf_total_fat)g\n" + "sodium: \(nutritionD.nf_sodium)mg\n" + "carbohydrate: \(nutritionD.nf_total_carbohydrate)g\n" + "sugars: \(nutritionD.nf_sugars)g\n" + "protein: \(nutritionD.nf_protein)g\n" + "fiber: \(nutritionD.nf_dietary_fiber)g"
        initializeDesigns()
        
    }
    
    func initializeDesigns() {
        foodDataTextView.layer.cornerRadius = 5
        foodDataTextView.layer.borderWidth = 2
        foodDataTextView.layer.borderColor = UIColor.white.cgColor
        foodDataTextView.layer.backgroundColor = UIColor(red: 0, green: 145.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
    }
    
    
}
