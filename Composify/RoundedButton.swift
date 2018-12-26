//
//  RoundedButton.swift
//  Composify
//
//  Created by Eirik Vale Aase on 26/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    private let title: String
    private let action: () -> Void
    
    required init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func performAction() {
        action()
    }
    
    private func setup() {
        setTitle(title, for: .normal)
        addTarget(self, action: #selector(performAction), for: .touchUpInside)
        
        backgroundColor = R.Colors.cardinalRed
        layer.cornerRadius = 12
        contentEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }
}
