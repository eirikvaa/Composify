//
//  RecordingTableViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 19.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class RecordingTableViewCell: UITableViewCell {
    private lazy var playButton = UIButton(type: .custom)
    private lazy var titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureViews()
    }

    func setTitle(_ title: String?) {
        titleLabel.text = title
    }

    func setImage(_ image: UIImage?) {
        playButton.setImage(image, for: .normal)
        applyAccessibility()
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
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
}

extension RecordingTableViewCell {
    func applyAccessibility() {
        let image = playButton.imageView?.image
        let isPlayImage = image?.isEqualTo(image: R.Images.play) ?? false

        playButton.isAccessibilityElement = true
        playButton.accessibilityTraits = [.button, .playsSound]
        playButton.accessibilityLabel = R.Loc.recordingCellPlayButtonAccLabel
        playButton.accessibilityValue = isPlayImage ?
            R.Loc.recordingCellPlayButtonCanPlayAccValue :
            R.Loc.recordingCellPlayButtonCanPauseAccValue
        playButton.accessibilityHint = R.Loc.recordingCellPlayButtonAccHint

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits = .staticText
        titleLabel.accessibilityValue = titleLabel.text
        titleLabel.accessibilityLabel = "Opptak"
    }
}

extension UIImage {
    func isEqualTo(image: UIImage?) -> Bool {
        guard let selfData = self.pngData() else { return false }
        guard let otherData = image?.pngData() else { return false }

        return selfData == otherData
    }
}
