//
//  PositionCell.swift
//  Kickball Manager
//
//  Created by Sean G Young on 1/15/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

class PositionCell: UITableViewCell {
    
    static let reuseId = "com.sdot.kickballManager.positionCell"

    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let nameLabel: UILabel = {
        let label = UILabel(translatesAutoresizingMask: false)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        return label
    }()
    
    private let playerLabel: UILabel = {
        let label = UILabel(translatesAutoresizingMask: false)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        return label
    }()
    
    // MARK: - Methods
    
    private func setupCell() {
        contentView.addSubviews([nameLabel, playerLabel])
        let dict = ["name": nameLabel, "player": playerLabel]
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-[player]-|", options: .alignAllCenterY, metrics: nil, views: dict).activate()
        NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name]-|", options: [], metrics: nil, views: dict).activate()
    }
    
    func configure(for position: Position, player: Player?) {
        nameLabel.text = position.rawValue
        playerLabel.text = player?.firstName
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        playerLabel.text = nil
    }
}
