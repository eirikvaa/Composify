//
//  SectionsTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

/**
`SectionsTableViewController` presents and managed all sections that a project has.
*/
class SectionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: Properties
	fileprivate var managedObjectContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	fileprivate var fetchedResultsController: NSFetchedResultsController<Section>!
	fileprivate let pieFileManager = PIEFileManager()
	var chosenProject: Project!
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
		}
	}

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
		insertAdjustableLabel(with: chosenProject.title, in: &navigationItem.titleView)
	}

	// MARK: UITableView
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
		
		if editing {
			let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSection))
			navigationItem.leftBarButtonItem = addButton
		} else {
			navigationItem.leftBarButtonItem = nil
		}
	}

	// MARK: UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		
		return sectionInfo.numberOfObjects
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath)

		let section = fetchedResultsController.object(at: indexPath)
		cell.textLabel?.text = section.title
		cell.textLabel?.adjustsFontSizeToFitWidth = true
				
		let localizedString = section.recordings.count == 1 ?
			String.localizedStringWithFormat("%d recording".localized, section.recordings.count) :
			String.localizedStringWithFormat("%d recordings".localized, section.recordings.count)
		
		cell.detailTextLabel?.text = localizedString

		return cell
	}

	// MARK: UITableViewDelegate
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let renameAction = UITableViewRowAction(style: .normal, title: "Rename".localized) { (rowAction, indexPath) in
			let renameAlert = UIAlertController(title: "Rename".localized, message: nil, preferredStyle: .alert)
			
			renameAlert.addTextField {
				var textField = $0
				self.configure(&textField, placeholder: self.fetchedResultsController.object(at: indexPath).title)
			}

			let saveAction = UIAlertAction(title: "Save".localized, style: .default) { (alertAction) in
				if let title = renameAlert.textFields?.first?.text {
					
					if let sections = self.fetchedResultsController.fetchedObjects {
						if sections.contains(where: {$0.title == title}) { return }
					}
					
					let section = self.fetchedResultsController.object(at: indexPath)

					self.pieFileManager.rename(section, from: section.title, to: title, section:nil, project:nil)
					section.title = title
					self.coreDataStack.saveContext()
				}
			}
			
			let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive, handler: nil)

			renameAlert.addAction(saveAction)
			renameAlert.addAction(cancelAction)

			self.present(renameAlert, animated: true, completion: nil)
		}

		let deleteAction = UITableViewRowAction(style: .normal, title: "Delete".localized) { (rowAction, indexPath) in
			let section = self.fetchedResultsController.object(at: indexPath)

			self.pieFileManager.delete(section)
			self.coreDataStack.viewContext.delete(section)
			self.coreDataStack.saveContext()
		}

		renameAction.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

		return [renameAction, deleteAction]
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showRecordings" {
			if let sectionIndex = tableView.indexPathForSelectedRow?.row {
				let destinationViewController = segue.destination as! PageRootViewController
				let section = self.fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
				destinationViewController.project = section.project
				destinationViewController.section = section
				destinationViewController.sectionIndex = sectionIndex
				destinationViewController.title = section.title
				insertAdjustableLabel(with: section.title, in: &destinationViewController.navigationItem.titleView)
			}
		}
	}
	
}

// MARK: Helper Methods
private extension SectionsViewController {
	/**
	Configures a textfield to be consistent.
	- Parameters:
		- textField: textfield to be configured
		- placeholder: placeholder of textfield
	*/
	func configure(_ textField: inout UITextField, placeholder: String) {
		textField.autocapitalizationType = .words
		textField.autocorrectionType = .default
		textField.clearButtonMode = .whileEditing
		textField.placeholder = placeholder
	}
	
	@objc func addSection() {
		let alert = UIAlertController(title: "New Section".localized, message: nil, preferredStyle: .alert)
		
		alert.addTextField {
			var textField = $0
			self.configure(&textField, placeholder: "Section Title".localized)
		}
		
		let save = UIAlertAction(title: "Save".localized, style: .default) { (alertAction) in
			if let title = alert.textFields?.first?.text, let section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: self.coreDataStack.viewContext) as? Section {
				section.title = title
				section.project = self.chosenProject
				
				self.pieFileManager.save(section)
				self.coreDataStack.saveContext()
			}
		}
		
		let cancel = UIAlertAction(title: "Cancel".localized, style: .destructive, handler: nil)
		
		alert.addAction(save)
		alert.addAction(cancel)
		
		present(alert, animated: true, completion: nil)
	}
	
	/**
	Inserts a label that adjusts the font of the text to the width of the label.
	- Parameters:
		- text: Label text
		- view: View that should be replaced with an adjustable label; we modify it directly (inout).
	- Warning: This is just used for the titleView of the navigation item in the navigation bar.
	*/
	func insertAdjustableLabel(with text: String, in view: inout UIView?) {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
		label.textAlignment = .center
		label.textColor = UIColor.white
		label.text = text
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.adjustsFontSizeToFitWidth = true
		view = label
	}
}

// MARK: NSFetchedResultsController
extension SectionsViewController: NSFetchedResultsControllerDelegate {
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
