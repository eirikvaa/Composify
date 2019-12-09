//
//  LibraryPageControl.swift
//  Composify
//
//  Created by Eirik Vale Aase on 09/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

class LibraryPageControl: UIPageControl {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    func configureView() {
        pageIndicatorTintColor = .lightGray
        currentPageIndicatorTintColor = R.Colors.cardinalRed
    }
}
