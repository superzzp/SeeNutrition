//
//  UserService.swift
//  SeeFood
//
//  Created by Alex Zhang on 2019-01-24.
//  Copyright © 2019 Alex Zhang. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


struct UserService {
    
    //create a new user with the given username, save the user record on firebase, and set current user with the new user
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            //processed added user info
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                User.setCurrent(user!)
                completion(user)
            })
        }
    }
    
    static func show (forUID uid: String, completion: @escaping (User?) -> Void) {
        print("USER SERVICE SHOW METHOD LINE 37")

        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(user)
        })
    }
}
