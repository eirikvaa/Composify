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
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
