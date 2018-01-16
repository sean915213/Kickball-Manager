//
//  PlayerViewController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility
import Firebase
import ContactsUI

protocol PlayerControllerDelegate: AnyObject {
    func playerController(_ controller: PlayerViewController, selected: Player)
}

class PlayerViewController: UITableViewController, CNContactPickerDelegate {
    
    // MARK: - Initialization
    
//    init(user: KMUser) {
//        self.user = user
//        super.init(style: .plain)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - Properties
    
//    let user: KMUser
    var players = [Player]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var delegate: PlayerControllerDelegate?
    
    private lazy var logger = Logger(source: "PlayerViewController")
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        // Register cell classes
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
//        loadPlayers()
        addToolbar()
    }
    
//    private func loadPlayers() {
//        user.getPlayers { (players, error) in
//            // Check
//            guard let players = players else {
//                // TODO: HANDLE THIS
//                fatalError("Handle this: \(error)")
//            }
//            self.players.append(contentsOf: players)
//            self.tableView.reloadData()
//        }
//    }
    
    private func addToolbar() {
        let toolbar = UIToolbar(translatesAutoresizingMask: true)
        
        // Add and constrain
//        view.addSubview(toolbar)
//        NSLayoutConstraint.constraintsPinningView(toolbar, axis: .horizontal).activate()
//        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.tableFooterView = toolbar
        
        // Add button
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pressedAdd))
        toolbar.setItems([add], animated: true)
        
        toolbar.sizeToFit()
    }
    
    // MARK: Actions
    
    @objc func pressedAdd() {
        let controller = CNContactPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    // CNContactPicker Delegate
    
//    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//        print("&& SELECTED: \(contact)")
//    }
    
//    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
//        print("&& SELECTED PROP: \(contactProperty)")
//    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        
        // TODO: NEED TO DELEGATE THIS NOW? BUT SHOULD ALWAYS ALLOW ADDING TO ALL USERS REGARDLESS OF WHERE? OR DELEGATE TO OTHER FUNCTIONS?
        fatalError("Needs rewritten")
        
//        guard !contacts.isEmpty else { return }
//        // Create players
//        let newPlayers = contacts.map { Player(contact: $0, owner: user) }
//        // Add in Firebase
//        for player in newPlayers {
//            do {
//                let _ = try user.firPlayersCollection.addObject(object: player, completion: { (error) in
//                    guard let error = error else { return }
//                    fatalError("HANDLE THIS: \(error)")
//                })
//                // To existing collection and reload
//                players.append(player)
//                tableView.reloadData()
//                self.logger.logInfo("Saving player at: \(player.firPath).")
//            } catch let error as NSError {
//                fatalError("HANDLE THIS: \(error)")
//            }
//        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelectContactProperties contactProperties: [CNContactProperty]) {
        print("&& SELECTED MULTI PROP: \(contactProperties)")
    }

    // MARK: UITableView DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // TODO: NEED TO DELEGATE THIS NOW THAT DIFFERENT SETS OF PLAYERS CAN BE LOADED
        fatalError("This needs rewritten")
        
        
//        let player = players[indexPath.row]
//        // Remove entry
//        players.remove(at: indexPath.row)
//        tableView.beginUpdates()
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//        tableView.endUpdates()
//        // Remove from db
//        player.firDocument.delete { (error) in
//            guard let error = error else { return }
//            self.logger.logWarning("Error deleting player [\(player.firPath)]: \(error)")
//            // Add to collection again
//            self.players.append(player)
//            self.tableView.beginUpdates()
//            self.tableView.insertRows(at: [IndexPath(row: self.players.count, section: 0)], with: .automatic)
//            self.tableView.endUpdates()
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlayerCell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseId, for: indexPath)
        cell.player = players[indexPath.row]
        return cell
    }
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.playerController(self, selected: players[indexPath.row])
    }
}
