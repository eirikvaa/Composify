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

// MARK: Helper Methods
private extension RecordingsTableViewController {
	func durationOfRecording(url: URL) -> Float64  {
		let audioAsset = AVURLAsset(url: url)
		let assetDuration = audioAsset.duration
		return CMTimeGetSeconds(assetDuration)
	}
}

// MARK: AVAudioPlayerDelegate
extension RecordingsTableViewController: AVAudioPlayerDelegate {
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
extension RecordingsTableViewController: NSFetchedResultsControllerDelegate {
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

/**
`RecordingsTableViewController` shows and managed recordings.
*/
class RecordingsTableViewController: UITableViewController {
	
	// MARK: Properties
	fileprivate var fetchedResultsController: NSFetchedResultsController<Recording>!
	fileprivate var previouslySelectedCellIndexPath: IndexPath?
	private var coreDataStack = CoreDataStack.sharedInstance
	private let pieFileManager = PIEFileManager()
	private var audioPlayer: AudioPlayer? {
		didSet {
			audioPlayer?.player.delegate = self
			audioPlayer?.player.volume = 1
		}
	}
	var section: Section!
	var pageIndex: Int!
	var timer: Timer?
	
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
		
		let statusBarHeight = UIApplication.shared.statusBarFrame.height
		let edgeInsets = UIEdgeInsets(top: statusBarHeight + 44, left: 0, bottom: 0, right: 0)
		tableView.contentInset = edgeInsets
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		audioPlayer?.player.stop()
		timer?.invalidate()
	}

	// MARK: UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		
		return sectionInfo.numberOfObjects
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath)
		
		let recording = fetchedResultsController.object(at: indexPath)
		
		cell.textLabel?.text = recording.title
		
		let duration = durationOfRecording(url: recording.url)
		let currentMinutes = Int(duration) / 60
		let currentSeconds = Int(duration) % 60
		
		cell.detailTextLabel?.text = String(format: "0:00/%d:%0.2d", currentMinutes, currentSeconds)

		return cell
	}

	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
			
			timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
				let secondsSinceStart = Int(Date().timeIntervalSince(start))
				let cell = tableView.cellForRow(at: indexPath)
				let currentMinutes = Int(secondsSinceStart) / 60
				let currentSeconds = Int(secondsSinceStart) % 60
				
				let durationMinutes = Int(audioPlayer.duration) / 60
				let durationSeconds = Int(audioPlayer.duration) % 60
				
				
				cell?.detailTextLabel?.text = String(format: "%d:%0.2d/%d:%0.2d", currentMinutes, currentSeconds, durationMinutes, durationSeconds)
			})
		}
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "")) { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: NSLocalizedString("Rename", comment: ""), message: nil, preferredStyle: .alert)
			
			renameAlert.addTextField( configurationHandler: { (textField) in
				textField.placeholder = self.fetchedResultsController.object(at: indexPath).title
				textField.autocapitalizationType = .words
				textField.clearButtonMode = .whileEditing
				textField.autocorrectionType = .default
			})

			let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { (alertAction) in
				guard let title = renameAlert.textFields?.first?.text else { return }
			
				if let recordings = self.fetchedResultsController.fetchedObjects {
					if recordings.map({$0.title}).contains(title) {
						return
					}
				}
			
				let recording = self.fetchedResultsController.object(at: indexPath)

				self.pieFileManager.rename(recording, from: recording.title, to: title, section: nil, project: nil)
				recording.title = title
				self.coreDataStack.saveContext()
			})

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
			self.present(activity, animated: true, completion: nil)
		}
		
		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
		shareAction.backgroundColor = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1.0)

		return [shareAction, renameAction, deleteAction]
	}
}
