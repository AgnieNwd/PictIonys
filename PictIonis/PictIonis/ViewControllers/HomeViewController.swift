//
//  HomeViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 11/08/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController {
    // MARK: - Properties

    let uid = Auth.auth().currentUser?.uid
    var user: [String:String] = [:]

    private lazy var drawRef: DatabaseReference! = Database.database().reference(withPath: "Drawing")
    private var drawRefHandle: DatabaseHandle?
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var menuOut = false;
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colorOne: Colors.violet, colorTwo: Colors.instagramyBlue)
        checkAuthenticateUser()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameListViewController = segue.destination as? GameListViewController {
            gameListViewController.delegate = self
        }
    }
    
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
        guard let drawViewController = storyboard?.instantiateViewController(identifier: "drawViewController") as? DrawViewController else { return }
      
        let newDrawRef = drawRef.childByAutoId()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        let _game = [
            "status":  "up",
            "author": [
                "email" : Auth.auth().currentUser?.email,
                "firstname": user["firstname"],
                "lastname": user["lastname"]
            ],
            "nb_users": "0",
            "date":   formatter.string(from: Date())
            ] as [String : Any]
        
        newDrawRef.setValue(_game)
        
        drawViewController.idGame = newDrawRef.key ?? ""
        drawViewController.user = user
        drawViewController.uid = uid ?? ""
        navigationController?.pushViewController(drawViewController, animated: true)
    }
    
    func checkAuthenticateUser() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let viewController = self.storyboard?.instantiateViewController(identifier: "viewController") as? ViewController
                
                self.view.window?.rootViewController = viewController
                self.view.window?.makeKeyAndVisible()
            }
        } else {
            loadUserData()
        }
    }
    
    // MARK: - API
      func loadUserData() {
        Database.database().reference(withPath: "users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.user = [
                "email" : Auth.auth().currentUser?.email ?? "",
                "lastname": value?["lastname"] as? String ?? "",
                "firstname": value?["firstname"] as? String ?? ""
            ]
                
//            self.firstname = value?["firstname"] as? String ?? ""

            self.welcomeLabel?.text = "Welcome " + self.user["firstname"]! + " " + self.user["lastname"]!

//            print(">>>>>>>>> last frist name ", lastname, firstname)
        }) { (error) in
            print(error.localizedDescription)
        }
      }
}

extension HomeViewController: GameListViewControllerDelegate {
    func gameListViewControllerDidSelect(game: Game) {
        if let drawViewController = storyboard?.instantiateViewController(identifier: "drawViewController") as? DrawViewController {
            drawViewController.idGame = game.id
            drawViewController.user = user
            drawViewController.uid = uid ?? ""
            navigationController?.pushViewController(drawViewController, animated: true)
        }
    }
}
