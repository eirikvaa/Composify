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
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        guard let currentProject = currentProject else {
            // swiftlint:disable:next force_cast
            return SectionPageItem(section: nil)
        }

        guard let section = currentProject.getSection(at: index) else {
            // swiftlint:disable:next force_cast
            return SectionPageItem(section: nil)
        }

        // swiftlint:disable:next force_cast
        return SectionPageItem(section: section)
    }
    
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        guard let currentProject = currentProject,
            let section = currentProject.getSection(at: index) else {
            return UIViewController()
        }

        let sectionViewController = SectionViewController(section: section)
        sectionViewController.libraryViewController = self

        return sectionViewController
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        currentProject?.sections.count ?? 0
    }
}
