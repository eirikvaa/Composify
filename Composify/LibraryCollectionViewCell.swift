//
//  LibraryCollectionViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {
	// MARK: @IBOutlets
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.adjustsFontSizeToFitWidth = true
		}
	}
	@IBOutlet weak var deleteButton: UIButton! {
		didSet {
			deleteButton.isHidden = true
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			titleLabel.textColor = isHighlighted ? Colors.mainColor : .black
		}
	}
	
	override var isSelected: Bool {
		didSet {
			titleLabel.textColor = isSelected ? Colors.mainColor : .black
		}
	}
}
