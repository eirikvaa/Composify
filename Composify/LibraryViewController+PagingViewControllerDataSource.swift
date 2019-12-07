//
//  LibraryViewController+PagingViewControllerDataSource
//  Composify
//
//  Created by Eirik Vale Aase on 06.12.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import Parchment
import UIKit

extension LibraryViewController: PagingViewControllerDataSource {
    func pagingViewController<T>(_: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T: PagingItem, T: Comparable, T: Hashable {
        guard let currentProject = currentProject else {
            // swiftlint:disable:next force_cast
            return SectionPageItem(section: nil) as! T
        }

        guard let section = currentProject.getSection(at: index) else {
            // swiftlint:disable:next force_cast
            return SectionPageItem(section: nil) as! T
        }

        // swiftlint:disable:next force_cast
        return SectionPageItem(section: section) as! T
    }

    func pagingViewController<T>(_: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T: PagingItem, T: Comparable, T: Hashable {
        guard let currentProject = currentProject,
            let section = currentProject.getSection(at: index) else {
            return UIViewController()
        }

        let sectionViewController = SectionViewController(section: section)
        sectionViewController.libraryViewController = self

        return sectionViewController
    }

    func numberOfViewControllers<T>(in _: PagingViewController<T>) -> Int where T: PagingItem, T: Comparable, T: Hashable {
        return currentProject?.sectionIDs.count ?? 0
    }
}
