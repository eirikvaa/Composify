//
//  RootViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: Helper Methods
private extension RootViewController {
	@objc func addRecording() {
		performSegue(withIdentifier: "addRecording", sender: self)
	}
	
	func setupPageViewController() {
		navigationItem.rightBarButtonItem = editButtonItem
		
		pageDataSourceDelegate.rootViewController = self
		
		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		pageViewController.delegate = pageDataSourceDelegate
		
		let startingViewController = pageDataSourceDelegate.viewControllerAtIndex(sectionIndex, storyboard: storyboard!)!
		
		let viewControllers = [startingViewController]
		pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
		pageViewController.dataSource = pageDataSourceDelegate
		addChildViewController(pageViewController)
		view.addSubview(pageViewController.view)
		
		pageViewController.didMove(toParentViewController: self)
	}
}

/**
`RootViewController` managed multiple `UITableView` instances.
*/
// TODO: Fix name to reflect that its a container for table views for recordings.
class RootViewController: UIViewController {

	// MARK: Properties
	fileprivate let pageDataSourceDelegate = SectionsPageViewController()
	fileprivate var pageViewController: UIPageViewController!
	var section: Section!
	var project: Project!
	
	// FIXME: Probably not using sectionIndex variable
	var sectionIndex = 0
	
	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupPageViewController()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	// MARK: UITableView
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		// This fixed the bug where edit mode wouldn't be activated.
		pageViewController.viewControllers?.first?.setEditing(editing, animated: animated)
		
		if editing {
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecording))
			navigationItem.leftBarButtonItem = addButton
		} else {
			navigationItem.leftBarButtonItem = nil
		}
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addRecording" {
			let navigationController = segue.destination as! UINavigationController
			let recordAudioViewController = navigationController.viewControllers.first as! RecordAudioViewController
			recordAudioViewController.section = section
		}
	}

}
