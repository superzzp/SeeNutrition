//
//  Constants.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2019-01-17.
//  Copyright © 2019 Alex Zhang. All rights reserved.
//

import Foundation

//A list of pre-defined Constants including critical api keys
//Do not upload this file online!!! Use .gitignore to exclude this file from tracking for all time

struct Constants {
    
    struct NUIX {
        static var nuixAppId = "562a4d10"
        static var nuixAppKeys = "c15dcf92be673e11bb3347fea34063f6"
        static var nuixURL = "https://trackapi.nutritionix.com/v2/natural/nutrients"
        static var nuixTimeZone = "US/Eastern"
    }
    
    
    struct Segue {
        static var toCreateUsername = "toCreateUsername"
    }
    
    struct UserDefaults {
        static var currentUser = "currentUser"
    }
}
