//
//  ErrorViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    private var text: String
    private var label = UILabel()

    init(labelText: String) {
        text = labelText

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        view.backgroundColor = .white

        label.text = text
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0

        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.leftAnchor.constraint(equalTo: view.leftAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
}
