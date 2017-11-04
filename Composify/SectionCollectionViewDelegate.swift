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
            
            if let vc = libraryViewController.rootPageViewController.viewControllers?.first as? RecordingsViewController {
                if let index = vc.pageIndex {
                    if index != indexPath.row {
                        if index > indexPath.row {
                            libraryViewController.rootPageViewController.setViewControllers([recordingViewController], direction: .reverse, animated: true, completion: nil)
                        } else {
                            libraryViewController.rootPageViewController.setViewControllers([recordingViewController], direction: .forward, animated: true, completion: nil)
                        }
                    }
                }
            }
			
		}
        
		libraryViewController.setEmptyState()
	}
}


