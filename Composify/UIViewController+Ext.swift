//
//  UIViewController+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Add a view controller to another view controller.
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// Remove a view controller from another view controller.
    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    static func onboardingRootViewController() -> OnboardingRootViewController {
        let storyboard = UIStoryboard.onboardingStoryboard()
        return storyboard.instantiateViewController(withIdentifier: R.ViewControllerIdentifiers.onboardingRoot) as! OnboardingRootViewController
    }

    static func onboardingPageViewController() -> OnboardingViewController {
        let storyboard = UIStoryboard.onboardingStoryboard()
        return storyboard.instantiateViewController(withIdentifier: R.ViewControllerIdentifiers.onboardingPage) as! OnboardingViewController
    }
}
