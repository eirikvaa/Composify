//
//  UIAlertController+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIAlertController {
    /// Create an alert view controller for an error title + message
    /// Shows only a single OK button because there isn't much to do besides that.
    /// - parameter title: The title of the alert
    /// - parameter message: The message of the alert
    /// - returns: An alert controller for an error message
    static func createErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: R.Loc.ok, style: .default)
        alert.addAction(ok)

        return alert
    }
}
