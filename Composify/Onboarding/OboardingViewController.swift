//
//  OboardingViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Parchment
import UIKit

final class OnboardingViewController: UIViewController {
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

        applyAccessibility()
    }
}

extension OnboardingViewController {
    func applyAccessibility() {
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .image
        imageView.accessibilityLabel = R.Loc.onboardingBackgroundImageAccLabel

        switch pageIndex {
        case 0: imageView.accessibilityValue = R.Loc.onboardingBackgroundImage0AccLabel
        case 1: imageView.accessibilityValue = R.Loc.onboardingBackgroundImage1AccLabel
        case 2: imageView.accessibilityValue = R.Loc.onboardingBackgroundImage2AccLabel
        case 3: imageView.accessibilityValue = R.Loc.onboardingBackgroundImage3AccLabel
        default: break
        }
    }
}
