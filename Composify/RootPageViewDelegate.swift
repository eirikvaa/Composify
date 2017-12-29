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
        guard finished else { return }
        guard let topViewController = pageViewController.viewControllers?.first as? RecordingsViewController else { return }
        guard let pageIndex = topViewController.pageIndex else { return }
        libraryViewController.currentSection = libraryViewController.currentProject?.sortedSections[pageIndex]
        
        libraryViewController.setEmptyState()
	}
}
