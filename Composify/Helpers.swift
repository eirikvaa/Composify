//
//  Helpers.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

struct T {
    var t: (Int, Int)
    
    init(_ t: (Int, Int)) {
        self.t = t
    }
}

extension T: Hashable {
    var hashValue: Int {
        return t.0.hashValue ^ t.1.hashValue
    }
}

extension T: Equatable {
    static func == (lhs: T, rhs: T) -> Bool {
        return lhs.t.0 == rhs.t.0 && lhs.t.1 == rhs.t.1
    }
}

extension T: CustomStringConvertible {
    var description: String {
        return "(\(t.0), \(t.1))"
    }
}

extension UIFont {
    static func preferredBoldFont(for style: UIFontTextStyle) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        let fontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: fontDescriptor!, size: 0)
    }
}

extension UserDefaults {
    func resetLastProject() {
        setValue(nil, forKey: "lastProjectID")
    }
    
    func resetLastSection() {
        setValue(nil, forKey: "lastSectionID")
    }
    
    var projectStoreID: String? {
        return value(forKey: "projectStoreID") as? String
    }
}

extension UIViewController {
    /// Add a view controller to another view controller.
    func add(_ child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    /// Remove a view controller from another view controller.
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
    
    func handleError(_ error: Error) {
        let title: String
        let message: String
        
        if let error = error as? AudioPlayerError {
            switch error {
            case .unableToConfigurePlayingSession:
                title = .localized(.missingRecordingAlertTitle)
                message = .localized(.missingRecordingAlertMessage)
            case .unableToPlayRecording:
                title = .localized(.unableToPlayRecordingTitle)
                message = .localized(.unableToPlayRecordingMessage)
            }
        } else if let error = error as? CFileManagerError {
            switch error {
            case .unableToSaveObject(let object):
                let objectTitle = object.getTitle() ?? ""
                title = .localized(.unableToSaveObjectTitle)
                message = String.localizedStringWithFormat(.localized(.unableToSaveObjectMessage), objectTitle)
            case .unableToDeleteObject(let object):
                let objectTitle = object.getTitle() ?? ""
                title = .localized(.unableToDeleteObjectTitle)
                message = String.localizedStringWithFormat(.localized(.unableToDeleteObjectMessage), objectTitle)
            }
        } else if let error = error as? AudioRecorderError {
            switch error {
            case .unableToConfigureRecordingSession:
                title = .localized(.unableToConfigureRecordingSessionTitle)
                message = .localized(.unableToConfigureRecordingSessionMessage)
            }
        } else {
            return
        }
        
        let alert = UIAlertController.createErrorAlert(title: title, message: message)
        present(alert, animated: true)
    }
}

extension UIAlertController {
    static func createErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: .localized(.ok), style: .default)
        alert.addAction(ok)
        
        return alert
    }
}

extension Collection {
    /// A happy-path method for checking if a collection consists of at
    /// least one element.
    var hasElements: Bool {
        return !isEmpty
    }
}

extension String {
    /// A happy-path method for checking if a string consists of at
    /// least one character.
    var hasPositiveCharacterCount: Bool {
        return !isEmpty
    }
}

/// Start from the bottom view and keep moving upwards
/// while checking for a specific tag unntil it returns
/// or nothing is found
extension UIView {
    static func findSuperView(withTag tag: Int, fromBottomView bottomView: UIView?) -> UIView? {
        var view: UIView? = bottomView
        
        while (view?.superview?.tag != tag) {
            view = view?.superview
        }
        
        // We stopped one level below the view we want, so return the superview.
        return view?.superview
    }
}
