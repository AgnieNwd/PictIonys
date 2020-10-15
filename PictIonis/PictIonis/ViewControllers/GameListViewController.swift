//
//  GameListViewController.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 02/10/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol GameListViewControllerDelegate: AnyObject {
    func gameListViewControllerDidSelect(game: Game)
}

class GameListViewController: UIViewController {
    private lazy var drawRef: DatabaseReference! = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    var games = [Game]()
    
    weak var delegate: GameListViewControllerDelegate?

    @IBOutlet weak var gameListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameListTableView.dataSource = self
        gameListTableView.delegate = self
        
        drawRef.child("Drawing").observe(.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? NSDictionary
            let author = value?["author"] as? NSDictionary

            guard let firstname = author?["firstname"] as? String else { return }
            guard let date = value?["date"] as? String else { return }
            
            let aGame = Game(id: snapshot.key, name: firstname, date: date)

            self.games.append(aGame)
            self.gameListTableView.reloadData()
        })
    }
}

extension GameListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        dismiss(animated: true) {
            self.delegate?.gameListViewControllerDidSelect(game: self.games[indexPath.row])
        }
    }
}

extension GameListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = games[indexPath.row].name
        cell.detailTextLabel?.text = games[indexPath.row].date
        return cell
    }
}
