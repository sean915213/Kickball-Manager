//
//  CreateTeamController.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/9/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit

class CreateTeamController: UIViewController, PlayerControllerDelegate {
    
    // MARK: - Initialization
    
    init(user: KMUser, team: Team) {
        self.user = user
        self.team = team
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let user: KMUser
    let team: Team
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        let nameLabel = UILabel(translatesAutoresizingMask: false)
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.textAlignment = .center
        nameLabel.text = team.name
        
        let addButton = UIButton(type: .roundedRect)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Add Player", for: [])
        addButton.addTarget(self, action: #selector(pressedAdd(button:)), for: .touchUpInside)
        
        view.addSubviews([nameLabel, addButton])
        
        NSLayoutConstraint.constraintsPinningView(nameLabel, axis: .horizontal, toMargins: true).activate()
        nameLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        
        addButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    }

    // MARK: Actions
    
    @objc func pressedAdd (button: UIButton) {
        let controller = PlayerViewController(user: user)
        controller.delegate = self
        show(controller, sender: self)
    }
    
    // MARK: PlayerControllerDelegate Implementation
    
    func playerController(_ controller: PlayerViewController, selected player: Player) {
        dismiss(animated: true, completion: nil)
        // Add player's id
        team.playerIds.insert(player.firPath!)
        // Update object
        try! team.overwrite { (error) in
            guard let error = error else { return }
            fatalError("HANDLE ERR: \(error)")
        }
        print("&& ADDED TO TEAM: \(team.firDocument!.documentID)")
    }
}
