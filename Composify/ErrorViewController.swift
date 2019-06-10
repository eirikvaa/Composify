//
//  ErrorViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class ErrorViewController: UIViewController {
    private var text: String
    private var buttonTitle: String
    private var buttonAction: () -> Void
    private var label = UILabel()
    private lazy var button = RoundedButton(title: self.buttonTitle, action: self.buttonAction)

    init(message: String, actionMessage: String, action: @escaping () -> Void) {
        text = message
        buttonTitle = actionMessage
        buttonAction = action

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        applyAccessibility()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func doAction() {
        button.performAction()
    }

    private func setup() {
        view.backgroundColor = .white

        label.text = text
        label.sizeToFit()
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0

        view.addSubview(label)
        view.addSubview(button)

        // Pin label to top, leading, and trailing anchor, in addition to button below
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -32),
        ])

        // Pin button to label above, in addition to leading, trailing and bottom anchor.
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: label.centerXAnchor),
        ])
    }
}

extension ErrorViewController {
    func applyAccessibility() {
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        label.accessibilityValue = text
        label.accessibilityLabel = R.Loc.errorViewControllerLabelAccLabel
    }
}
