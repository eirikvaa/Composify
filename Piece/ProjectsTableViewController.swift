//
//  ProjectsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: Helper Methods
private extension ProjectsTableViewController {
	@objc func addProject() {
		let alert = UIAlertController(
			title: NSLocalizedString("New Project", comment: "Title of alert when creating a new project."),
			message: nil,
			preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = NSLocalizedString("Project Title", comment: "Placeholder text for text field in alert.")
			textField.autocapitalizationType = .words
			textField.clearButtonMode = .whileEditing
		}
		
		let save = UIAlertAction(
			title: NSLocalizedString("Save", comment: "Title of save button in configProjects."),
			style: .default,
			handler: { alertAction in
				if let projectTitle = alert.textFields?.first?.text, let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: self.coreDataStack.viewContext) as? Project {
					project.title = projectTitle
					self.pieFileManager.save(project)
					self.coreDataStack.saveContext()
				}
		})
		
		let cancel = UIAlertAction(
			title: NSLocalizedString("Cancel", comment: "Title of cancel button in configProjects."),
			style: .destructive,
			handler: nil)
		
		alert.addAction(save)
		alert.addAction(cancel)
		
		present(alert, animated: true, completion: nil)
	}
}

// MARK: NSFetchedResultsController
extension ProjectsTableViewController: NSFetchedResultsControllerDelegate {
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
`ProjectsTableViewController` shows and managed projects.
*/
class ProjectsTableViewController: UITableViewController {

	// MARK: Properties
	private var fetchedResultsController: NSFetchedResultsController<Project>!
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	fileprivate let pieFileManager = PIEFileManager()

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest() as! NSFetchRequest<Project>
		//let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		let sortDescriptor = NSSortDescriptor(key: #keyPath(Project.title), ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,managedObjectContext: self.coreDataStack.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			print(error.localizedDescription)
		}
		
		navigationItem.rightBarButtonItem = self.editButtonItem
		navigationItem.title = NSLocalizedString("Projects", comment: "")
	}
	
	// MARK: UITableView
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if editing {
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProject))
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath)
		
		let project = fetchedResultsController.object(at: indexPath)
		
		cell.textLabel?.text = project.title
		cell.textLabel?.adjustsFontSizeToFitWidth = true
		
		var localizedString = ""
		
		switch (project.sections.count != 1, project.recordings.count != 1) {
		case (true, true):
			localizedString = String.localizedStringWithFormat(
				NSLocalizedString("%d sections and %d recordings", comment: "Sections and recordings"),
				project.sections.count, project.recordings.count)
		case (false, true):
			localizedString = String.localizedStringWithFormat(
				NSLocalizedString("%d section and %d recordings", comment: "Section and recordings"),
				project.sections.count, project.recordings.count)
		case (true, false):
			localizedString = String.localizedStringWithFormat(
				NSLocalizedString("%d sections and %d recording", comment: "Section and recordings"),
				project.sections.count, project.recordings.count)
		case (false, false):
			localizedString = String.localizedStringWithFormat(
				NSLocalizedString("%d section and %d recording", comment: "Section and recording"),
				project.sections.count, project.recordings.count)
		}
		
		cell.detailTextLabel?.text = localizedString
		
		return cell
	}

	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(
			style: .normal,
			title: NSLocalizedString("Rename", comment: "Rename project"),
			handler: { (rowAction, indexPath) in

			let renameAlert = UIAlertController(
				title: NSLocalizedString("Rename", comment: "Title of rename project alert"),
				message: nil,
				preferredStyle: .alert)

			renameAlert.addTextField { textField in
				textField.placeholder = self.fetchedResultsController.object(at: indexPath).title
				textField.autocapitalizationType = .words
				textField.clearButtonMode = .whileEditing
			}

			let saveAction = UIAlertAction(
				title: NSLocalizedString("Save", comment: "Title of save action"),
				style: .default,
				handler: { alertAction in
				if let title = renameAlert.textFields?.first?.text {
					
					let projects = self.fetchedResultsController.fetchedObjects!
					
					if projects.map({$0.title}).contains(title) {
						return
					}
					
					let project = self.fetchedResultsController.object(at: indexPath)
					self.pieFileManager.rename(project, from: project.title, to: title, section: nil, project: nil)
					project.title = title
					self.coreDataStack.saveContext()
				}
			})

			let cancelAction = UIAlertAction(
				title: NSLocalizedString("Cancel", comment: "Title of cancel button"),
				style: .destructive,
				handler: nil)

			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)

			self.present(renameAlert, animated: true, completion: nil)
		})

		let deleteAction = UITableViewRowAction(
			style: .normal,
			title: NSLocalizedString("Delete", comment: "Title of delete action"),
			handler: { (rowAction, indexPath) in
				let project = self.fetchedResultsController.object(at: indexPath)
				self.pieFileManager.delete(project)
				self.coreDataStack.viewContext.delete(project)
				self.coreDataStack.saveContext()
		})

		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

		return [renameAction, deleteAction]
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showSections" {
			if let destinationViewController = segue.destination as? SectionsTableViewController,
				let indexPath = tableView.indexPathForSelectedRow {
				destinationViewController.chosenProject = fetchedResultsController.object(at: indexPath)
			}
		}
	}
	
}
