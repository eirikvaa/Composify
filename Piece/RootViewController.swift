//
//  RootViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit

protocol RootViewControllerDelegate {
	func userDidStartEditing()
	func userDidEndEditing()
}

// MARK: Helper methods
private extension RootViewController {
	func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataTableViewController? {
		if project.sections.count == 0 || index >= project.sections.count {
			return nil
		}

		let dataTableViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataTableViewController
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		let sections = project.sections.sortedArray(using: [sortDescriptor]) as! Array<Section>
		dataTableViewController.section = sections[index]
		section = sections[index]
		delegate = dataTableViewController
		return dataTableViewController
	}

	func indexOfViewController(_ viewController: DataTableViewController) -> Int {
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		let sections = project.sections.sortedArray(using: [sortDescriptor]) as! Array<Section>
		return sections.index(of: viewController.section) ?? NSNotFound
	}
}

// MARK: UIPageViewControllerDataSource
extension RootViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var index = indexOfViewController(viewController as! DataTableViewController)

		if index == NSNotFound || index == 0 {
			return nil
		}

		index -= 1

		return viewControllerAtIndex(index, storyboard: storyboard!)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var index = indexOfViewController(viewController as! DataTableViewController)

		if index == NSNotFound {
			return nil
		}

		index += 1

		if index == project.sections.count {
			return nil
		}

		return viewControllerAtIndex(index, storyboard: storyboard!)
	}
}

// MARK: UIPageViewControllerDelegate
extension RootViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		let title = (pageViewController.viewControllers?.first! as! DataTableViewController).section.title
		navigationItem.title = title
		section = project.sections.first(where: {($0 as! Section).title == title}) as! Section!
	}
}

class RootViewController: UIViewController {

	// MARK: @IBOutlets
	@IBOutlet weak var editBarButton: UIBarButtonItem! {
		didSet {
			editBarButton.style = .done
		}
	}

	// MARK: Properties
	private var pageViewController: UIPageViewController!
	var project: Project!
	var section: Section!
	var delegate: RootViewControllerDelegate!
	fileprivate var userIsEditing = false

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		pageViewController.delegate = self

		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		let sections = project.sections.sortedArray(using: [sortDescriptor]) as! Array<Section>
		let sectionIndex = sections.index(of: section)

		let startingViewController: DataTableViewController = viewControllerAtIndex(sectionIndex!, storyboard: storyboard!)!
		let viewControllers = [startingViewController]
		pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
		pageViewController.dataSource = self
		addChildViewController(pageViewController!)
		view.addSubview(pageViewController!.view)

		pageViewController.didMove(toParentViewController: self)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationItem.title = section.title
	}

	func addRecording() {
		performSegue(withIdentifier: "addRecording", sender: self)
	}

	@IBAction func edit(_ sender: UIBarButtonItem) {
		switch userIsEditing {
		case false:
			delegate.userDidStartEditing()
			sender.title = NSLocalizedString("Done", comment: "Title of done button when editing recordings.")
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecording))
			navigationItem.leftBarButtonItem = addButton
		case true:
			delegate.userDidEndEditing()
			sender.title = NSLocalizedString("Edit", comment: "Title of done button before editing recordings.")
			navigationItem.leftBarButtonItem = nil
		}

		userIsEditing = !userIsEditing
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addRecording" {
			let nav = segue.destination as! UINavigationController
			let recordAudioViewController = nav.viewControllers.first as! RecordAudioViewController
			recordAudioViewController.section = section
		}
	}

}
