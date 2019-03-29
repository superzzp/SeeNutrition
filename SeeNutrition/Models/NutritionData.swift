//
//  NutritionData.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2019-01-15.
//  Copyright © 2019 Alex Zhang. All rights reserved.
//

import Foundation

class NutritionData {
    var food_name: String
    var brand_name: String
    var serving_unit: String
    
    var serving_qty: Int
    var serving_weight_grams: Int
    var nf_calories: Int
    
    var nf_total_fat: Double
    var nf_saturated_fat: Double
    var nf_cholesterol: Double
    var nf_sodium: Double
    var nf_total_carbohydrate: Double
    var nf_dietary_fiber: Double
    var nf_sugars: Double
    var nf_protein: Double
    var nf_potassium: Double
    var nf_p: Double
    
    init(){
        food_name = ""
        brand_name = ""
        serving_unit = ""
        
        serving_qty = 0
        serving_weight_grams = 0
        nf_calories = 0
        
        nf_total_fat = 0.0
        nf_saturated_fat = 0.0
        nf_cholesterol = 0.0
        nf_sodium = 0.0
        nf_total_carbohydrate = 0.0
        nf_dietary_fiber = 0.0
        nf_sugars = 0.0
        nf_protein = 0.0
        nf_potassium = 0.0
        nf_p = 0.0
    }
}


