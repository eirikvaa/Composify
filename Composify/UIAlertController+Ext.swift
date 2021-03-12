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
        let okAction = UIAlertAction(title: R.Loc.ok, style: .default)
        alert.addAction(okAction)

        return alert
    }

    static func createShowSettingsAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let settings = UIAlertAction(title: R.Loc.settings, style: .default) { _ in
            let application = UIApplication.shared
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            guard application.canOpenURL(settingsURL) else {
                return
            }

            application.open(settingsURL)
        }

        let cancel = UIAlertAction.cancelAction

        alert.addAction(settings)
        alert.addAction(cancel)

        return alert
    }

    static func createConfirmationAlert(
        title: String,
        message: String,
        completionHandler: ((UIAlertAction) -> Void)?
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )

        let delete = UIAlertAction(
            title: R.Loc.delete,
            style: .destructive,
            handler: completionHandler
        )

        let cancelAction = UIAlertAction.cancelAction

        alert.addAction(delete)
        alert.addAction(cancelAction)

        return alert
    }
}
