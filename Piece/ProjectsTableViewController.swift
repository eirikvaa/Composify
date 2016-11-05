//
//  ProjectsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

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
		default:
			break
		}

		projects = fetchedResultsController.fetchedObjects as! [Project]
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}

class ProjectsTableViewController: UITableViewController {

	// MARK: Properties
	fileprivate lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
		let fetchRequest = Project.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]

		let fetchedResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest, managedObjectContext: self.managedContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		fetchedResultsController.delegate = self
		return fetchedResultsController
	}()
	private var managedContext = CoreDataStack.sharedInstance.managedContext
	fileprivate var projects = [Project]()

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = self.editButtonItem
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Fetches all objects every time the user navigates here because data might have changed.
		do {
			try fetchedResultsController.performFetch()
			projects = fetchedResultsController.fetchedObjects as! [Project]
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return projects.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath)
		cell.textLabel?.text = projects[indexPath.row].title
		return cell
	}

	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "Rename project")) { (rowAction, indexPath) in

			let renameAlert = UIAlertController(title: NSLocalizedString("Rename", comment: "Title of rename project alert"), message: nil, preferredStyle: .alert)

			renameAlert.addTextField(configurationHandler: { textField in
				textField.placeholder = NSLocalizedString("New Name to Project", comment: "Placeholder for new project title")
				textField.autocapitalizationType = .words
			})

			let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Title of save action"), style: .default, handler: { alertAction in


				if let title = renameAlert.textFields?.first?.text {
					let project = self.projects[indexPath.row]
					PIEFileManager().rename(project, from: project.title, to: title, section: nil, project: nil)
					project.title = title
					CoreDataStack.sharedInstance.saveContext()
				}
			})

			let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel button"), style: .destructive, handler: nil)

			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)

			self.present(renameAlert, animated: true, completion: nil)
		}

		let deleteAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Delete", comment: "Title of delete action")) { (rowAction, indexPath) in
			let project = self.projects[indexPath.row]
			PIEFileManager().delete(project)
			self.managedContext.delete(project)
			CoreDataStack.sharedInstance.saveContext()
		}

		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 207.0 / 255.0, green: 0.0 / 255.0, blue: 15.0 / 255.0, alpha: 1.0)

		return [renameAction, deleteAction]
	}

	// Mus use @objc so #selector(addProject) can be used when addProject is a private method.
	@objc private func addProject() {
		let alert = UIAlertController(title: NSLocalizedString("New Project", comment: "Title of alert when creating a new project."), message: nil, preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = NSLocalizedString("Project Title", comment: "Placeholder text for text field in alert.")
			textField.autocapitalizationType = .words
		}

		let save = UIAlertAction(title: NSLocalizedString("Save", comment: "Title of save button in configProjects."), style: .default) { alertAction in
			if let projectTitle = alert.textFields?.first?.text {
				let entityDescription = NSEntityDescription.entity(forEntityName: "Project", in: self.managedContext)

				if let entityDescription = entityDescription {
					let project = NSManagedObject(entity: entityDescription, insertInto: self.managedContext) as! Project
					project.title = projectTitle
					PIEFileManager().save(project)
					CoreDataStack.sharedInstance.saveContext()
				}
			}
		}

		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title of cancel button in configProjects."), style: .destructive, handler: nil)

		alert.addAction(save)
		alert.addAction(cancel)

		present(alert, animated: true, completion: nil)
	}

	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showSections" {
			if let destinationViewController = segue.destination as? SectionsTableViewController,
				let indexPath = tableView.indexPathForSelectedRow {
					destinationViewController.chosenProject = projects[indexPath.row]
			}
		}
	}

	// MARK: Editing
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		// Only show the + button (add project) when in editing mode.
		if editing {
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProject))
			self.navigationItem.leftBarButtonItem = addButton
		} else {
			self.navigationItem.leftBarButtonItem = nil
		}
	}
}
