//
//  LibraryCollectionViewCell.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import Parchment
import UIKit

class LibraryCollectionViewCell: PagingCell {
    lazy var sectionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        sectionLabel.pinToEdgesOfView(contentView)
    }

    fileprivate func configure() {
        sectionLabel.backgroundColor = .white
        sectionLabel.textAlignment = .center

        contentView.addSubview(sectionLabel)
    }

    override func setPagingItem(_ pagingItem: PagingItem, selected _: Bool, options _: PagingOptions) {
        guard let sectionItem = pagingItem as? SectionPageItem else { return }
        sectionLabel.text = sectionItem.section?.title ?? "N/A"
    }
}
