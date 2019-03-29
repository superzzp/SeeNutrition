//
//  LoginViewController.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2019-01-24.
//  Copyright © 2019 Alex Zhang. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase

//pre-emptively solved namespace conflict between SeeNutrition.User and FirebaseAuth.User by using type alias FIRUser
typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController, FUIAuthDelegate
{

    
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("the login button is tapped!!!")
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let authViewController = authUI?.authViewController()
        present(authViewController!, animated: true) {
            print("FirebaseUI Presented!")
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if(error != nil) {
            print(error.debugDescription)
            print(error?.localizedDescription)
            print("User cancel login or error with login!")
        }else{
            print("Signup / Login successful!")
        }
        
        //get a FIRUser instance
        guard let user: FIRUser = authDataResult?.user
            else{
                return
        }
        
        UserService.show(forUID: user.uid) { user in
            if let user = user {
                //if snapshot return an existing user info, User init successfully and user != nil
                //call singlton to set user and also set user to system default
                User.setCurrent(user, writeToUserDefaults: true);
                print("Welcome back, \(user.username)")
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
            }else{
                //if there is no existing user info in snapshot
                //if the current user has verified the email, ask user to create a username and register the user there
                if((authDataResult?.user)!.isEmailVerified == true) {
                    self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
                }else{
                    //if the user haven't verified the email, sent an verification to user
                    self.emailVerification(firUser: (authDataResult?.user)!)
                    do {
                        try Auth.auth().signOut()
                        self.dismiss(animated: true, completion: nil)
                    } catch let err {
                        print(err)
                    }
                }
            }
        }
    }
    
    private func emailVerification(firUser: FIRUser){
        firUser.sendEmailVerification { error in
            if (error != nil) {
                print("email is invalid!")
                self.showToast(message: "email is invalid!")
                print(error.debugDescription)
                print("===============================")
                print(error?.localizedDescription)
            }else{
                print("email is sent! Please verify your email!")
                self.showToast(message: "Please verify your email and login again!")
            }
        }
    }
}


