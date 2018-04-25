//
// Created by Eirik Vale Aase on 21.05.2017.
// Copyright (c) 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class RootPageViewDelegate: NSObject {
	var libraryViewController: LibraryViewController!
}

extension RootPageViewDelegate: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageIndex = (pageViewController.viewControllers?.first as? RecordingsViewController)?.pageIndex
        
        if let pageIndex = pageIndex {
            let indexPath = IndexPath(row: pageIndex, section: 0)
            reloadViewController(pageViewController)
            libraryViewController.sectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        }
	}
}

private extension RootPageViewDelegate {
    func reloadViewController(_ pageViewController: UIPageViewController) {
        guard let topViewController = pageViewController.viewControllers?.first as? RecordingsViewController else { return }
        guard let pageIndex = topViewController.pageIndex else { return }
        libraryViewController.currentSection = libraryViewController.currentProject?.sortedSections[pageIndex]
        
        libraryViewController.setEmptyState()
        libraryViewController.shouldRefresh(projectCollectionView: false, sectionCollectionView: true, recordingsTableView: true)
    }
}
