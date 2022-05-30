//
//  LoginUserPwdViewController.swift
//  SeeNutrition
//
//  Created by Alex Zhang on 2022-05-27.
//  Copyright © 2022 Alex Zhang. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        // Validate Text Fields
        if let error = validateFields() {
            showError(error)
        } else {
            // Create clean version of the text fields
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // Signing in the users
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let err = error {
                    self.errorLabel.text = err.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    StorageServices.queryUserDataByUid(uid: result!.user.uid) { (serviceResult) in
                    switch serviceResult {
                        case .failure(let error):
                            // Error storing the user profile
                            self.showError(error.localizedDescription)
                        case .success(let userData):
                            // Transition to the main screen
                            if let firstName = userData["firstname"] as? String,
                               let lastName = userData["lastname"] as? String,
                               let _ = userData["email"] as? String {
                                User.setCurrent(User(uid: result!.user.uid, firstName: firstName, lastName: lastName), writeToUserDefaults: true)
                                self.transitionToMain()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToMain() {
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    func validateFields() -> String? {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        // Check that all fields are filled in
        let cleanPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanPassword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0;
        
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
