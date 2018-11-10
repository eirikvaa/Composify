//
//  RootPageViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 20.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class RootPageViewDataSource: NSObject {
	var libraryViewController: LibraryViewController!

	func indexOfViewController(_ viewController: RecordingsViewController) -> Int {
        return viewController.pageIndex ?? NSNotFound
	}

	func viewController(at index: Int, storyboard: UIStoryboard) -> RecordingsViewController? {
        guard let sectionIDs = libraryViewController.currentProject?.sectionIDs else { return nil }
        guard sectionIDs.hasElements && index < sectionIDs.count else { return nil }
        guard let recordingsViewController = storyboard.instantiateViewController(withIdentifier: Strings.StoryboardIDs.contentPageViewController) as? RecordingsViewController else { return nil }
        
		recordingsViewController.project = libraryViewController.currentProject
        recordingsViewController.section = libraryViewController.currentProject?.sectionIDs[index].correspondingSection
		recordingsViewController.tableViewDataSource.libraryViewController = libraryViewController
        recordingsViewController.tableViewDelegate.libraryViewController = libraryViewController
		recordingsViewController.pageIndex = index

		return recordingsViewController
	}
}

extension RootPageViewDataSource: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? RecordingsViewController else { return nil }
		var index = indexOfViewController(viewController)

		if index == NSNotFound || index == 0 {
			return nil
		}

		index -= 1

		return self.viewController(at: index, storyboard: libraryViewController.storyboard!)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? RecordingsViewController else { return nil }
		var index = indexOfViewController(viewController)

		if index == NSNotFound {
			return nil
		}

		index += 1

		if index == libraryViewController.currentProject?.sectionIDs.count ?? 0 {
			return nil
		}

		return self.viewController(at: index, storyboard: libraryViewController.storyboard!)
	}
}
