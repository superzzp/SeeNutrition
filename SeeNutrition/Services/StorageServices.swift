//
//  UserServices.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2022-05-28.
//  Copyright © 2022 Alex Zhang. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore



class StorageServices {
    
    static func queryUserDataByUid(uid: String, completion: @escaping (Result<[String:Any],Error>) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        let query = usersRef.whereField("uid", isEqualTo: uid)
        query.getDocuments() { querySnapshot, err in
            if let err = err {
                completion(.failure(err))
            } else {
                for document in querySnapshot!.documents {
                    completion(.success(document.data()))
                }
            }
        }
    }
    
    static func storeUserProfile(_ firstName: String,_ lastName: String,_ email: String,_ uid: String, completion: @escaping (Result<Any,Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").addDocument(data: ["firstname" : firstName, "lastname" : lastName, "email" : email, "uid" : uid]) { error in
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.success("Successfully Store Profile of user: " + uid))
            }
        }
    }
}
