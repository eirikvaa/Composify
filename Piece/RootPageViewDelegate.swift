//
// Created by Eirik Vale Aase on 21.05.2017.
// Copyright (c) 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

protocol RootPageDelegate {
	func didSwipe(to indexPath: IndexPath)
}

class RootPageViewDelegate: NSObject {
	var libraryViewController: LibraryViewController!
	var delegate: RootPageDelegate?
}

extension RootPageViewDelegate: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			if let top = pageViewController.viewControllers?.first as? RecordingsViewController {
				let indexPath = IndexPath(item: top.pageIndex ?? 0, section: 0)
				delegate?.didSwipe(to: indexPath)
			}
			
		}
	}
}
