//
//  User.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2019-01-24.
//  Copyright © 2019 Alex Zhang. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: Codable{
    
    // Setup singlton
    // 1
    private static var _current: User?
    
    // 2
    static var current: User {
        // 3
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        // 4
        return currentUser
    }
    
    // MARK: - Class Methods
    
    // 5
    let uid: String
    let username: String
    
    
    init(uid: String, username: String){
        self.uid = uid
        self.username = username
    }
    
    //method to persist the current user to UserDefaults so that user don't need to log in repetitively
    //also set the singleton _user = user
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            if let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
            }
        }
        _current = user
    }
    
    //return the current username if it exist
    static func getCurrent() -> String?{
        return _current?.username
    }
    
    
    //    failable initializer
    //    handle existing users
    //    if a user doesn't have a UID or a username, we'll fail the initialization and return nil.
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String
            else{return nil}
        
        self.uid = snapshot.key
        self.username = username
        
    }
    
}
