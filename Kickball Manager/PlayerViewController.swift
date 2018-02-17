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
    func playerController(_ controller: PlayerViewController, displayStyleFor player: Player) -> PlayerCell.Style
    func playerController(_ controller: PlayerViewController, selected player: Player)
    func playerController(_ controller: PlayerViewController, shouldSaveNew player: Player) -> Bool
    func playerControllerCancelled(_ controller: PlayerViewController)
}

class PlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate {
    
    // MARK: - Initialization
    
    init(user: KMUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let user: KMUser
    
    var players = [Player]() {
        didSet {
            // Sort players by last name
            players.sort(by: { $0.lastName < $1.lastName })
//            players = players.sorted(by: { $0.lastName < $1.lastName })
            // Reload section
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    weak var delegate: PlayerControllerDelegate?
    
    private lazy var logger = Logger(source: "PlayerViewController")
    
    private lazy var tableView: UITableView = {
        let table = UITableView(translatesAutoresizingMask: false)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .white
        table.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
        return table
    }()
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        NSLayoutConstraint.constraintsPinningView(tableView).activate()
        addToolbar()
    }
    
    func reloadPlayers() {
        // Reload section
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableView.endUpdates()
    }
    
    private func addToolbar() {
        let toolbar = UIToolbar(translatesAutoresizingMask: false)
        
        // Add and constrain
        view.addSubview(toolbar)
        NSLayoutConstraint.constraintsPinningView(toolbar, axis: .horizontal).activate()
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
//        tableView.tableFooterView = toolbar
        
        // Add buttons
        // - Add
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pressedAdd))
        // - Flex
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // - Cancel
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(pressedCancel))
        
        toolbar.setItems([add, flex, cancel], animated: true)
    }
    
    // MARK: Actions
    
    @objc private func pressedAdd() {
        // Must fetch all contacts and find a single attribute to filter on (i.e. identifier) in order to use an NSPredicate to disable contacts in CNContactPickerViewController.
        // Should be done off main queue
        DispatchQueue.global(qos: .userInitiated).async {
            var invalidIds = [String]()
            let request = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor])
            // Enumerate all contacts and add invalid ids
            try! CNContactStore().enumerateContacts(with: request) { (contact, _) in
                if self.players.contains(Player(contact: contact, owner: self.user)) { invalidIds.append(contact.identifier) }
            }
            // Jump back into main queue to present controller
            DispatchQueue.main.async {
                let controller = CNContactPickerViewController()
                controller.delegate = self
                // Assign predicate
                controller.predicateForEnablingContact = NSPredicate(format: "!(identifier IN %@)", invalidIds)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func pressedCancel() {
        delegate?.playerControllerCancelled(self)
    }
    
    // CNContactPicker Delegate
    
//    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//        print("&& SELECTED: \(contact)")
//    }
    
//    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
//        print("&& SELECTED PROP: \(contactProperty)")
//    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        var newPlayers = [Player]()
        // Ask delegate whether to add contacts to user's players
        for contact in contacts {
            let player = Player(contact: contact, owner: user)
            if delegate?.playerController(self, shouldSaveNew: player) == true { newPlayers.append(player) }
        }
        // Add new players
        for player in newPlayers {
            try! player.addOrOverwrite(completion: { (error) in
                // Log error if it exists or add player
                if let error = error {
                    self.logger.logWarning("Failed to add new contact as player w/ error: \(error)")
                } else {
                    self.logger.logInfo("Added new player [\(player.firPath)].")
                    self.players.append(player)
                }
            })
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelectContactProperties contactProperties: [CNContactProperty]) {
        print("&& SELECTED MULTI PROP: \(contactProperties)")
    }

    // MARK: UITableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let player = players[indexPath.row]
        let cell: PlayerCell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseId, for: indexPath)
        cell.player = player
        cell.style = delegate?.playerController(self, displayStyleFor: player) ?? .default
        return cell
    }
    
    // MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.playerController(self, selected: players[indexPath.row])
    }
}
