//
//  UIStoryboard+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIStoryboard {
    /// Fetch the onboarding storyboard
    /// - returns: The onboarding storyboard
    static func onboardingStoryboard() -> UIStoryboard {
        return UIStoryboard(name: R.Storyboards.onboarding, bundle: .main)
    }
}
