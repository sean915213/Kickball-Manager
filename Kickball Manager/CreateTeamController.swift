//
//  CreateTeamController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/9/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

class CreateTeamController: UITableViewController, PlayerControllerDelegate {
    
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
    private lazy var logger = Logger(source: "CreateTeamController")
    private lazy var players = [Player]()
    private lazy var games = [Game]()
    
//    override var isEditing: Bool {
//        didSet {
//
//        }
//    }
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = team.name
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
        
        let button = UIBarButtonItem(title: "Add Game", style: .plain, target: self, action: #selector(tappedAddGame))
        let toolbar = UIToolbar(translatesAutoresizingMask: true)
        toolbar.sizeToFit()
        toolbar.setItems([button], animated: true)
        tableView.tableFooterView = toolbar
//        view.addSubview(toolbar)
//        toolbar.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
//        NSLayoutConstraint.constraintsPinningView(toolbar, axis: .horizontal).activate()
        
        // Fetch players
        team.getPlayers { (players, errors) in
            self.players.append(contentsOf: players)
            self.tableView.reloadData()
            guard !errors.isEmpty else { return }
            self.logger.logWarning("Errors fetching players: \(errors)")
        }
        // Fetch games
        team.firGamesCollection.getObjects { (games: [Game]?, snapshot, error) in
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
        let _ = try! team.firGamesCollection.addObject(object: game) { (error) in
            if let error = error {
                self.logger.logWarning("Failed to create new game. Error: \(error)")
            } else {
                self.logger.logInfo("Created new game: \(game.firPath)")
                let controller = GameController(game: game, user: self.user)
                self.show(controller, sender: self)
            }
        }
    }
    
    // MARK: PlayerControllerDelegate Implementation
    
    func playerController(_ controller: PlayerViewController, selected player: Player) {
        dismiss(animated: true, completion: nil)
        // Add player's id
        team.playerPaths.insert(player.firPath)
        // Add to collection and reload
        players.append(player)
        tableView.reloadData()
        // Update object
        try! team.addOrOverwrite { (error) in
            guard let error = error else { return }
            fatalError("HANDLE ERR: \(error)")
        }
        print("&& ADDED TO TEAM: \(team.firDocument.documentID)")
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
            let controller = GameController(game: games[indexPath.row], user: user)
            show(controller, sender: self)
            return
        }
        let controller = PlayerViewController(user: user)
        controller.delegate = self
        show(controller, sender: self)
    }
}
