//
//  RecordAudioButton.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

class RecordAudioButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    func configureView() {
        layer.cornerRadius = 5
        backgroundColor = R.Colors.fireBushYellow
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
