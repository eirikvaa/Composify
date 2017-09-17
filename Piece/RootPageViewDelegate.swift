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
		if finished {
			if let top = pageViewController.viewControllers?.first as? RecordingsViewController {
				let indexPath = IndexPath(item: top.pageIndex ?? 0, section: 0)
				libraryViewController.sectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
			}
		}
	}
}
