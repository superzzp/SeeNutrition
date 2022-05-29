//
//  AppDelegate.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2018-12-27.
//  Copyright © 2022 Alex Zhang. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Configure Firebase auth and storage.
        FirebaseApp.configure()
        // Configure users and initial view.
        configureInitialRootViewController(for: window)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Helper function, setting the initialViewController to window, and also get the default user from System if the user previously logged in
    func configureInitialRootViewController(for window: UIWindow?) {

        let defaults = UserDefaults.standard
        let initialViewController: UIViewController
    
        if let _ = Auth.auth().currentUser,
        let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data,
        let user = try? JSONDecoder().decode(User.self, from: userData)
        {   // If users is logged in and is in UserDefault
            // Set current user to singleton, but no need to set to UserDefault
            User.setCurrent(user)
            initialViewController = UIStoryboard.initialViewController(for: .main)
        } else {
            // If user is not logged in
            initialViewController = UIStoryboard.initialViewController(for: .login)
        }
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }

}

