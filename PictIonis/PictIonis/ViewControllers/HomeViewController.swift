//
//  HomeViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 11/08/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    
    var menuOut = false;
    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthenticateUser()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    
    @IBAction func menuTapped(_ sender: Any) {
        if menuOut == false {
            leading.constant = 150
            trailing.constant = -150
            menuOut = true
        } else {
            leading.constant = 0
            trailing.constant = 0
            menuOut = false
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animatioinComplete) in
            print("The animation is complete!")
        }
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            
            let viewController = self.storyboard?.instantiateViewController(identifier: "viewController") as? ViewController
            
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
        }
        catch {
            print("An error occurred on log out")
        }
    }
    
    @IBAction func transitionToDrawScreen(_ sender: Any) {
        let drawViewController = storyboard?.instantiateViewController(identifier: "drawViewController") as? DrawViewController
        
        view.window?.rootViewController = drawViewController
        view.window?.makeKeyAndVisible()
    }
    
    func checkAuthenticateUser() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let viewController = self.storyboard?.instantiateViewController(identifier: "viewController") as? ViewController
                
                self.view.window?.rootViewController = viewController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
    
}
