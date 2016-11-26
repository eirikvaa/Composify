//
//  SectionsPageViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 19.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: UIPageViewControllerDelegate
extension SectionsPageViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if let viewControllers = pageViewController.viewControllers as? [RecordingsTableViewController], let viewController = viewControllers.first {
			pageRootViewController.section = viewController.section
			
			let navigationItemLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
			navigationItemLabel.textAlignment = .center
			navigationItemLabel.textColor = UIColor.white
			navigationItemLabel.text = viewController.section.title
			navigationItemLabel.font = UIFont.boldSystemFont(ofSize: 16)
			navigationItemLabel.adjustsFontSizeToFitWidth = true
			pageRootViewController.navigationItem.titleView = navigationItemLabel
			
			
			pageRootViewController.setEditing(false, animated: true)
		}
		
		if let previousViewController = previousViewControllers.first {
			previousViewController.setEditing(false, animated: true)
		}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		if let viewController = pendingViewControllers.first {
			viewController.setEditing(false, animated: false)
		}
	}
}

// MARK: UIPageViewControllerDataSource
extension SectionsPageViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var index = indexOfViewController(viewController as! RecordingsTableViewController)
		
		if index == NSNotFound || index == 0 {
			return nil
		}
		
		index -= 1
		
		return viewControllerAtIndex(index, storyboard: pageRootViewController.storyboard!)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var index = indexOfViewController(viewController as! RecordingsTableViewController)
		
		if index == NSNotFound {
			return nil
		}
		
		index += 1
		
		if index == pageRootViewController.project.sections.count {
			return nil
		}
		
		return viewControllerAtIndex(index, storyboard: pageRootViewController.storyboard!)
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pageRootViewController.project.sections.count
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		let viewController = pageViewController.viewControllers!.first as! RecordingsTableViewController
		
		return viewController.pageIndex
	}
}

/**
`SectionPageViewController` is a delegate and datasource for the UIPageViewController instance.
*/
class SectionsPageViewController: NSObject {
	var pageRootViewController: PageRootViewController!
	fileprivate var sections: [Section] {		
		return pageRootViewController.project.sections.sorted(by: {$0.title < $1.title})
	}
	
	override init() {
		super.init()
		
		stylePageControl()
	}
	
	func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> RecordingsTableViewController? {
		if pageRootViewController.project.sections.count == 0 || index >= pageRootViewController.project.sections.count {
			return nil
		}
		
		let recordingsTableViewController = storyboard.instantiateViewController(withIdentifier: "RecordingsViewController") as! RecordingsTableViewController
		recordingsTableViewController.section = sections[index]
		recordingsTableViewController.title = sections[index].title
		pageRootViewController.section = sections[index]
		recordingsTableViewController.pageIndex = index
		return recordingsTableViewController
	}
	
	func indexOfViewController(_ viewController: RecordingsTableViewController) -> Int {
		return sections.index(of: viewController.section) ?? NSNotFound
	}
	
	func stylePageControl() {
		let pageControlAppearance = UIPageControl.appearance()
		pageControlAppearance.currentPageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
		pageControlAppearance.pageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.2)
	}
}
