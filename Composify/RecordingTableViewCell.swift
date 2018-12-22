//
//  RecordingTableViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 19.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {
    lazy var playButton = UIButton(type: .custom)
    lazy var titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureViews()
    }

    private func configureViews() {
        contentView.isUserInteractionEnabled = false
        selectionStyle = .none

        playButton.alpha = 1
        playButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            playButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: separatorInset.left),
            playButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            playButton.rightAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }
}
