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
                title = R.Loc.missingRecordingAlertTitle
                message = R.Loc.missingRecordingAlertMessage
            case .unableToFindPlayable:
                title = R.Loc.unableToFindRecordingTitle
                message = R.Loc.unableToFindRecordingMessage
            }
        } else if let error = error as? FileManagerError {
            switch error {
            case let .unableToSaveObject(object):
                let objectTitle = object.getTitle() ?? ""
                title = R.Loc.unableToSaveObjectTitle
                message = R.Loc.unableToSaveObjectMessage(withTitle: objectTitle)
            case let .unableToDeleteObject(object):
                let objectTitle = object.getTitle() ?? ""
                title = R.Loc.unableToDeleteObjectTitle
                message = R.Loc.unableToDeleteObjectMessage(withTitle: objectTitle)
            }
        } else if let error = error as? AudioRecorderServiceError {
            switch error {
            case .unableToConfigureRecordingSession:
                title = R.Loc.unableToConfigureRecordingSessionTitle
                message = R.Loc.unableToConfigureRecordingSessionMessage
            }
        } else {
            print(error.localizedDescription)
            return
        }

        let alert = UIAlertController.createErrorAlert(title: title, message: message)
        present(alert, animated: true)
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
