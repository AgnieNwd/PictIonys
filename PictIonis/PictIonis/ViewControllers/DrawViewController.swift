//
//  DrawViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 09/09/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DrawViewController: UIViewController {
    var uid = ""
    var idGame: String = ""
    var user: [String:String] = [:]
    var firstname = ""
    var lastname = ""
    
    private lazy var drawRef: DatabaseReference! = Database.database().reference(withPath: "Drawing").child(idGame)
    
    // MARK: - Properties

    @IBOutlet weak var collectionColorView: UICollectionView!
    
    @IBOutlet weak var canvasView: CanvasView!
    
    @IBOutlet weak var rootStackView: UIStackView!
    
    @IBOutlet weak var messagesTableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    var colorsArray: [String] = ["000000", "ffffff", "ff0000", "0080FF", "009c46", "ff6124", "ffa600", "9b00e5", "e500e5"]
   
    var messages = [[String:String]]()

    var isOwner = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Color list
        collectionColorView.delegate = self
        collectionColorView.dataSource = self
        
        // Messages list
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        
        // Message input
        messageTextField.delegate = self
        
        // Back button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(transitionToHomeScreen))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        canvasView.idGame = idGame
        
        // First load lines
        drawRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let author = value?["author"] as? NSDictionary
            
            if let email = author?["email"] as? String, Auth.auth().currentUser?.email != email {
                self.canvasView.isUserInteractionEnabled = false
                self.rootStackView.isUserInteractionEnabled = false
                self.rootStackView.isHidden = true
                
                if let lines = value?["lines"] as? NSDictionary {
                    let tmp = lines.allValues.compactMap { $0 as? [String: Any] }
                    
                    self.canvasView.addNewLines(tmp)
                } else if let lines = value?["lines"] as? [Any] {
                    let tmp = lines.compactMap { $0 as? [String: Any] }
                    
                    self.canvasView.addNewLines(tmp)
                }
                
                self.observeNewPoints()
            } else {
                self.isOwner = true
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        observeNewMessage()
    }
    
    // MARK: API

    func observeNewPoints() {
        drawRef.child("lines").observe(.childChanged, with: { snapshot in
            if let key = Int(snapshot.key), let line = snapshot.value as? [String: Any] {
                self.canvasView.addNewLine(line, for: key)
            } else if let lines = snapshot.value as? [Any] {
                
                _ = lines.compactMap { $0 as? [String: Any] }
            }
        })
        
        drawRef.child("lines").observe(.childRemoved, with: { snapshot in
            self.canvasView.undoDraw()
        })
    }
    
    func observeNewMessage() {
        drawRef.child("chat").observe(.childAdded, with: { snapshot in
           let value = snapshot.value as? NSDictionary

            guard let username = value?["username"] as? String else { return }
            guard let message = value?["message"] as? String else { return }
            
            self.messages.append(["username": username, "mess": message])
            self.messagesTableView.reloadData()
            self.messagesTableView.scrollToRow(at: IndexPath(row: (self.messages.count - 1), section: 0), at: .bottom, animated: true)
        })
    }
    
    // MARK: - Actions

    @IBAction func onClickUndo(_ sender: Any) {
        canvasView.undoDraw()
    }
    
    @IBAction func onClickClear(_ sender: Any) {
        canvasView.clearCanvasView()
    }
    
    @IBAction func onChangeBrushSize(_ sender: UISlider) {
        canvasView.strokeWidth = CGFloat(sender.value)
    }
    
    @IBAction func onClickSend(_ sender: Any) {
        let message = messageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        print(message, user);
        let newDrawRef = drawRef.child("chat/").childByAutoId()
        let messageInfo = [
            "username": user["firstname"],
            "message": message
        ]
        
        newDrawRef.setValue(messageInfo)

        messageTextField.text = nil
    }
    
    
    // MARK: - Navigation
    
    @objc private func transitionToHomeScreen() {
        if (isOwner) {
            drawRef.removeValue()
            print("deleted")
        }
        navigationController?.popViewController(animated: true)
    }

}

extension DrawViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let view = cell.viewWithTag(111) as UIView? {
            view.backgroundColor = UIColor.hexStringToUIColor(hex: colorsArray[indexPath.row])
            view.layer.cornerRadius = 3
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        canvasView.strokeColor = colorsArray[indexPath.row]
    }
    
    
}

extension DrawViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]["mess"]
        cell.detailTextLabel?.text = messages[indexPath.row]["username"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show chat message 
    }
}


extension DrawViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
