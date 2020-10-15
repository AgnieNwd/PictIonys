//
//  LoginViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 11/08/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var goToSignUpButton: UIButton!
    
    
    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpElements()
    }
    
    
    // MARK: - Navigation
    
    func transitionToHomeScreen() {
        if let homeViewController = storyboard?.instantiateViewController(identifier: "homeViewController") as? HomeViewController {
            let homeNav = UINavigationController(rootViewController: homeViewController)
            
            view.window?.rootViewController = homeNav
            view.window?.makeKeyAndVisible()
        }
    }
    
    func transitionToSignUpScreen() {
        let signUpViewController = storyboard?.instantiateViewController(identifier: "signUpViewController") as? SignUpViewController
        
        view.window?.rootViewController = signUpViewController
        view.window?.makeKeyAndVisible()
    }

    // MARK: - Actions

    @IBAction func LoginAction(_ sender: Any) {
        let error = checkFields()
        
        if error != nil {
            showError(error!)
        } else {
            let email = loginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: email, password: password) { (data, error) in
                if error != nil {
                    // Couldn't sign in
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                }
                else {
                    
                    // Transition to the home screen
                    self.transitionToHomeScreen()
                }
            }
        }
    }
    
    @IBAction func SignUpTransitionAction(_ sender: Any) {
        transitionToSignUpScreen()
    }
    
    // MARK: - Helper functions

    func setUpElements() {
        // Gradient Background
        view.setGradientBackground(colorOne: Colors.violet, colorTwo: Colors.instagramyBlue)
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
//        Utilities.styleTextField(loginTextField)
//        Utilities.styleTextField(passwordTextField)
        Utilities.styleHollowButton(loginButton)
        
    }
    
    func checkFields() -> String? {
        
        // Check that all fields are not empty
        if loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill out all fields completely."
        }
        
        // Check if email is valid
        let cleanedEmail = loginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isEmailValid(cleanedEmail) == false {
            Utilities.styleTextField(loginTextField, "error")
            return "Please enter a valid email address."
        } else {
            Utilities.styleTextField(loginTextField)
        }
        
        return nil
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    

}
