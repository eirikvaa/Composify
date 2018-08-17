//
//  LibraryCollectionViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {
    lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureViews()
    }
    
    private func configureViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}
