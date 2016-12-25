//
//  PageRootViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import AVFoundation

//`PageRootViewController` manages multiple `UITableView` instances.
class PageRootViewController: UIViewController {

	// MARK: Properties
	fileprivate let pageDataSourceDelegate = SectionsPageViewController()
	fileprivate var pageViewController: UIPageViewController!
	var section: Section!
	var project: Project!
	var sectionIndex = 0
	
	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupPageViewController()
	}
	
	// MARK: UITableView
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		pageViewController.viewControllers?.first?.setEditing(editing, animated: animated)
		
		if editing {
			let recordButton = UIBarButtonItem(image: UIImage(named:"Microphone"), style: .plain, target: self, action: #selector(addRecording))
			navigationItem.leftBarButtonItem = recordButton
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

// MARK: Helper Methods
private extension PageRootViewController {
	/**
	Performs the `addRecording` segue.
	*/
	@objc func addRecording() {
		performSegue(withIdentifier: "addRecording", sender: self)
	}
	
	/**
	Setups the UIPageViewController instance.
	*/
	func setupPageViewController() {
		navigationItem.rightBarButtonItem = editButtonItem
		
		pageDataSourceDelegate.pageRootViewController = self
		
		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		pageViewController.delegate = pageDataSourceDelegate
		pageViewController.dataSource = pageDataSourceDelegate
		
		let startingViewController = pageDataSourceDelegate.viewControllerAtIndex(sectionIndex, storyboard: storyboard!)!
		
		let viewControllers = [startingViewController]
		pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
		addChildViewController(pageViewController)
		view.addSubview(pageViewController.view)
		
		pageViewController.didMove(toParentViewController: self)
	}
}
