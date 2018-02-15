//
//  InningController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 12/1/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

class InningController: UITableViewController, PlayerControllerDelegate {
    
    // MARK: - Initialization
    
    init(user: KMUser, game: Game, inning: Inning) {
        self.user = user
        self.game = game
        self.inning = inning
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let user: KMUser
    let game: Game
    let inning: Inning
    private lazy var players = [Position: Player]()
    
    private lazy var logger = Logger(source: "InningController")
    
    private lazy var playerController: PlayerViewController = {
        let controller = PlayerViewController()
        controller.delegate = self
        // Load players from game
        self.game.getPlayers(completion: { (players, errors) in
            // Assign players
            controller.players = players
            // Log errors
            guard !errors.isEmpty else { return }
            self.logger.logWarning("Errors fetching game players: \(errors)")
        })
        return controller
    }()
    
    private var allPositions: [Position] {
        // TODO: Obtain from game? Or some other source?
        return Position.allValues
    }
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Inning: " + String(inning.number)
        tableView.register(PositionCell.self, forCellReuseIdentifier: PositionCell.reuseId)
        // Fetch positions
        inning.getPositions { (positions, error) in
            if let positions = positions {
                self.loadPlayers(from: positions)
            } else {
                self.logger.logWarning("Failed to get positions w/ error: \(error)")
            }
        }
        tableView.reloadData()
        
        
        inning.firPositionsCollection.addSnapshotListener { (snapshot, error) in
            for change in snapshot!.documentChanges {
                print("&& CHG TYPE: \(change.type.rawValue), DOC: \(change.document.reference.path)")
            }
        }
    }
    
    private func loadPlayers(from playerPositions: [PlayerPosition]) {
        for playerPosition in playerPositions {
            playerPosition.getPlayer { (player, error) in
                if let player = player {
                    self.players[playerPosition.position] = player
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: self.allPositions.index(of: playerPosition.position)!, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                } else {
                    self.logger.logWarning("Failed to get player w/ error: \(error)")
                }
            }
        }
    }
    
    // MARK: PlayerController Delegate
    
    func playerController(_ controller: PlayerViewController, displayStyleFor player: Player) -> PlayerCell.Style {
        guard !players.values.contains(player) else { return .discouraged }
        return .default
    }
    
    func playerController(_ controller: PlayerViewController, selected player: Player) {
        // Make sure player not already selected
        guard !players.values.contains(player) else {
            let alert = UIAlertController(title: "Cannot Add", message: "That player is already assigned to a position.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            alert.display()
            return
        }
        // Dismiss
        dismiss(animated: true, completion: nil)
        // Get the position we were selecting
        let position = allPositions[tableView.indexPathForSelectedRow!.row]
        // Assign player and reload
        players[position] = player
        tableView.beginUpdates()
        tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: .automatic)
        tableView.endUpdates()
        // Create and save a database representation
        let playerPosition = PlayerPosition(position: position, player: player, inning: inning)
        try! playerPosition.addOrOverwrite { (error) in
            if let error = error { self.logger.logWarning("Failed to save PlayerPosition w/ error: \(error)") }
        }
    }
    
    func playerControllerCancelled(_ controller: PlayerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableView Delegate/DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPositions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let position = allPositions[indexPath.row]
        let cell: PositionCell = tableView.dequeueReusableCell(withIdentifier: PositionCell.reuseId, for: indexPath)
        cell.configure(for: position, player: players[position])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present(playerController, animated: true, completion: nil)
        playerController.reloadPlayers()
    }
}
