//
//  ButtonCell.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/23/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    static let reuseId = "com.sdot.kickballManager.buttonCell"

    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let button: UIButton = {
        let button = UIButton(translatesAutoresizingMask: false)
        button.setTitleColor(.blue, for: [])
        return button
    }()
    
    // MARK: - Methods
    
    private func setupCell() {
        contentView.addSubview(button)
        NSLayoutConstraint.constraintsPinningView(button, toMargins: true).activate()
    }
}
