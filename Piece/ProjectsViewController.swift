//
//  ProjectsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

/**
`ProjectsTableViewController` shows and manages projects; you can add, delete and rename projects.
*/
class ProjectsViewController: UIViewController {

	// MARK: Properties
	fileprivate var fetchedResultsController: NSFetchedResultsController<Project>!
	fileprivate let coreDataStack = CoreDataStack.sharedInstance
	fileprivate let pieFileManager = PIEFileManager()
	
	// MARK: @IBOutlets
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
		}
	}

	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		let fetchRequest = Project.fetchRequest() as! NSFetchRequest<Project>
		let sortDescriptor = NSSortDescriptor(key: #keyPath(Project.title), ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataStack.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
		tableView.setEditing(editing, animated: animated)
		
		if editing {
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProject))
			navigationItem.leftBarButtonItem = addButton
		} else {
			navigationItem.leftBarButtonItem = nil
		}
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showSections" {
			if let destinationViewController = segue.destination as? SectionsViewController,
				let indexPath = tableView.indexPathForSelectedRow {
				destinationViewController.chosenProject = fetchedResultsController.object(at: indexPath)
			}
		}
	}
}

// MARK: UITableViewDelegate
extension ProjectsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: ""), handler: { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: NSLocalizedString("Rename", comment: ""), message: nil, preferredStyle: .alert)
			renameAlert.addTextField {
				var textField = $0
				self.configure(&textField, placeholder: self.fetchedResultsController.object(at: indexPath).title)
			}
			
			let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { alertAction in
				if let title = renameAlert.textFields?.first?.text {
					
					guard let projects = self.fetchedResultsController.fetchedObjects,
						!projects.contains(where: { $0.title == title }) else { return }
					
					let project = self.fetchedResultsController.object(at: indexPath)
					self.pieFileManager.rename(project, from: project.title, to: title, section: nil, project: nil)
					project.title = title
					self.coreDataStack.saveContext()
				}
			}
			
			let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
			
			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)
			
			self.present(renameAlert, animated: true, completion: nil)
		})
		
		let deleteAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Delete", comment: "")) { (rowAction, indexPath) in
			let project = self.fetchedResultsController.object(at: indexPath)
			self.pieFileManager.delete(project)
			self.coreDataStack.viewContext.delete(project)
			self.coreDataStack.saveContext()
		}
		
		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
		
		return [renameAction, deleteAction]
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: UITableViewDataSource
extension ProjectsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		
		return sectionInfo.numberOfObjects
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath)
		
		let project = fetchedResultsController.object(at: indexPath)
		
		cell.textLabel?.text = project.title
		cell.textLabel?.adjustsFontSizeToFitWidth = true
		
		let sectionsWord = project.sections.count == 1 ?
			NSLocalizedString("section", comment: "") :
			NSLocalizedString("sections", comment: "")
		
		let recordingsWord = project.recordings.count == 1 ?
			NSLocalizedString("recording", comment: "") :
			NSLocalizedString("recordings", comment: "")
		
		let localizedString = String.localizedStringWithFormat(NSLocalizedString("%d %@ and %d %@", comment: ""), project.sections.count, sectionsWord, project.recordings.count, recordingsWord)
		
		cell.detailTextLabel?.text = localizedString
		
		return cell
	}
}

// MARK: NSFetchedResultsController
extension ProjectsViewController: NSFetchedResultsControllerDelegate {
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

// MARK: Helper Methods
private extension ProjectsViewController {
	/**
	Configures a text field with the appropriate settings.
	- Parameters:
		- textField: textfield to be configured
		- placeholder: placeholder for textfield
	*/
	func configure(_ textField: inout UITextField, placeholder: String) {
		textField.autocapitalizationType = .words
		textField.autocorrectionType = .default
		textField.clearButtonMode = .whileEditing
		textField.placeholder = placeholder
	}
	
	/**
	Adds a new project. Returns if user tries to add a project with an existing title.
	*/
	@objc func addProject() {
		let newProjectAlert = UIAlertController(title: NSLocalizedString("New Project", comment: ""), message: nil, preferredStyle: .alert)
		
		newProjectAlert.addTextField {
			var textField = $0
			self.configure(&textField, placeholder: NSLocalizedString("Project Title", comment: ""))
		}
		
		let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { alertAction in
			if let projectTitle = newProjectAlert.textFields?.first?.text {
				
				if let projects = self.fetchedResultsController.fetchedObjects {
					if projects.contains(where: { $0.title == projectTitle }) {
						// If title is taken, just show a message and return.
						let duplicateAlert = UIAlertController(title: NSLocalizedString("A project with this name already exists", comment: ""), message: nil, preferredStyle: .alert)
						let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
						duplicateAlert.addAction(okAction)
						self.present(duplicateAlert, animated: true, completion: nil)
						
						return
					} else {
						if let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: self.coreDataStack.viewContext) as? Project {
							project.title = projectTitle
							self.pieFileManager.save(project)
							self.coreDataStack.saveContext()
						}
					}
				}
			}
		}
		
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
		
		newProjectAlert.addAction(saveAction)
		newProjectAlert.addAction(cancelAction)
		
		present(newProjectAlert, animated: true, completion: nil)
	}
}
