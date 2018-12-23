//
//  OboardingViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Parchment
import UIKit

class OnboardingViewController: UIViewController {
    // MARK: @IBOutlets

    @IBOutlet private var imageView: UIImageView!

    // MARK: Properties

    var backgroundImage: UIImage?
    var pageIndex = 0

    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = backgroundImage
        view.backgroundColor = R.Colors.cardinalRed
    }
}
