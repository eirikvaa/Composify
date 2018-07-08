//
//  ErrorViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    
    private var labelText: String?
    private var errorLabel = UILabel()
    
    init(labelText: String?) {
        self.labelText = labelText
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        view.backgroundColor = .white
        
        errorLabel.text = labelText
        errorLabel.textAlignment = .center
        errorLabel.textColor = .darkGray
        errorLabel.numberOfLines = 0
        
        view.addSubview(errorLabel)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: view.topAnchor),
            errorLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorLabel.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
