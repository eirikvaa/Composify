//
//  SectionsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: Helper Methods
private extension SectionsTableViewController {
	@objc func addSection() {
		let alert = UIAlertController(
			title: NSLocalizedString("New Section", comment: "Title of alert when creating new section."),
			message: nil,
			preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = NSLocalizedString("Section Title", comment: "Placeholder text for title of new section.")
			textField.autocapitalizationType = .words
			textField.clearButtonMode = .whileEditing
		}
		
		let save = UIAlertAction(
			title: NSLocalizedString("Save", comment: "Title of save button in configSections."),
			style: .default,
			handler: { (alertAction) in
				if let title = alert.textFields?.first?.text, let section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: self.coreDataStack.viewContext) as? Section {
					section.title = title
					section.project = self.chosenProject
					
					self.pieFileManager.save(section)
					self.coreDataStack.saveContext()
				}
		})
		
		let cancel = UIAlertAction(
			title: NSLocalizedString("Cancel", comment: "Title of cancel button in configSections."),
			style: .destructive,
			handler: nil)
		
		alert.addAction(save)
		alert.addAction(cancel)
		
		present(alert, animated: true, completion: nil)
	}
}

// MARK: NSFetchedResultsController
extension SectionsTableViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .update:
			if let indexPath = indexPath {
				tableView.reloadRows(at: [indexPath], with: .fade)
			}
		case .insert:
			if let newIndexPath = newIndexPath {
				tableView.insertRows(at: [newIndexPath], with: .fade)
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

class SectionsTableViewController: UITableViewController {

	// MARK: Properties
	var chosenProject: Project!
	fileprivate var managedObjectContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	fileprivate var fetchedResultsController: NSFetchedResultsController<Section>!
	fileprivate let pieFileManager = PIEFileManager()


	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let fetchRequest = Section.fetchRequest() as! NSFetchRequest<Section>
		let sortDescriptor = NSSortDescriptor(key: #keyPath(Section.title), ascending: true)
		let predicate = NSPredicate(format: "project = %@", self.chosenProject)
		fetchRequest.sortDescriptors = [sortDescriptor]
		fetchRequest.predicate = predicate
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,managedObjectContext: self.coreDataStack.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			print(error.localizedDescription)
		}
		
		navigationItem.rightBarButtonItem = editButtonItem
		
		let navigationItemLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
		navigationItemLabel.textAlignment = .center
		navigationItemLabel.textColor = UIColor.white
		navigationItemLabel.text = chosenProject.title
		navigationItemLabel.font = UIFont.boldSystemFont(ofSize: 16)
		navigationItemLabel.adjustsFontSizeToFitWidth = true
		navigationItem.titleView = navigationItemLabel
	}

	// MARK: UITableView
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if editing {
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSection))
			navigationItem.leftBarButtonItem = addButton
		} else {
			navigationItem.leftBarButtonItem = nil
		}
	}

	// MARK: UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		
		return sectionInfo.numberOfObjects
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath)

		let section = fetchedResultsController.object(at: indexPath)
		cell.textLabel?.text = section.title
		cell.textLabel?.adjustsFontSizeToFitWidth = true
		
		var localizedString = ""
		
		if section.recordings.count != 1 {
			localizedString = String.localizedStringWithFormat(
				NSLocalizedString("%d recordings", comment: "Recordings"),
				section.recordings.count)
		} else {
			localizedString = String.localizedStringWithFormat(
				NSLocalizedString("%d recording", comment: "Recording"),
				section.recordings.count)
		}
		
		cell.detailTextLabel?.text = localizedString

		return cell
	}

	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(
		style: .normal,
		title: NSLocalizedString("Rename", comment: "Rename section action"),
		handler: { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: NSLocalizedString("Rename", comment: "Rename alert title"), message: nil, preferredStyle: .alert)
			
			renameAlert.addTextField { textField in
				textField.placeholder = self.fetchedResultsController.object(at: indexPath).title
				textField.autocapitalizationType = .words
				textField.clearButtonMode = .whileEditing
			}

			let saveAction = UIAlertAction(
				title: NSLocalizedString("Save", comment: "Save section action"),
				style: .default,
				handler: { (alertAction) in
					if let title = renameAlert.textFields?.first?.text {
						
						if let sections = self.fetchedResultsController.fetchedObjects {
							if sections.map({$0.title}).contains(title) { return }
						}
						
						let section = self.fetchedResultsController.object(at: indexPath)

						self.pieFileManager.rename(section, from: section.title, to: title, section:nil, project:nil)
						section.title = title
						self.coreDataStack.saveContext()
				}
			})
			
			let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel button"), style: .destructive, handler: nil)

			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)

			self.present(renameAlert, animated: true, completion: nil)
		})

		let deleteAction = UITableViewRowAction(
			style: .normal,
			title: NSLocalizedString("Delete", comment: "Delete a recording."),
			handler: { (rowAction, indexPath) in
				let section = self.fetchedResultsController.object(at: indexPath)

				self.pieFileManager.delete(section)
				self.coreDataStack.viewContext.delete(section)
				self.coreDataStack.saveContext()
		})

		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

		return [renameAction, deleteAction]
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showRecordings" {
			if let sectionIndex = tableView.indexPathForSelectedRow?.row {
				let destinationViewController = segue.destination as! RootViewController
				let section = self.fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
				destinationViewController.project = section.project
				destinationViewController.section = section
				destinationViewController.sectionIndex = sectionIndex
				destinationViewController.title = section.title
				
				let navigationItemLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
				navigationItemLabel.textAlignment = .center
				navigationItemLabel.textColor = UIColor.white
				navigationItemLabel.text = section.title
				navigationItemLabel.font = UIFont.boldSystemFont(ofSize: 16)
				navigationItemLabel.adjustsFontSizeToFitWidth = true
				destinationViewController.navigationItem.titleView = navigationItemLabel
			}
		}
	}
	
}
