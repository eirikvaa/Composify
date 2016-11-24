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
		if let viewControllers = pageViewController.viewControllers as? [DataTableViewController], let viewController = viewControllers.first {
			rootViewController.section = viewController.section
			
			let navigationItemLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
			navigationItemLabel.textAlignment = .center
			navigationItemLabel.textColor = UIColor.white
			navigationItemLabel.text = viewController.section.title
			navigationItemLabel.font = UIFont.boldSystemFont(ofSize: 16)
			navigationItemLabel.adjustsFontSizeToFitWidth = true
			rootViewController.navigationItem.titleView = navigationItemLabel
			
			
			rootViewController.setEditing(false, animated: true)
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
		var index = indexOfViewController(viewController as! DataTableViewController)
		
		if index == NSNotFound || index == 0 {
			return nil
		}
		
		index -= 1
		
		return viewControllerAtIndex(index, storyboard: rootViewController.storyboard!)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var index = indexOfViewController(viewController as! DataTableViewController)
		
		if index == NSNotFound {
			return nil
		}
		
		index += 1
		
		if index == rootViewController.project.sections.count {
			return nil
		}
		
		return viewControllerAtIndex(index, storyboard: rootViewController.storyboard!)
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return rootViewController.project.sections.count
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		let viewController = pageViewController.viewControllers!.first as! DataTableViewController
		
		return viewController.pageIndex
	}
}

/**
`SectionPageViewController` is a delegate and datasource for the UIPageViewController instance.
*/
class SectionsPageViewController: NSObject {
	var rootViewController: RootViewController!
	fileprivate var sections: [Section] {		
		return rootViewController.project.sections.sorted(by: {$0.title < $1.title})
	}
	
	override init() {
		super.init()
		
		stylePageControl()
	}
	
	func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataTableViewController? {
		if rootViewController.project.sections.count == 0 || index >= rootViewController.project.sections.count {
			return nil
		}
		
		let dataTableViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataTableViewController
		dataTableViewController.section = sections[index]
		dataTableViewController.title = sections[index].title
		rootViewController.section = sections[index]
		dataTableViewController.pageIndex = index
		return dataTableViewController
	}
	
	func indexOfViewController(_ viewController: DataTableViewController) -> Int {
		return sections.index(of: viewController.section) ?? NSNotFound
	}
	
	func stylePageControl() {
		let pageControlAppearance = UIPageControl.appearance()
		pageControlAppearance.currentPageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
		pageControlAppearance.pageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.2)
	}
}
