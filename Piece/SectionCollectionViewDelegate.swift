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
		libraryViewController.currentSection = libraryViewController.currentProject?.sortedSections[indexPath.row]
		
		if let recordingViewController = libraryViewController.rootPageViewDataSource.viewController(at: indexPath.row, storyboard: libraryViewController.storyboard!) {
			libraryViewController.rootPageViewController.setViewControllers([recordingViewController], direction: .forward, animated: false, completion: nil)
		}
		
		libraryViewController.shouldRefresh(projectCollectionView: false, sectionCollectionView: false, recordingsTableView: true)
		libraryViewController.setEmptyState()
	}
}

extension SectionCollectionViewDelegate: RootPageDelegate {
	func didSwipe(to indexPath: IndexPath) {		
		
	}
}
