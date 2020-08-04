//
//  TextFieldTableViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 02.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class TextFieldTableViewCell: UITableViewCell {
    var textField: AdministrateProjectTextField!

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
        textField = AdministrateProjectTextField(frame: .zero)
        tag = 1234
        isUserInteractionEnabled = true

        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: separatorInset.left),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: separatorInset.right),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
}
