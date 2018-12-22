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
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }
}
