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

// TODO: Configure this or make it a setting or something
private let numberOfInnings = 9

// TODO: Different organization
let kickerRuleSets: [AnyRuleSet<Player>] = {
    return [AnyRuleSet(GenderRuleSet())]
}()

class GameController: UITableViewController, PlayerTableViewControllerDelegate {
    
    private enum Sections: Int { case players, kickers, innings }
    
    private enum PickingMode { case player, kicker }
    
    // MARK: - Initialization
    
    init(game: Game, team: Team, user: KMUser) {
        self.game = game
        self.team = team
        self.user = user
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let game: Game
    let team: Team
    let user: KMUser
    
    private lazy var logger = Logger(source: "GameController")
    private lazy var players = [Player]()
    private lazy var kickers = [(Kicker, Player)]()
    private lazy var innings = [Inning]()
    
    private lazy var playerController: PlayerTableViewController = {
        let controller = PlayerTableViewController(user: user)
        controller.delegate = self
        return controller
    }()
    private var pickingMode: PickingMode?
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Game " + String(game.number)
        navigationItem.rightBarButtonItem = editButtonItem
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseId)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseId)
        // Fetch players
        game.getPlayers { (players, errors) in
            self.players.append(contentsOf: players)
            self.reloadSection(.players)
            guard !errors.isEmpty else { return }
            self.logger.logWarning("Errors fetching players: \(errors)")
        }
        // Fetch kickers
        fetchKickers()
        // Fetch innings
        game.inningsCollection.getObjects { (innings: [Inning]?, snapshot, error) in
            if let innings = innings {
                self.loadInnings(from: innings)
            } else {
                self.logger.logWarning("Failed to fetch innings.  Error: \(String(describing: error))")
            }
        }
    }
    
    private func fetchKickers() {
        game.kickersCollection.getObjects { (kickers: [Kicker]?, snapshot, error) in
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
                    self.reloadSection(.kickers)
                }
            }
        }
    }
    
    private func loadInnings(from existingInnings: [Inning]) {
        // Create dict of existing innings
        var inningDict = [Int: Inning]()
        existingInnings.forEach { inningDict[$0.number] = $0 }
        // Add all innings
        for i in 0..<numberOfInnings {
            // Add existing or create new
            let inning = inningDict[i] ?? Inning(number: i + 1, game: game)
            innings.append(inning)
        }
        reloadSection(.innings)
    }
    
    private func addPlayer(_ player: Player) {
        // Add player and reload
        players.append(player)
        reloadSection(.players)
        // Add to game
        try! game.addPlayers([player]) { (error) in
            guard let error = error else { return }
            self.logger.logWarning("Error adding player to game: \(error)")
        }
        // Add to kickers
        addKicker(for: player)
    }
    
    private func addKicker(for player: Player) {
        // Create and add new kicker
        let kicker = Kicker(number: kickers.count + 1, player: player, game: game)
        try! kicker.addOrOverwrite { (error) in
            if let error = error {
                self.logger.logWarning("Failed to add kicker. Error: \(error)")
            } else {
                self.logger.logInfo("Added kicker: \(kicker.firPath).")
                // Add and reload
                self.kickers.append((kicker, player))
                // Sort kickers
                self.sortKickers()
            }
        }
    }
    
    private func sortKickers() {
        let originalKickers = kickers.map { $0.0 }
        let originalPlayers = kickers.map { $0.1 }
        var sortedPlayers = originalPlayers
        for rules in kickerRuleSets {
            do {
                sortedPlayers = try rules.tryApply(on: sortedPlayers)
            } catch let error as RuleSetError {
                let alert = UIAlertController(title: "Kickers Incorrect", message: error.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction.cancel())
                present(alert, animated: true, completion: nil)
            } catch let error {
                self.logger.logError("Caught unknown error type from ruleSet: \(error)")
            }
        }
        // If same collection then do nothing
        guard sortedPlayers != originalPlayers else { return }
        // Reset kickers
        kickers.removeAll()
        for i in 0..<sortedPlayers.endIndex {
            let player = sortedPlayers[i]
            // Find original kicker entry
            let kicker = originalKickers.first(where: { $0.playerPath == player.firPath })!
            // Change kicker number
            kicker.number = i
            // Update in database
            try! kicker.update(property: \.number, named: "number")
            // Add to kickers
            kickers.append((kicker, player))
        }
        // Reload section
        reloadSection(.kickers)
    }
    
    private func reloadSection(_ section: Sections) {
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: section.rawValue), with: .automatic)
        tableView.endUpdates()
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
            pickingMode = .player
            // Begin loading team's players
            playerController.loadPlayers(from: team)
            // Present awhile
            present(playerController, animated: true, completion: nil)
        case .kickers:
            pickingMode = .kicker
            present(playerController, animated: true, completion: nil)
            // Assign players
            playerController.players = players
        case .innings:
            print("TAPPED ADD INNING")
        }
    }
    
    // MARK: PlayerController Delegate Implementation
    
    func playerController(_ controller: PlayerTableViewController, displayStyleFor: Player) -> PlayerCell.Style {
        return .default
    }
    
    func playerController(_ controller: PlayerTableViewController, shouldSaveNew player: Player) -> Bool {
        fatalError("HANDLE ME: SHOULD ALLOW?")
        return false
    }
    
    func playerController(_ controller: PlayerTableViewController, selected player: Player) {
        // Dismiss
        dismiss(animated: true, completion: nil)
        // Save
        switch pickingMode! {
        case .player:
            addPlayer(player)
        case .kicker:
            addKicker(for: player)
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
        // Update only entries with a changed index
        let (minIndex, maxIndex) = sourceIndexPath.row < destinationIndexPath.row ? (sourceIndexPath.row, destinationIndexPath.row) : (destinationIndexPath.row, sourceIndexPath.row)
        for i in minIndex...maxIndex {
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
        guard indexPath.section == Sections.innings.rawValue else { return }
        let controller = InningController(user: user, game: game, inning: innings[indexPath.row])
        show(controller, sender: self)
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
