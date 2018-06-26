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
        guard let project = viewController.project else { return NSNotFound }
        guard let section = viewController.section else { return NSNotFound }
        guard let index = project.sections.sorted().index(of: section) else { return NSNotFound }
        
        return index
	}

	func viewController(at index: Int, storyboard: UIStoryboard) -> RecordingsViewController? {
		if libraryViewController.currentProject?.sections.count == 0 || index >= (libraryViewController.currentProject?.sections.count ?? 0) {
			return nil
		}
        
        guard index < (libraryViewController.currentProject?.sections.count ?? 0) else { return nil }
        
		let recordingsViewController = storyboard.instantiateViewController(withIdentifier: Strings.StoryboardIDs.contentPageViewController) as! RecordingsViewController
		recordingsViewController.project = libraryViewController.currentProject
        recordingsViewController.section = libraryViewController.currentProject?.sections[index]
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
        RealmStore.shared.realm.refresh()
        guard let viewController = viewController as? RecordingsViewController else { return nil }
		var index = indexOfViewController(viewController)

		if index == NSNotFound {
			return nil
		}

		index += 1

		if index == libraryViewController.currentProject?.sections.sorted().count {
			return nil
		}

		return self.viewController(at: index, storyboard: libraryViewController.storyboard!)
	}
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return libraryViewController.currentProject?.sections.count ?? 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return (libraryViewController.currentProject?.sections.count ?? 0) > 0 ? 0 : -1
    }
}
