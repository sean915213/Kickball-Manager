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
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
        // Fetch players
        team.getPlayers { (players, errors) in
            self.players.append(contentsOf: players)
            self.tableView.reloadData()
            guard !errors.isEmpty else { return }
            self.logger.logWarning("Errors fetching players: \(errors)")
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
        try! team.overwrite { (error) in
            guard let error = error else { return }
            fatalError("HANDLE ERR: \(error)")
        }
        print("&& ADDED TO TEAM: \(team.firDocument.documentID)")
    }
    
    // MARK: UITableView Delegate/DataSource Implementation
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return players.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = team.name
            return cell
        }
        let cell: PlayerCell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseId, for: indexPath)
        cell.player = players[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = PlayerViewController(user: user)
        controller.delegate = self
        show(controller, sender: self)
    }
}
