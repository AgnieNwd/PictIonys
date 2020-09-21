//
//  ViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 11/08/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil) {
            transitionToHomeScreen()
        }
        
    }
    
    // MARK: - Navigation

        func transitionToHomeScreen() {
            
            let homeViewController = storyboard?.instantiateViewController(identifier: "homeViewController") as? HomeViewController
            
            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
            
        }
    
    // MARK: - Helper functions

    func checkCurrentUserInfo() {
       
    }
    
    func setUpElements() {
        // Gradient Background
        view.setGradientBackground(colorOne: Colors.violet, colorTwo: Colors.instagramyBlue)

        Utilities.styleFilledButton(LoginButton)
        Utilities.styleHollowButton(signUpButton)
    }


}

