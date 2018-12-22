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

    /// Resign first responder from all textfields so that we persist a possible renaming as
    /// early as possible.
    func resignFromAllTextFields() {
        let action = #selector(UIApplication.resignFirstResponder)
        UIApplication.shared.sendAction(action, to: nil, from: nil, for: nil)
    }

    /// Instantiate an OnboardingRootViewController
    /// - returns: OnboardingRootViewController
    static func onboardingRootViewController() -> OnboardingRootViewController {
        let storyboard = UIStoryboard.onboardingStoryboard()
        return storyboard.instantiateViewController(withIdentifier: R.ViewControllerIdentifiers.onboardingRoot) as! OnboardingRootViewController
    }

    /// Instantiate an OnboardingViewController
    /// - returns: OnboardingViewController
    static func onboardingPageViewController() -> OnboardingViewController {
        let storyboard = UIStoryboard.onboardingStoryboard()
        return storyboard.instantiateViewController(withIdentifier: R.ViewControllerIdentifiers.onboardingPage) as! OnboardingViewController
    }
}
