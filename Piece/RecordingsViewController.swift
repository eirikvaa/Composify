//
//  RecordingsViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 20.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class RecordingsViewController: UIViewController {
	// MARK: Lazy Properties
	lazy var tableViewDelegate: RecordingsTableViewDelegate = {
		let delegate = RecordingsTableViewDelegate()
		delegate.parentViewController = self
		return delegate
	}()
	lazy var tableViewDataSource: RecordingsTableViewDataSource = {
		let dataSource = RecordingsTableViewDataSource()
		dataSource.parentViewController = self
		return dataSource
	}()
	
	// MARK: Regular Properties
	var project: Project?
	var section: Section?
	var pageIndex: Int?
    var currentlyPlayingRecording: Recording?
    var audioPlayer: AudioPlayer? {
        didSet {
            if audioPlayer != nil {
                audioPlayer?.player.delegate = tableViewDelegate
                audioPlayer?.player.play()
            }
        }
    }

	// MARK: @IBOutlets
	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView.delegate = tableViewDelegate
			tableView.dataSource = tableViewDataSource
		}
	}

	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let notificationName = Notification.Name(rawValue: Notifications.pickedProject)
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(refresh), name: notificationName, object: nil)
		
		let sectionPicked = Notification.Name(rawValue: Notifications.pickedSection)
		center.addObserver(self, selector: #selector(refresh), name: sectionPicked, object: nil)
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
}

extension RecordingsViewController {
	@objc func refresh() {
		tableView.reloadData()
	}
}
