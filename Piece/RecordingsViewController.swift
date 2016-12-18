//
//  RecordingsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

/**
`RecordingsTableViewController` shows and managed recordings.
*/
// FIXME: Refactor code that saves and restores timer.
class RecordingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// MARK: Properties
	fileprivate var fetchedResultsController: NSFetchedResultsController<Recording>!
	fileprivate var previouslySelectedCellIndexPath: IndexPath?
	private var coreDataStack = CoreDataStack.sharedInstance
	private let pieFileManager = PIEFileManager()
	fileprivate var audioPlayer: AudioPlayer? {
		didSet {
			audioPlayer?.player.delegate = self
			audioPlayer?.player.volume = 1
		}
	}
	fileprivate var timer: Timer?
	var section: Section!
	var pageIndex: Int!
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
		}
	}
	fileprivate var secondsSinceStart = 0
	fileprivate var startDate: Date?
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
		didSet {
			activityIndicator.isHidden = true
		}
	}
	
	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let fetchRequest = Recording.fetchRequest() as! NSFetchRequest<Recording>
		let sortDescriptor = NSSortDescriptor(key: #keyPath(Recording.title), ascending: true)
		let predicate = NSPredicate(format: "project = %@ AND section = %@", self.section.project, self.section)
		fetchRequest.sortDescriptors = [sortDescriptor]
		fetchRequest.predicate = predicate
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataStack.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			print(error.localizedDescription)
		}
		
		
		// Want to know when the application goes into the background so we can handle the audio session.
		NotificationCenter.default.addObserver(self, selector: #selector(pauseMusic), name: Notification.Name.UIApplicationWillResignActive, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(resumeMusic), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let text = UserDefaults().value(forKey: "RecordingCurrentAndTotalTime") as? String
			, let row = UserDefaults().value(forKey: "RecordingRow") as? Int {
			let cell = tableView.cellForRow(at: IndexPath(item: row, section: 0))
			cell?.detailTextLabel?.text = text
		}
	}
	
	/**
	Stops the audio player, invalidates the timer and resets the label.
	*/
	@objc private func pauseMusic() {
		pausePlaySession()
	}
	
	@objc private func resumeMusic() {
		audioPlayer?.player.play()
		//let secondsSinceStart = UserDefaults().integer(forKey: "RecordingSecondsSinceStart")
		
		// We move the time a second closer to make up for any delays.
		//let startDate = Date(timeInterval: TimeInterval(-secondsSinceStart), since: Date())
		let startDate = UserDefaults().value(forKey: "RecordingStartDate") as! Date
		
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
			if let indexPath = self.previouslySelectedCellIndexPath, let audioPlayer = self.audioPlayer?.player {
				
				let secondsSinceStart = Int(Date().timeIntervalSince(startDate)) - 1
				
				let cell = self.tableView.cellForRow(at: indexPath)
				let currentMinutes = Int(secondsSinceStart) / 60
				let currentSeconds = Int(secondsSinceStart) % 60
				
				let durationMinutes = Int(audioPlayer.duration) / 60
				let durationSeconds = Int(audioPlayer.duration) % 60
				
				cell?.detailTextLabel?.text = String(format: "%d:%0.2d/%d:%0.2d", currentMinutes, currentSeconds, durationMinutes, durationSeconds)
			}
		})
		
		timer?.fire()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		pausePlaySession()
	}

	// MARK: UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		
		return sectionInfo.numberOfObjects
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath)
		
		let recording = fetchedResultsController.object(at: indexPath)
		
		cell.textLabel?.text = recording.title
		
		let duration = recording.duration
		let currentMinutes = Int(duration) / 60
		let currentSeconds = Int(duration) % 60
		
		cell.detailTextLabel?.text = String(format: "0:00/%d:%0.2d", currentMinutes, currentSeconds)

		return cell
	}

	// MARK: UITableViewDelegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Stop timer if there already is a song playing.
		timer?.invalidate()
		
		let recording = fetchedResultsController.object(at: indexPath)
		audioPlayer = AudioPlayer(url: recording.url)

		guard let audioPlayer = audioPlayer?.player else { return }
		
		// This stops any currently playing recordings, and starts the one selected.
		audioPlayer.play()

		if let indexPath = tableView.indexPathForSelectedRow {
			// If we previously began playing a recording, deselect it.
			if let indexPath = previouslySelectedCellIndexPath {
				let cell = tableView.cellForRow(at: indexPath)
				cell?.textLabel?.text = fetchedResultsController.object(at: indexPath).title
				tableView.reloadRows(at: [indexPath], with: .fade)
			}
			
			previouslySelectedCellIndexPath = indexPath
			let cell = tableView.cellForRow(at: indexPath)
			cell?.textLabel?.text = "\(recording.title) ..."
			tableView.deselectRow(at: indexPath, animated: true)
			let start = Date()
			startDate = start
			
			timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
				let secondsSinceStart = Int(Date().timeIntervalSince(start))
				self.secondsSinceStart = secondsSinceStart
				
				let cell = tableView.cellForRow(at: indexPath)
				let currentMinutes = Int(secondsSinceStart) / 60
				let currentSeconds = Int(secondsSinceStart) % 60
				
				let durationMinutes = Int(audioPlayer.duration) / 60
				let durationSeconds = Int(audioPlayer.duration) % 60
				
				
				cell?.detailTextLabel?.text = String(format: "%d:%0.2d/%d:%0.2d", currentMinutes, currentSeconds, durationMinutes, durationSeconds)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: "Rename".localized) { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: "Rename".localized, message: nil, preferredStyle: .alert)
			
			renameAlert.addTextField {
				$0.placeholder = self.fetchedResultsController.object(at: indexPath).title
				$0.autocapitalizationType = .words
				$0.clearButtonMode = .whileEditing
				$0.autocorrectionType = .default
			}

			let saveAction = UIAlertAction(title: "Save".localized, style: .default) { alertAction in
				guard let title = renameAlert.textFields?.first?.text else { return }
			
				if let recordings = self.fetchedResultsController.fetchedObjects {
					if recordings.contains(where: {$0.title == title}) {
						return
					}
				}
			
				let recording = self.fetchedResultsController.object(at: indexPath)

				self.pieFileManager.rename(recording, from: recording.title, to: title, section: nil, project: nil)
				recording.title = title
				self.coreDataStack.saveContext()
			}

			let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive, handler: nil)

			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)

			self.present(renameAlert, animated: true, completion: nil)
		}

		let deleteAction = UITableViewRowAction(style: .normal, title: "Delete".localized) { (rowAction, indexPath) in
			let recording = self.fetchedResultsController.object(at: indexPath)

			self.pieFileManager.delete(recording)
			self.coreDataStack.viewContext.delete(recording)
			self.coreDataStack.saveContext()
		}
		
		let shareAction = UITableViewRowAction(style: .normal, title: "Share".localized) { (rowAction, indexPath) in
			let recording = self.fetchedResultsController.object(at: indexPath)
			let activity = UIActivityViewController(activityItems: [recording.url], applicationActivities: nil)
			activity.popoverPresentationController?.sourceView = self.tableView.cellForRow(at: indexPath)
			
			self.activityIndicator.isHidden = false
			self.activityIndicator.hidesWhenStopped = true
			self.activityIndicator.startAnimating()
			
			self.present(activity, animated: true) {
				self.activityIndicator.stopAnimating()
			}
		}
		
		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
		shareAction.backgroundColor = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1.0)

		return [shareAction, renameAction, deleteAction]
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
}

// MARK: Helper Methods
private extension RecordingsViewController {
	func pausePlaySession() {
		audioPlayer?.player.pause()
		timer?.invalidate()
		
		if let indexPath = previouslySelectedCellIndexPath, let date = startDate {
			let userDefault = UserDefaults()
			let text = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
			userDefault.setValue(text, forKey: "RecordingCurrentAndTotalTime")
			userDefault.set(indexPath.row, forKey: "RecordingRow")
			userDefault.setValue(date, forKey: "RecordingStartDate")
		}
	}
}

// MARK: AVAudioPlayerDelegate
extension RecordingsViewController: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		if let indexPath = previouslySelectedCellIndexPath {
			let cell = tableView.cellForRow(at: indexPath)
			cell?.textLabel?.text = fetchedResultsController.object(at: indexPath).title
			
			// As the audio is finished playing, we'll stop the timer.
			timer?.invalidate()
			
			tableView.reloadRows(at: [indexPath], with: .fade)
		}
	}
}

// MARK: NSFetchedResultsControllerDelegate
extension RecordingsViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			if let indexPath = newIndexPath {
				tableView.insertRows(at: [indexPath], with: .fade)
			}
		case .update:
			if let indexPath = indexPath {
				tableView.reloadRows(at: [indexPath], with: .fade)
			}
		case .delete:
			if let indexPath = indexPath {
				tableView.deleteRows(at: [indexPath], with: .fade)
			}
		case .move:
			if let indexPath = indexPath, let newIndexPath = newIndexPath {
				tableView.deleteRows(at: [indexPath], with: .fade)
				tableView.insertRows(at: [newIndexPath], with: .fade)
			}
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}
