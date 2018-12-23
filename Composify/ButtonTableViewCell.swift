//
//  ButtonTableViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    private var button: UIButton!
    var buttonTitle: String? {
        didSet {
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        }
    }

    var action: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func buttonTap() {
        action?()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }
}

extension ButtonTableViewCell {
    func setupViews() {
        button = UIButton(frame: .zero)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.pinToEdgesOfView(contentView)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        applyAccessibility()
    }
}

extension ButtonTableViewCell {
    func applyAccessibility() {
        // TODO: Localize
        button.isAccessibilityElement = true
        button.accessibilityTraits = .button
        button.accessibilityValue = button.titleLabel?.text
        button.accessibilityLabel = "Slett"
        button.accessibilityHint = "Sletter prosjekt"
    }
}
