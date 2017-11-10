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

class PlayerViewController: UITableViewController, CNContactPickerDelegate {
    
    // MARK: - Initialization
    
    init(user: KMUser) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let user: KMUser
    
    private var players = [Player]()
    
    private lazy var logger = Logger(source: "PlayerViewController")
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        // Register cell classes
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
        loadPlayers()
        addToolbar()
    }
    
    private func loadPlayers() {
        user.getPlayers { (players, error) in
            
            print("&& GOT PLAYERS: \(players)")
            
            // Check
            guard let players = players else {
                // TODO: HANDLE THIS
                fatalError("Handle this: \(error)")
            }
            self.players.append(contentsOf: players)
            self.tableView.reloadData()
        }
    }
    
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
        guard !contacts.isEmpty else { return }
        // Create players
        let newPlayers = contacts.map { Player(contact: $0) }
        // Add to collection and reload
        players.append(contentsOf: newPlayers)
        tableView.reloadData()
        // Add in Firebase
        for player in newPlayers {
            do {
                let (newPlayer, _) = try user.firPlayersCollection.addDocument(object: player, completion: { (error) in
                    guard let error = error else { return }
                    fatalError("HANDLE THIS: \(error)")
                })
                self.logger.logInfo("Saving player w/ identifier: \(newPlayer.firID!).")
            } catch let error as NSError {
                fatalError("HANDLE THIS: \(error)")
            }
        }
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlayerCell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseId, for: indexPath)
        cell.player = players[indexPath.row]
        return cell
    }
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // DO SOMETHING
    }
}
