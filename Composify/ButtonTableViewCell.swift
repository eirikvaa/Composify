//
//  ButtonTableViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class ButtonTableViewCell: UITableViewCell {
    private var button: UIButton!
    var buttonTitle: String? {
        didSet {
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        }
    }

    var buttonTitleColor: UIColor? {
        didSet {
            button.setTitleColor(buttonTitleColor, for: .normal)
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

        button.pinToEdges(of: contentView)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        applyAccessibility()
    }
}

extension ButtonTableViewCell {
    func applyAccessibility() {
        button.isAccessibilityElement = true
        button.accessibilityTraits = .button
        button.accessibilityValue = button.titleLabel?.text
        button.accessibilityLabel = R.Loc.buttonTableViewCellAccLabel
        button.accessibilityHint = R.Loc.buttonTableViewCellAccHint
    }
}
