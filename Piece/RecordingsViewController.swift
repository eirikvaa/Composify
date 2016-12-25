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
// TODO: Refactor class.
class RecordingsViewController: UIViewController {
	
	// MARK: Properties
	fileprivate var fetchedResultsController: NSFetchedResultsController<Recording>!
	fileprivate var previouslySelectedCellIndexPath: IndexPath?
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	fileprivate let pieFileManager = PIEFileManager()
	fileprivate var audioPlayer: AudioPlayer? {
		didSet {
			audioPlayer?.player.delegate = self
			audioPlayer?.player.volume = 1
		}
	}
	fileprivate var timer: Timer?
	var section: Section!
	var pageIndex: Int!
	
	// MARK: @IBOutlets
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
		}
	}
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
		NotificationCenter.default.addObserver(self, selector: #selector(stopMusic), name: Notification.Name.UIApplicationWillResignActive, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(resetPlaySession), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		resetPlaySession()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		stopPlaySession()
	}
	
	// MARK: UITableView
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
}

// MARK: UITableVieDataSource
extension RecordingsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		
		return sectionInfo.numberOfObjects
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath)
		
		let recording = fetchedResultsController.object(at: indexPath)
		
		cell.textLabel?.text = recording.title
		
		// TODO: Refactor this out.
		let duration = recording.duration
		let totalMinutes = Int(duration) / 60
		let totalSeconds = Int(duration) % 60
		
		cell.detailTextLabel?.text = String(format: "0:00/%d:%0.2d", totalMinutes, totalSeconds)
		
		return cell
	}
}

// MARK: UITableViewDelegate
extension RecordingsViewController: UITableViewDelegate {
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
			
			// Create timer and update detailTextLabel every second.
			timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
				let secondsSinceStart = Int(Date().timeIntervalSince(start))
				if var detailLabel = cell?.detailTextLabel {
					self.update(detailLabel: &detailLabel, in: indexPath, with: secondsSinceStart)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "")) { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: NSLocalizedString("Rename", comment: ""), message: nil, preferredStyle: .alert)
			
			renameAlert.addTextField {
				$0.placeholder = self.fetchedResultsController.object(at: indexPath).title
				$0.autocapitalizationType = .words
				$0.clearButtonMode = .whileEditing
				$0.autocorrectionType = .default
			}
			
			let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { alertAction in
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
			
			let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
			
			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)
			
			self.present(renameAlert, animated: true, completion: nil)
		}
		
		let deleteAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Delete", comment: "")) { (rowAction, indexPath) in
			let recording = self.fetchedResultsController.object(at: indexPath)
			
			self.pieFileManager.delete(recording)
			self.coreDataStack.viewContext.delete(recording)
			self.coreDataStack.saveContext()
		}
		
		let shareAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Share", comment: "")) { (rowAction, indexPath) in
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

// MARK: Helper Methods
// TODO: OH MY GOD, refactor!
private extension RecordingsViewController {
	func update(detailLabel: inout UILabel, in indexPath: IndexPath, with secondsSinceStart: Int) {
		let currentMinutes = Int(secondsSinceStart) / 60
		let currentSeconds = Int(secondsSinceStart) % 60
		
		if let audioPlayer = audioPlayer?.player {
			let durationMinutes = Int(audioPlayer.duration) / 60
			let durationSeconds = Int(audioPlayer.duration) % 60
			
			detailLabel.text = String(format: "%d:%0.2d/%d:%0.2d", currentMinutes, currentSeconds, durationMinutes, durationSeconds)
		}
	}
	
	/**
	Stop the play session.
	*/
	func stopPlaySession() {
		audioPlayer?.player.stop()
		timer?.invalidate()
	}
	
	/**
	Stops the audio player, invalidates the timer and resets the label.
	*/
	@objc func stopMusic() {
		stopPlaySession()
	}
	
	/**
	Resets the play session, specifically resets the detailTextLabel to 0:00/totalMinues:totalSeconds.
	*/
	@objc func resetPlaySession() {
		if let indexPath = previouslySelectedCellIndexPath {
			let cell = tableView.cellForRow(at: indexPath)
			let recording = fetchedResultsController.object(at: indexPath)
			
			let duration = recording.duration
			let currentMinutes = Int(duration) / 60
			let currentSeconds = Int(duration) % 60
			
			cell?.detailTextLabel?.text = String(format: "0:00/%d:%0.2d", currentMinutes, currentSeconds)
		}
	}
}
