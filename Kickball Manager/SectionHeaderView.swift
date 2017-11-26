//
//  SectionHeaderView.swift
//  Kickball Manager
//
//  Created by Sean G Young on 11/25/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

class SectionHeaderView: UITableViewHeaderFooterView {
    
    static let reuseId = "com.sdot.KickballManager.headerView"

    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let label: UILabel = {
        let label = UILabel(translatesAutoresizingMask: false)
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.defaultLow, for: .vertical)
        return button
    }()
    
    // MARK: - Methods
    
    private func setupView() {
        contentView.addSubviews([label, button])
        NSLayoutConstraint.constraintsPinningViews([label, button], axis: .vertical, toMargins: true).withPriority(UILayoutPriority(999)).activate()
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[button]-|", options: .alignAllCenterY, metrics: nil, views: ["label": label, "button": button]).withPriority(UILayoutPriority(999)).activate()
//        NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[button]-|", options: .alignAllCenterY, metrics: nil, views: ["label": label, "button": button]).withPriority(.required).activate()
    }
}
