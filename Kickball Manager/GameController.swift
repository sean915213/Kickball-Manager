//
//  GameController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility
import Firebase

class GameController: UITableViewController, PlayerControllerDelegate {
    
    private enum Sections: Int { case players, kickers, innings }
    
    private enum PickingMode { case player, kicker }
    
    // MARK: - Initialization
    
    init(game: Game, user: KMUser) {
        self.game = game
        self.user = user
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let game: Game
    let user: KMUser
    private lazy var logger = Logger(source: "GameController")
    private lazy var players = [Player]()
    private lazy var kickers = [(Kicker, Player)]()
    private lazy var innings = [Inning]()
    
    private lazy var playerController: PlayerViewController = {
        let controller = PlayerViewController(user: self.user)
        controller.delegate = self
        return controller
    }()
    private var pickingMode: PickingMode?
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseId)
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Fetch players
        game.getPlayers { (players, errors) in
            self.players.append(contentsOf: players)
            self.tableView.reloadData()
            guard !errors.isEmpty else { return }
            self.logger.logWarning("Errors fetching players: \(errors)")
        }
        // Fetch kickers
        fetchKickers()
        // Fetch innings
        game.firInningsCollection.getObjects { (innings: [Inning]?, snapshot, error) in
            if let innings = innings {
                self.innings.append(contentsOf: innings)
                self.tableView.reloadData()
            } else {
                self.logger.logWarning("Failed to fetch innings.  Error: \(String(describing: error))")
            }
        }
    }
    
    private func fetchKickers() {
        game.firKickersCollection.getObjects { (kickers: [Kicker]?, snapshot, error) in
            guard let kickers = kickers else {
                self.logger.logWarning("Failed to fetch kickers.  Error: \(String(describing: error))")
                return
            }
            for kicker in kickers {
                // Fetch person entry
                kicker.getPlayer { (player, error) in
                    guard let player = player else {
                        // TODO: DELETE KICKER ENTRY SOMEHOW. HERE?
                        self.logger.logWarning("Failed to fetch kicker's player entry [\(kicker.playerPath)] with error: \(String(describing: error))")
                        return
                    }
                    // Add to kickers
                    self.kickers.append((kicker, player))
                    // Sort
                    self.kickers.sort { $0.0.number < $1.0.number }
                    // Reload section
                    self.tableView.beginUpdates()
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        for i in 0..<tableView.numberOfSections {
            (tableView.headerView(forSection: i) as? SectionHeaderView)?.button.isHidden = !isEditing
        }
    }
    
    // MARK: Actions
    
    @objc private func tappedHeaderAdd(on sender: UIButton) {
        switch Sections(rawValue: sender.tag)! {
        case .players:
            print("PLAYER")
            pickingMode = .player
            present(playerController, animated: true, completion: nil)
        case .kickers:
            print("KICKER")
            pickingMode = .kicker
            present(playerController, animated: true, completion: nil)
        case .innings:
            print("INNING")
        }
    }
    
    // MARK: PlayerController Delegate Implementation
    
    func playerController(_ controller: PlayerViewController, selected player: Player) {
        switch pickingMode! {
        case .player:
            // Add player and reload
            players.append(player)
            tableView.reloadData()
            // Add to game and overwrite
            game.playerPaths.insert(player.firPath)
            try! game.addOrOverwrite(completion: { (error) in
                if let error = error {
                    self.logger.logWarning("Failed overwriting game. Error: \(error)")
                } else {
                    self.logger.logInfo("Added player: \(player.firPath).")
                }
            })
        case .kicker:
            // Create new kicker
            let kicker = Kicker(number: kickers.count + 1, player: player, game: game)
            // Add
            // TODO: HANDLE ERRORS
            let _ = try! game.firKickersCollection.addObject(object: kicker, completion: { (error) in
                if let error = error {
                    self.logger.logWarning("Failed to add kicker. Error: \(error)")
                } else {
                    self.logger.logInfo("Added kicker: \(kicker.firPath).")
                    // Insert and reload
                    self.kickers.append((kicker, player))
                    self.tableView.reloadData()
                }
            })
        }
        // Dismiss
        dismiss(animated: true, completion: nil)
    }

    // MARK: UITableView Delegate/DataSource Implementation

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section)! {
        case .players: return players.count
        case .kickers: return kickers.count
        case .innings: return innings.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: SectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.reuseId)!
        header.button.addTarget(self, action: #selector(tappedHeaderAdd(on:)), for: .touchUpInside)
        header.button.tag = section
        header.button.isHidden = !isEditing
        switch Sections(rawValue: section)! {
        case .players: header.label.text = "Players"
        case .kickers: header.label.text = "Kickers"
        case .innings: header.label.text = "Innings"
        }
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Sections.players.rawValue {
            let cell: PlayerCell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseId, for: indexPath)
            cell.player = players[indexPath.row]
            return cell
        }
        if indexPath.section == Sections.kickers.rawValue {
            let (kicker, player) = kickers[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = String(kicker.number) + " " + player.displayName
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Inning: " + String(innings[indexPath.row].number)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let section = Sections(rawValue: indexPath.section)!
        return section == .kickers
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Change kickers in collection
        let kicker = kickers.remove(at: sourceIndexPath.row)
        kickers.insert(kicker, at: destinationIndexPath.row)
        // Loop through any changed entries
        let minIndex = sourceIndexPath.row < destinationIndexPath.row ? sourceIndexPath.row : destinationIndexPath.row
        for i in minIndex..<kickers.count {
            let kicker = kickers[i].0
            // Assign new number
            kicker.number = i + 1
            // Begin write request
            try! kicker.addOrOverwrite(completion: { (error) in
                if let error = error {
                    self.logger.logWarning("Failed to update kicker [\(kicker.firPath)]. Error: \(error)")
                } else {
                    self.logger.logInfo("Updated kicker [\(kicker.firPath)].")
                }
            })
        }
        // Reload table
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        isEditing = !isEditing
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
