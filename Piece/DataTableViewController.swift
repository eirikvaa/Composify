//
//  DataTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: NSFetchedResultsController
extension DataTableViewController: NSFetchedResultsControllerDelegate {
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
		default:
			tableView.reloadData()
		}

		recordings = fetchedResultsController.fetchedObjects as! [Recording]
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}

// MARK: RootViewControllerDelegate
extension DataTableViewController: RootViewControllerDelegate {
	func userDidStartEditing() {
		tableView.setEditing(true, animated: true)
	}

	func userDidEndEditing() {
		tableView.setEditing(false, animated: true)
	}
}

class DataTableViewController: UITableViewController {

	// MARK: Properties
	private var audioPlayer: AudioPlayer!
	var section: Section!
	fileprivate var managedObjectContext = CoreDataStack.sharedInstance.managedContext
	fileprivate lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Recording.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		let predicate = NSPredicate(format: "project = %@ AND section = %@", self.section.project, self.section)
		fetchRequest.sortDescriptors = [sortDescriptor]
		fetchRequest.predicate = predicate

		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		return fetchedResultsController
	}()
	fileprivate var recordings = [Recording]()

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = section.title

		let statusBarHeight = UIApplication.shared.statusBarFrame.height
		tableView.contentInset = UIEdgeInsets(top: statusBarHeight + 44, left: 0, bottom: 0, right: 0)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		fetchedResultsController.delegate = self

		do {
			try fetchedResultsController.performFetch()
			recordings = fetchedResultsController.fetchedObjects as! [Recording]
		} catch {
			print(error.localizedDescription)
		}

		tableView.reloadData()
	}

	// MARK: UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return recordings.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath)

		cell.textLabel?.text = recordings[indexPath.row].title

		return cell
	}

	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let recording = recordings[indexPath.row]
		audioPlayer = AudioPlayer(url: recording.url)

		audioPlayer.player.play()

		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "Rename recording action")) { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: NSLocalizedString("Rename", comment: "Rename recording alert"), message: nil, preferredStyle: .alert)
			renameAlert.addTextField( configurationHandler: { (textField) in
				textField.placeholder = NSLocalizedString("New Name to Recording", comment: "Placeholder for new recording title")
				textField.autocapitalizationType = .words
				textField.clearButtonMode = .whileEditing
			})

			let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Save action title"), style: .default, handler: { (alertAction) in
				let title = renameAlert.textFields?.first!.text
				let recording = self.recordings[indexPath.row]

				PIEFileManager().rename(recording, from: recording.title, to: title!, section: nil, project: nil)
				recording.title = title!
				CoreDataStack.sharedInstance.saveContext()
			})

			let cancelAction = UIAlertAction(
			                                 title: NSLocalizedString("Cancel", comment: "Cancel action title"),
			                                 style: .destructive,
			                                 handler: nil)

			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)

			self.present(renameAlert, animated: true, completion: nil)
		}

		let deleteAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Delete", comment: "Deelte action title")) { (rowAction, indexPath) in
			let recording = self.recordings[indexPath.row]

			PIEFileManager().delete(recording)

			CoreDataStack.sharedInstance.persistentContainer.viewContext.delete(recording)
			CoreDataStack.sharedInstance.saveContext()
		}

		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 207.0 / 255.0, green: 0.0 / 255.0, blue: 15.0 / 255.0, alpha: 1.0)

		return [renameAction, deleteAction]
	}
}
