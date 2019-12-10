//
//  AdministrateProjectTextField.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

class AdministrateProjectTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    func configureView() {
        autocapitalizationType = .words
        clearButtonMode = .whileEditing
        returnKeyType = .done

        font = .preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        isUserInteractionEnabled = true

        isAccessibilityElement = true
        accessibilityLabel = R.Loc.textFieldTableViewCellAccLabel
    }
}
