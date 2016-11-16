//
//  SectionsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: NSFetchedResultsController
extension SectionsTableViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			if let newIndexPath = newIndexPath {
				tableView.insertRows(at: [newIndexPath], with: .fade)
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
			break
		}

		sections = fetchedResultsController.fetchedObjects as! [Section]
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}

class SectionsTableViewController: UITableViewController {

	// MARK: Properties
	var chosenProject: Project!
	fileprivate var managedObjectContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
	fileprivate lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Section.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		let predicate = NSPredicate(format: "project = %@", self.chosenProject)
		fetchRequest.sortDescriptors = [sortDescriptor]
		fetchRequest.predicate = predicate

		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		return fetchedResultsController
	}()
	fileprivate var sections = [Section]()

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = chosenProject.title
		
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
		label.text = navigationItem.title
		label.adjustsFontSizeToFitWidth = true
		navigationItem.titleView = label
		
		
		navigationItem.rightBarButtonItem = editButtonItem
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		fetchedResultsController.delegate = self

		// Must update the content every time the user navigates to it because it might have changed.
		do {
			try fetchedResultsController.performFetch()
			sections = fetchedResultsController.fetchedObjects as! [Section]
		} catch {
			print(error.localizedDescription)
		}

		tableView.reloadData()
	}

	// MARK: UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath)

		let section = sections[indexPath.row]
		
		cell.textLabel?.text = section.title
		
		// FIXME: Localize
		if section.recordings.count != 1 {
			let ls = String.localizedStringWithFormat(
				NSLocalizedString("%d recordings", comment: "Recordings"),
				section.recordings.count)
			cell.detailTextLabel?.text = ls
		} else {
			let ls = String.localizedStringWithFormat(
				NSLocalizedString("%d recording", comment: "Recording"),
				section.recordings.count)
			cell.detailTextLabel?.text = ls
		}

		return cell
	}

	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "Rename section action")) { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: NSLocalizedString("Rename", comment: "Rename alert title"), message: nil, preferredStyle: .alert)
			renameAlert.addTextField( configurationHandler: { (textField) in
				textField.placeholder = NSLocalizedString("New Name to Section", comment: "Placeholder text for new name to section")
				textField.autocapitalizationType = .words
				textField.clearButtonMode = .whileEditing
			})

			let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Save section action"), style: .default, handler: { (alertAction) in
				if let title = renameAlert.textFields?.first?.text {
					let section = self.sections[indexPath.row]

					PIEFileManager().rename(section, from: section.title, to: title, section:nil, project:nil)
					section.title = title
					CoreDataStack.sharedInstance.saveContext()
				}
			})
			let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel button"), style: .destructive, handler: nil)

			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)

			self.present(renameAlert, animated: true, completion: nil)
		}

		let deleteAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Delete", comment: "Delete a recording.")) { (rowAction, indexPath) in
			let section = self.sections[indexPath.row]

			PIEFileManager().delete(section)
			CoreDataStack.sharedInstance.persistentContainer.viewContext.delete(section)
			CoreDataStack.sharedInstance.saveContext()
		}

		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 207.0 / 255.0, green: 0.0 / 255.0, blue: 15.0 / 255.0, alpha: 1.0)

		return [renameAction, deleteAction]
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		if editing {
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSection))
			navigationItem.leftBarButtonItem = addButton
		} else {
			navigationItem.leftBarButtonItem = nil
		}
	}

	func addSection() {
		let alert = UIAlertController(title: NSLocalizedString("New Section", comment: "Title of alert when creating new section."), message: nil, preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = NSLocalizedString("Section Title", comment: "Placeholder text for title of new section.")
			textField.autocapitalizationType = .words
			textField.clearButtonMode = .whileEditing
		}

		let save = UIAlertAction(title: NSLocalizedString("Save", comment: "Title of save button in configSections."), style: .default) { (alertAction) in
			if let title = alert.textFields?.first?.text {
				let entityDescription = NSEntityDescription.entity(forEntityName: "Section", in: self.managedObjectContext)

				if let entityDescription = entityDescription {
					let section = NSManagedObject(entity: entityDescription, insertInto: self.managedObjectContext) as! Section
					section.title = title
					section.project = self.chosenProject

					PIEFileManager().save(section)
					CoreDataStack.sharedInstance.saveContext()
				}
			}
		}

		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel button in configSections."), style: .destructive, handler: nil)

		alert.addAction(save)
		alert.addAction(cancel)

		present(alert, animated: true, completion: nil)
	}

	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showRecordings" {
			let sectionCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)
			let sectionTitle = sectionCell?.textLabel?.text
			let selectedSection = chosenProject.sections.filter { ($0 as! Section).title == sectionTitle }.first

			if let selectedSection = selectedSection {
				let destinationViewController = segue.destination as! RootViewController
				destinationViewController.project = (selectedSection as AnyObject).project
				destinationViewController.section = selectedSection as! Section
			}
		}
	}
}
