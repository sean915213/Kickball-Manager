//
//  TalentCell.swift
//  Kickball Manager
//
//  Created by Sean G Young on 2/27/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit

class TalentCell: UITableViewCell {
    
    static let reuseId = "com.sdot.talentCell"
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var talent: Talent? {
        didSet {
            if let talent = talent { configure(forTalent: talent) }
        }
    }
    
    private let label: UILabel = {
        let label = UILabel(translatesAutoresizingMask: false)
        return label
    }()
    
    private(set) lazy var slider: UISlider = {
        let slider = UISlider(translatesAutoresizingMask: false)
        slider.addTarget(self, action: #selector(valueChanged(onSlider:)), for: .valueChanged)
        slider.minimumValue = Float(Talent.min)
        slider.maximumValue = Float(Talent.max)
        return slider
    }()
    
    // MARK: - Methods
    
    private func setupCell() {
        contentView.addSubviews([label, slider])
        NSLayoutConstraint.constraintsPinningViews([label, slider], axis: .horizontal, toMargins: true).activate()
        NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-[slider]-|", options: [], metrics: nil, views: ["label": label, "slider": slider]).activate()
    }
    
    private func configure(forTalent talent: Talent) {
        label.text = talent.rawValue
    }
    
    // MARK: Actions
    
    @objc private func valueChanged(onSlider slider: UISlider) {
        slider.value = roundf(slider.value)
    }
}
