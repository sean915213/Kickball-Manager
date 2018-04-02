//
//  TeamController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/9/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility
import Firebase

class TeamController: UITableViewController, PlayerTableViewControllerDelegate {
    
    // MARK: - Initialization
    
    init(user: KMUser, team: Team) {
        self.user = user
        self.team = team
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let user: KMUser
    let team: Team
    private lazy var logger = Logger(source: "TeamController")
    
    private var players = [Player]() {
        didSet {
            players.sort(by: \.lastName)
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    private lazy var games = [Game]()
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = team.name
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
        // Create toolbar
        let gameButton = UIBarButtonItem(title: "Add Game", style: .plain, target: self, action: #selector(tappedAddGame))
        let playerButton = UIBarButtonItem(title: "Add Player", style: .plain, target: self, action: #selector(tappedAddPlayer))
        let toolbar = UIToolbar(translatesAutoresizingMask: true)
        toolbar.sizeToFit()
        toolbar.setItems([gameButton, playerButton], animated: true)
        tableView.tableFooterView = toolbar
        // Fetch players
        team.getPlayers { (players, errors) in
            self.players.append(contentsOf: players)
            self.tableView.reloadData()
            guard !errors.isEmpty else { return }
            self.logger.logWarning("Errors fetching players: \(errors)")
        }
        // Fetch games
        team.gamesCollection.getObjects { (games: [Game]?, snapshot, error) in
            if let games = games {
                self.games.append(contentsOf: games)
                self.tableView.reloadData()
            } else {
                self.logger.logWarning("Failed to fetch games. Error: \(String(describing: error))")
            }
        }
    }
    
    // MARK: Actions
    
    @objc private func tappedAddGame() {
        let number = games.count + 1
        // Create game
        let game = Game(number: number, team: team)
        game.playerPaths = team.playerPaths
        // Add
        let _ = try! Firestore.firestore().addObject(game) { (error) in
            if let error = error {
                self.logger.logWarning("Failed to create new game. Error: \(error)")
            } else {
                self.logger.logInfo("Created new game: \(game.firPath)")
                let controller = GameController(game: game, team: self.team, user: self.user)
                self.show(controller, sender: self)
            }
        }
    }
    
    @objc private func tappedAddPlayer() {
        let controller = PlayerTableViewController(user: user)
        controller.delegate = self
        user.getPlayers { (players, error) in
            controller.players = players ?? []
            if let error = error {
                fatalError("HANDLE ERR: \(error)")
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: PlayerControllerDelegate Implementation
    
    func playerController(_ controller: PlayerTableViewController, displayStyleFor player: Player) -> PlayerCell.Style {
        return players.contains(player) ? .discouraged : .default
    }
    
    func playerController(_ controller: PlayerTableViewController, shouldSaveNew player: Player) -> Bool {
        // Player controller has access to user's list in this scenario so any eligible contact can be added
        return true
    }
    
    func playerController(_ controller: PlayerTableViewController, selected player: Player) {
        guard !players.contains(player) else {
            let alert = UIAlertController(title: "Already on Team", message: "Please choose a different player.", preferredStyle: .alert)
            alert.addAction(.cancel())
            alert.display()
            return
        }
        // Dismiss
        dismiss(animated: true, completion: nil)
        // Add player's id
        team.playerPaths.insert(player.firPath)
        // Add to collection
        players.append(player)
        // Update object
        try! team.addOrOverwrite { (error) in
            guard let error = error else { return }
            fatalError("HANDLE ERR: \(error)")
        }
    }
    
    func playerControllerCancelled(_ controller: PlayerTableViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableView Delegate/DataSource Implementation
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return players.count
        }
        return games.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Players"
        } else if section == 2 {
            return "Games"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = team.name
            return cell
        }
        if indexPath.section == 1 {
            let cell: PlayerCell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseId, for: indexPath)
            cell.player = players[indexPath.row]
            return cell
        }
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(games[indexPath.row].number)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let controller = GameController(game: games[indexPath.row], team: team, user: user)
            show(controller, sender: self)
            return
        }

        // TODO: Remove
        let player = players[indexPath.row]
        if player.talents == nil {
            print("&& SEEDING TALENTS ON: \(player)")
            player.talents = [Talent: Int]()
            Talent.allValues.forEach { player.talents![$0] = 0 }
        }
        
        let controller = PlayerViewController()
        controller.player = players[indexPath.row]
        show(controller, sender: self)
        
//        let controller = PlayerTableViewController(user: user)
//        controller.delegate = self
//        // Assign current list of players
//        controller.players = players
//        present(controller, animated: true, completion: nil)
    }
}
