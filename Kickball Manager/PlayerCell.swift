//
//  PlayerCell.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit

class PlayerCell: UICollectionViewCell {
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    var player: Player? {
        didSet { }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    // MARK: - Methods
    
    private func setupCell() {
        contentView.addSubview(nameLabel)
        
        // TODO: BRING IN TEH UTILITIES VIA TEH PODS
        
    }
    
    private func configure(with player: Player) {
        nameLabel.text = player.firstName + " " + player.lastName
    }
}
