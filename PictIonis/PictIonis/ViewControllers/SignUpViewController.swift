//
//  SignUpViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 11/08/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var goToLogInButton: UIButton!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()

    }
    
    
    // MARK: - Actions

    @IBAction func signUpAction(_ sender: Any) {
        let error = checkFields()
        
        if error != nil {
            showError(error!)
        } else {
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create user
            Auth.auth().createUser(withEmail: email, password: password) { (data, error) in
                if error != nil {
                    self.showError("Error on create user")
                } else {
                    let db = Firestore.firestore()
                    // Add a new document with a generated ID
                    db.collection("users").addDocument(data: [
                        "firstname": firstName,
                        "lastname": lastName,
                        "email": email,
                        "uid": data!.user.uid
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                    
                    // Transition to the home screen
                    self.transitionToHomeScreen()
                }
            }
        }
    }
    
    // MARK: - Navigation

     func transitionToHomeScreen() {
         
         let homeViewController = storyboard?.instantiateViewController(identifier: "homeViewController") as? HomeViewController
         
         view.window?.rootViewController = homeViewController
         view.window?.makeKeyAndVisible()
         
     }
    
    @IBAction func transitionToLogInScreen(_ sender: Any) {
        let logInViewController = storyboard?.instantiateViewController(identifier: "logInViewController") as? LoginViewController
                
        view.window?.rootViewController = logInViewController
        view.window?.makeKeyAndVisible()
    }
    
    // MARK: - Helper functions
    
    func setUpElements() {
        // Gradient Background
        view.setGradientBackground(colorOne: Colors.violet, colorTwo: Colors.instagramyBlue)
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
//        Utilities.styleTextField(firstNameTextField)
//        Utilities.styleTextField(lastNameTextField)
//        Utilities.styleTextField(emailTextField)
//        Utilities.styleTextField(passwordTextField)
        Utilities.styleHollowButton(signUpButton)
        
    }
    
    func checkFields() -> String? {
        
        // Check that all fields are not empty
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill out all fields completely."
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            Utilities.styleTextField(passwordTextField, "error")
            return "Please make sure your password is at least 8 characters, contains one Uppercase & one Lowercase alphabet and a number."
        } else {
            Utilities.styleTextField(passwordTextField)
        }
        
        // Check if is email type
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if Utilities.isEmailValid(cleanedEmail) == false {
            Utilities.styleTextField(emailTextField, "error")
            return "Please enter a valid email address."
        } else {
            Utilities.styleTextField(emailTextField)
        }
        
        return nil
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    
}
