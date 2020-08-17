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

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil) {
            
        }
    }
    
    func checkCurrentUserInfo() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(LoginButton)
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(LoginButton)
    }


}

