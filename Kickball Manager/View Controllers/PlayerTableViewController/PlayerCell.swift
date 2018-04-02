//
//  PlayerCell.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

class PlayerCell: UITableViewCell {
    
    enum Style { case `default`, discouraged }
    
    static let reuseId = "com.sdot.kickballManager.playerCell"
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var player: Player? {
        didSet {
            if let p = player { configure(with: p) }
        }
    }
    
    var style: Style = .default {
        didSet {
            switch style {
            case .default: nameLabel.textColor = .black
            case .discouraged: nameLabel.textColor = .red
            }
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel(translatesAutoresizingMask: false)
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    // MARK: - Methods
    
    private func setupCell() {
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.constraintsPinningView(nameLabel, toMargins: true).activate()
    }
    
    private func configure(with player: Player) {
        nameLabel.text = player.firstName + " " + player.lastName
    }
}
