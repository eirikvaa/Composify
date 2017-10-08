//
//  RootPageViewDataSource.swift
//  Piece
//
//  Created by Eirik Vale Aase on 20.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class RootPageViewDataSource: NSObject {
	var libraryViewController: LibraryViewController!

	func indexOfViewController(_ viewController: RecordingsViewController) -> Int {
		if let project = viewController.project, let section = viewController.section {
			return project.sortedSections.index(of: section) ?? NSNotFound
		}
		return NSNotFound
	}

	func viewController(at index: Int, storyboard: UIStoryboard) -> RecordingsViewController? {
		if libraryViewController.currentProject?.sections.count == 0 || index >= (libraryViewController.currentProject?.sections.count)! {
			return nil
		}

		let recordingsViewController = storyboard.instantiateViewController(withIdentifier: Strings.StoryboardIDs.contentPageViewController) as! RecordingsViewController
		recordingsViewController.project = libraryViewController.currentProject
		recordingsViewController.section = libraryViewController.currentProject?.sortedSections[index]
		recordingsViewController.tableViewDataSource.libraryViewController = libraryViewController
		recordingsViewController.tableViewDelegate.libraryViewController = libraryViewController
		recordingsViewController.pageIndex = index

		return recordingsViewController
	}
}

extension RootPageViewDataSource: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var index = indexOfViewController(viewController as! RecordingsViewController)

		if index == NSNotFound || index == 0 {
			return nil
		}

		index -= 1

		return self.viewController(at: index, storyboard: libraryViewController.storyboard!)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var index = indexOfViewController(viewController as! RecordingsViewController)

		if index == NSNotFound {
			return nil
		}

		index += 1

		if index == libraryViewController.currentProject?.sections.count {
			return nil
		}

		return self.viewController(at: index, storyboard: libraryViewController.storyboard!)
	}
}


