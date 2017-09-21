//
//  ProjectCollectionViewDelegate.swift
//  Piece
//
//  Created by Eirik Vale Aase on 21.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class ProjectCollectionViewDelegate: NSObject {
	var libraryViewController: LibraryViewController!
}

extension ProjectCollectionViewDelegate: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let project = libraryViewController.projects[indexPath.row]
		libraryViewController.currentProject = project
		libraryViewController.currentSection = project.sortedSections.first
		
		if let recordingViewController = libraryViewController.rootPageViewDataSource.viewController(at: 0, storyboard: libraryViewController.storyboard!) {
			libraryViewController.rootPageViewController.setViewControllers([recordingViewController], direction: .forward, animated: false, completion: nil)
		}
				
		libraryViewController.shouldRefresh(projectCollectionView: false, sectionCollectionView: true, recordingsTableView: true)
		libraryViewController.setEmptyState()
		
		if libraryViewController.sectionCollectionView.numberOfItems(inSection: 0) > 0 {
			let indexPath = IndexPath(item: 0, section: 0)
			libraryViewController.sectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
		}
		
		let cell = collectionView.cellForItem(at: indexPath) as? LibraryCollectionViewCell
		cell?.titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
		
		libraryViewController.navigationItem.title = project.title
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as? LibraryCollectionViewCell
		cell?.titleLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
	}
}
