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
    private lazy var positions = [Position: PlayerPosition]()
    
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
                self.loadPositions(from: positions)
            } else {
                self.logger.logWarning("Failed to get positions w/ error: \(error)")
            }
        }
        
        tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func loadPositions(from playerPositions: [PlayerPosition]) {
        // Assign positions
        playerPositions.forEach { self.positions[$0.position] = $0 }
        // Reload data
        tableView.reloadData()
    }
    
    // MARK: PlayerController Delegate
    
    func playerController(_ controller: PlayerViewController, selected player: Player) {
        // Dismiss
        dismiss(animated: true, completion: nil)
        // Update
        let position = allPositions[tableView.indexPathForSelectedRow!.row]
        let playerPosition: PlayerPosition
        // Replace or create player position
        if let existingPosition = positions[position] {
            existingPosition.playerPath = player.firPath
            playerPosition = existingPosition
        } else {
            playerPosition = PlayerPosition(position: position, player: player, inning: inning)
        }
        // Save position
        try! inning.firPositionsCollection.addObject(object: playerPosition) { (error) in
            if let error = error { self.logger.logWarning("Error adding player to position: \(error)") }
        }
        // Assign and reload
        positions[position] = playerPosition
        tableView.beginUpdates()
        tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: .automatic)
        tableView.endUpdates()
    }

    // MARK: UITableView Delegate/DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPositions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        fatalError("START HERE: Need to also load Player for each PlayerPosition object.")
        
        let position = allPositions[indexPath.row]
        let cell: PositionCell = tableView.dequeueReusableCell(withIdentifier: PositionCell.reuseId, for: indexPath)
        cell.configure(for: position, player: nil)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present(playerController, animated: true, completion: nil)
    }
}
