//
// Created by Eirik Vale Aase on 21.05.2017.
// Copyright (c) 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class SectionCollectionViewDelegate: NSObject {
	var libraryViewController: LibraryViewController!
}

// MARK: UICollectionViewDelegate
extension SectionCollectionViewDelegate: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            libraryViewController.setEmptyState()
        }
        
		libraryViewController.currentSection = libraryViewController.currentProject?.sortedSections[indexPath.row]
        
        guard let recordingViewController = libraryViewController
            .rootPageViewDataSource
            .viewController(at: indexPath.row, storyboard: libraryViewController.storyboard!) else { return }
        
        guard let vc = libraryViewController
            .rootPageViewController
            .viewControllers?.first as? RecordingsViewController else { return }
        
        guard let pageIndex = vc.pageIndex, pageIndex != indexPath.row else { return }
        
        let direction: UIPageViewControllerNavigationDirection = pageIndex > indexPath.row ? .reverse : .forward
        libraryViewController.rootPageViewController.setViewControllers([recordingViewController], direction: direction, animated: true, completion: nil)
	}
}


