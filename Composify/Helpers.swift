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
    static func ==(lhs: T, rhs: T) -> Bool {
        return lhs.t.0 == rhs.t.0 && lhs.t.1 == rhs.t.1
    }
}

extension T: CustomStringConvertible {
    var description: String {
        return "(\(t.0), \(t.1))"
    }
}

extension UIFont {
    static func preferredBoldFont(for style: UIFontTextStyle) -> UIFont  {
        let font = UIFont.preferredFont(forTextStyle: style)
        let fontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: fontDescriptor!, size: 0)
    }
}

extension UserDefaults {
    func persist(project: Project?) {
        guard let project = project else { return }
        setValue(project.id, forKey: "lastProjectID")
    }
    
    func lastProject() -> Project? {
        guard let id = UserDefaults.standard.string(forKey: "lastProjectID") else { return nil }
        return RealmStore.shared.realm.object(ofType: Project.self, forPrimaryKey: id)
    }
}

extension Array where Element: Comparable {
    
    @discardableResult
    mutating func removeFirst(_ element: Element) -> Element? {
        guard let firstElement = self.first(where: { $0 == element }) else { return nil }
        guard let index = self.index(of: firstElement) else { return nil }
        let element = self.remove(at: index)
        return element
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}
