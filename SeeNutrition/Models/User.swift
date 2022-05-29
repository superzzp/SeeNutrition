//
//  User.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2019-01-24.
//  Copyright © 2022 Alex Zhang. All rights reserved.
//

import Foundation

class User: Codable{
    
    // Setup singlton
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    
    // MARK: - Class Methods
    
    let uid: String
    let firstName: String
    let lastName: String
    
    init(uid: String, firstName: String, lastName: String){
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
    }
    
    //    failable initializer
    //    handle existing users
    //    if a user doesn't have a UID or a username, fail the initialization and return nil.
//    init?(snapshot: DataSnapshot) {
//        guard let dict = snapshot.value as? [String : Any],
//            let username = dict["username"] as? String
//            else{return nil}
//        self.uid = snapshot.key
//        self.username = username
//    }
//
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
    
    //return the current user's first name if it exist, otherwise return nil
    static func getCurrentFirstName() -> String?{
        return _current?.firstName
    }

}
