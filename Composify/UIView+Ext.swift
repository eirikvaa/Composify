//
//  UIView+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

/// Start from the bottom view and keep moving upwards
/// while checking for a specific tag unntil it returns
/// or nothing is found
extension UIView {
    static func findSuperView(withTag tag: Int, fromBottomView bottomView: UIView?) -> UIView? {
        var view: UIView? = bottomView

        while view?.superview?.tag != tag {
            view = view?.superview
        }

        // We stopped one level below the view we want, so return the superview.
        return view?.superview
    }
}
