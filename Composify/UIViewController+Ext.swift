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
    
    func handleError(_ error: Error) {
        let title: String
        let message: String
        
        if let error = error as? AudioPlayerServiceError {
            switch error {
            case .unableToConfigurePlayingSession:
                title = .localized(.missingRecordingAlertTitle)
                message = .localized(.missingRecordingAlertMessage)
            case .unableToFindPlayable:
                title = .localized(.unableToFindRecordingTitle)
                message = .localized(.unableToFindRecordingMessage)
            }
        } else if let error = error as? FileManagerError {
            switch error {
            case .unableToSaveObject(let object):
                let objectTitle = object.getTitle() ?? ""
                title = .localized(.unableToSaveObjectTitle)
                message = .localizedLocale(.unableToSaveObjectMessage, objectTitle)
            case .unableToDeleteObject(let object):
                let objectTitle = object.getTitle() ?? ""
                title = .localized(.unableToDeleteObjectTitle)
                message = .localizedLocale(.unableToDeleteObjectMessage, objectTitle)
            }
        } else if let error = error as? AudioRecorderServiceError {
            switch error {
            case .unableToConfigureRecordingSession:
                title = .localized(.unableToConfigureRecordingSessionTitle)
                message = .localized(.unableToConfigureRecordingSessionMessage)
            }
        } else {
            print(error.localizedDescription)
            return
        }
        
        let alert = UIAlertController.createErrorAlert(title: title, message: message)
        present(alert, animated: true)
    }
}
