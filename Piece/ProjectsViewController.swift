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
		
		// Subclassing UIViewController (not UITableViewController), so we must excplicitly set the state.
		tableView.setEditing(editing, animated: animated)
		
		if editing {
			let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProject))
			navigationItem.leftBarButtonItem = button
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
		let rename = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "")) { (rowAction, indexPath) in
			let alert = UIAlertController(title: NSLocalizedString("Rename", comment: ""), message: nil, preferredStyle: .alert)
			
			alert.addTextField {
				var textField = $0
				self.configure(&textField, placeholder: self.fetchedResultsController.object(at: indexPath).title)
			}
			
			let save = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { alertAction in
				if let title = alert.textFields?.first?.text {
					guard let projects = self.fetchedResultsController.fetchedObjects,
						!projects.contains(where: { $0.title == title }) else {
							let alert = UIAlertController(title: NSLocalizedString("Duplicate title!", comment: ""), message: NSLocalizedString("A project with this title already exists.", comment: ""), preferredStyle: .alert)
							let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
							alert.addAction(ok)
							self.present(alert, animated: true, completion: nil)
							
							return
					}
					
					let project = self.fetchedResultsController.object(at: indexPath)
					self.pieFileManager.rename(project, from: project.title, to: title, section: nil, project: nil)
					project.title = title
					self.coreDataStack.saveContext()
				}
			}
			
			let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
			
			alert.addAction(save)
			alert.addAction(cancel)
			
			self.present(alert, animated: true, completion: nil)
		}
		
		let delete = UITableViewRowAction(style: .normal, title: NSLocalizedString("Delete", comment: "")) { (rowAction, indexPath) in
			let project = self.fetchedResultsController.object(at: indexPath)
			self.pieFileManager.delete(project)
			self.coreDataStack.viewContext.delete(project)
			self.coreDataStack.saveContext()
		}
		
		rename.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		delete.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
		
		return [rename, delete]
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
		let alert = UIAlertController(title: NSLocalizedString("New Project", comment: ""), message: nil, preferredStyle: .alert)
		
		alert.addTextField {
			var textField = $0
			self.configure(&textField, placeholder: NSLocalizedString("Project Title", comment: ""))
		}
		
		let save = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { alertAction in
			if let title = alert.textFields?.first?.text {
				guard let projects = self.fetchedResultsController.fetchedObjects,
					!projects.contains(where: { $0.title == title }) else {
						let alert = UIAlertController(title: NSLocalizedString("Duplicate title!", comment: ""), message: NSLocalizedString("A project with this title already exists.", comment: ""), preferredStyle: .alert)
						let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
						alert.addAction(ok)
						self.present(alert, animated: true, completion: nil)
						
						return
				}
				
				if let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: self.coreDataStack.viewContext) as? Project {
					project.title = title
					self.pieFileManager.save(project)
					self.coreDataStack.saveContext()
				}
			}
		}
		
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
		
		alert.addAction(save)
		alert.addAction(cancel)
		
		present(alert, animated: true, completion: nil)
	}
}
