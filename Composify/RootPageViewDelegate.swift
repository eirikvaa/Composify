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

        reloadViewController(pageViewController, pageIndex: pageIndex!)
	}
}

private extension RootPageViewDelegate {
    func reloadViewController(_ pageViewController: UIPageViewController, pageIndex: Int) {
        guard let topViewController = pageViewController.viewControllers?.first as? RecordingsViewController else { return }
        guard let pageIndex = topViewController.pageIndex else { return }
        guard let currentProject = libraryViewController.currentProject else { return }
        
        let indexPath = IndexPath(row: pageIndex, section: 0)
        libraryViewController.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        libraryViewController.pageControl.currentPage = pageIndex
        libraryViewController.currentProject = currentProject
        libraryViewController.currentSectionID = currentProject.sectionIDs[indexPath.row]
        libraryViewController.updateUI()
        
        UserDefaults.standard.persist(project: currentProject)
        UserDefaults.standard.persist(section: libraryViewController.currentSection)
    }
}
