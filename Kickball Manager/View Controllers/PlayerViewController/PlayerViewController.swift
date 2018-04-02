//
//  PlayerViewController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 2/27/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

class PlayerViewController: UITableViewController {
    
    private enum Section: Int {
        case gender, talents
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var player: Player? {
        didSet {
            title = player?.displayName
            // Assign an array of talents in order to maintain an index
            if let keys = player?.talents?.keys {
                talents = Array(keys)
            } else {
                talents = nil
            }
            // Reload
            tableView.reloadData()
        }
    }
    
    private var talents: [Talent]?
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TalentCell.self, forCellReuseIdentifier: TalentCell.reuseId)
    }
    
    @objc private func valueEnded(onSlider slider: UISlider) {
        // Change on player
        player!.talents![talents![slider.tag]] = Int(roundf(slider.value))
        try! player!.update(property: \.talents, named: "talents") { (error) in
            guard let error = error else { return }
            self.logger.logWarning("Failed to update talent w/ error: \(error)")
        }
    }
    
    private func updateGender(to gender: Player.Gender?) {
        guard gender != player!.gender else { return }
        // Assign and reload
        player!.gender = gender
        reloadSection(.gender)
        // Update
        try! player!.update(property: \.gender, named: "gender", completion: { (error) in
            if let error = error {
                self.logger.logWarning("Failed to update gender. Error: \(error)")
            } else {
                self.logger.logInfo("Updated gender to: \(gender)")
            }
        })
    }
    
    private func reloadSection(_ section: Section) {
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: section.rawValue), with: .automatic)
        tableView.endUpdates()
    }
    
    // MARK: UITableView Datasource/Delegate Implementation
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .gender: return 1
        case .talents: return talents?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .gender:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = player?.gender?.rawValue ?? "<undefined>"
            return cell
        case .talents:
            let talent = talents![indexPath.row]
            let cell: TalentCell = tableView.dequeueReusableCell(withIdentifier: TalentCell.reuseId, for: indexPath)
            cell.talent = talent
            cell.slider.value = Float(player!.talents![talent]!)
            cell.slider.tag = indexPath.row
            cell.slider.addTarget(self, action: #selector(valueEnded(onSlider:)), for: .touchUpInside)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == Section.gender.rawValue else { return }
        let alert = UIAlertController(title: "Gender", message: "Choose gender.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Male", style: .default, handler: { (_) in
            self.updateGender(to: .male)
        }))
        alert.addAction(UIAlertAction(title: "Female", style: .default, handler: { (_) in
            self.updateGender(to: .female)
        }))
        alert.addAction(UIAlertAction(title: "None", style: .default, handler: { (_) in
            self.updateGender(to: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
