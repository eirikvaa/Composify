//
//  TextFieldTableViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 02.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class TextFieldTableViewCell: UITableViewCell {
    var textField: UITextField!
    var placeholder: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension TextFieldTableViewCell {
    func setupViews() {
        textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true

        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: separatorInset.left),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: separatorInset.right),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])

        applyAccessibility()
    }
}

extension TextFieldTableViewCell {
    func applyAccessibility() {
        textField.isAccessibilityElement = true
        textField.accessibilityLabel = R.Loc.textFieldTableViewCellAccLabel
    }
}
