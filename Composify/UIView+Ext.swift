//
//  UIView+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIView {
    /// Start from the bottom view and keep moving upwards
    /// while checking for a specific tag unntil it returns
    /// or nothing is found
    /// - parameter tag: The tag the wanted view has
    /// - parameter bottomView: The view from which we start searching
    /// - returns: The super view with the passed in tag, or `nil` if the view wasn't found
    static func findSuperView(withTag tag: Int, fromBottomView bottomView: UIView?) -> UIView? {
        var currentView: UIView? = bottomView

        while currentView?.superview?.tag != tag {
            currentView = currentView?.superview
        }

        // We stopped one level below the view we want, so return the superview.
        return currentView?.superview
    }

    /// Pin this view to the edges of the passed in view
    /// - parameter view: The view that this view should be pinned to
    func pinToEdges(of view: UIView) {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 0),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 0),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
