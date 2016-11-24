//
//  ConfigureRecordingTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: @IBActions
private extension ConfigureRecordingTableViewController {
	@objc @IBAction func playAudio(_ sender: AnyObject) {
		audioPlayer = AudioPlayer(url: recording.url)
		audioPlayer.player.play()
	}
	
	@objc @IBAction func save(_ sender: AnyObject) {
		guard let project = project, let section = section else { return }
		
		guard let newTitle = recordingTitleTextField.text, !isDuplicate(newTitle) else {
			showOKAlert(NSLocalizedString("Duplicate title!", comment: "The title is not unique in the project and section."), message: nil)
			return
		}
		
		// The audio file is already created, so we'll just rename it.
		self.pieFileManager.rename(recording, from: recording.title, to: newTitle, section: section, project: project)
		recording.title = newTitle
		recording.section = section
		recording.project = project
		self.coreDataStack.saveContext()
		presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	@objc @IBAction func cancel(_ sender: AnyObject) {
		// We'll notify the user if he/she tries to cancel the configuration of the recording.
		let localizedTitle = NSLocalizedString("Recording will be deleted. Proceed?", comment: "Alert when user cancels the recording.")
		let cancelAlert = UIAlertController(title: localizedTitle, message: nil, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "OK", style: .default) { _ in
			self.pieFileManager.delete(self.recording)
			self.coreDataStack.viewContext.delete(self.recording)
			self.coreDataStack.saveContext()
			
			self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
		}
		let localizedCancel = NSLocalizedString("Cancel", comment: "Cancelling configuration")
		let noAction = UIAlertAction(title: localizedCancel, style: .cancel, handler: nil)
		cancelAlert.addAction(yesAction)
		cancelAlert.addAction(noAction)
		present(cancelAlert, animated: true, completion: nil)
	}
}

// MARK: Helper Methods
private extension ConfigureRecordingTableViewController {
	func isDuplicate(_ title: String) -> Bool {
		
		return section.recordings.map { $0.title }.contains(title)
	}

	func showOKAlert(_ title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message ?? nil, preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Confirmation"), style: .default, handler: nil)
		alert.addAction(okAction)

		present(alert, animated: true, completion: nil)
	}
	
	func togglePicker(tagged tag: Int) {
		switch tag {
		case 111:
			projectPickerViewHidden = !projectPickerViewHidden
			projectPicker.isHidden = !projectPicker.isHidden
		case 222:
			sectionPickerViewHidden = !sectionPickerViewHidden
			sectionPicker.isHidden = !sectionPicker.isHidden
			
		default:
			break
		}
		
		if !projectPicker.isHidden {
			let selectedIndex = projects.index(of: project)!
			projectPicker.selectRow(selectedIndex, inComponent: 0, animated: true)
			projectDetailLabel.text = project.title
		}
		
		if !sectionPicker.isHidden {
			let selectedIndex = project.sections.contains(section) ? project.sections.sorted(by: {$0.title < $1.title}).index(of: section) : 0
			sectionPicker.selectRow(selectedIndex!, inComponent: 0, animated: true)
			sectionDetailLabel.text = section.title
		}
		
		tableView.beginUpdates()
		tableView.endUpdates()
		
		tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
	}
}

// MARK: UIPickerViewDelegate
extension ConfigureRecordingTableViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch pickerView.tag {
		case 111:
			guard projects.count > 0 else { return nil }
			return projects[row].title
		case 222:
			guard project.sections.count > 0 else { return nil }
			return project.sections.sorted(by: {$0.title < $1.title})[row].title
		default:
			return nil
		}
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		switch pickerView.tag {
		case 111:
			guard projects.count > 0 else { return }
			
			guard projects[row].sections.count > 0 else {
				let localizedString = NSLocalizedString("No sections in project", comment: "Title of alert when picking project without sections")
				let emptyProjectSectionsAlert = UIAlertController(title: localizedString, message: nil, preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
				emptyProjectSectionsAlert.addAction(okAction)
				present(emptyProjectSectionsAlert, animated: true, completion: nil)
				
				return
			}
			
			if project == projects[row] {
				return
			}
			
			project = projects[row]
			
			if project.sections.count == 0 {
				project = projects.first(where: { $0.sections.count > 0 })
			}
			
			projectDetailLabel.text = project.title
			section = project.sections.sorted(by: {$0.title < $1.title})[0]
			sectionDetailLabel.text = section.title
		case 222:
			guard project.sections.count > 0 else { return }

			section = project.sections.sorted(by: {$0.title < $1.title})[row]
			sectionDetailLabel.text = section.title
		default:
			break
		}
	}
}

// MARK: UIPickerViewDataSource
extension ConfigureRecordingTableViewController: UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch pickerView.tag {
		case 111:
			return projects.count
		case 222:
			return project.sections.count
		default:
			return 0
		}
	}
}

// FIXME: Clean up this class
class ConfigureRecordingTableViewController: UITableViewController {

	// MARK: @IBOutlets
	@IBOutlet weak var saveBarButton: UIBarButtonItem!
	@IBOutlet weak var recordingTitleTextField: UITextField! {
		didSet {
			recordingTitleTextField.adjustsFontSizeToFitWidth = true
		}
	}
	@IBOutlet weak var sectionDetailLabel: UILabel! {
		didSet {
			sectionDetailLabel.text = section.title
			sectionDetailLabel.adjustsFontSizeToFitWidth = true
		}
	}
	@IBOutlet weak var projectDetailLabel: UILabel! {
		didSet {
			projectDetailLabel.text = section.project.title
			projectDetailLabel.adjustsFontSizeToFitWidth = true
		}
	}
	@IBOutlet weak var projectPicker: UIPickerView! {
		didSet {
			projectPicker.delegate = self
			projectPicker.dataSource = self
			projectPicker.tag = 111
		}
	}
	@IBOutlet weak var sectionPicker: UIPickerView! {
		didSet {
			sectionPicker.delegate = self
			sectionPicker.dataSource = self
			sectionPicker.tag = 222
		}
	}

	// MARK: Properties
	fileprivate var audioPlayer: AudioPlayer! {
		didSet {
			audioPlayer.player.volume = 1.0
		}
	}
	fileprivate var pieFileManager = PIEFileManager()
	fileprivate var projectPickerViewHidden = true
	fileprivate var sectionPickerViewHidden = true
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	var section: Section!
	var project: Project!
	var recording: Recording!
	var projects = [Project]()

	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest() as! NSFetchRequest<Project>
		let sortDescriptor = NSSortDescriptor(key: #keyPath(Project.title), ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		do {
			projects = try self.coreDataStack.viewContext.fetch(fetchRequest)
		} catch {
			print(error.localizedDescription)
		}
		
		recordingTitleTextField.text = recording.title
		
		navigationItem.title = NSLocalizedString("Configure and Save Recording", comment: "Navigation bar title when configuring recording")
		
		let navigationItemLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
		navigationItemLabel.text = navigationItem.title
		navigationItemLabel.adjustsFontSizeToFitWidth = true
		navigationItemLabel.textColor = UIColor.white
		navigationItemLabel.textAlignment = .center
		navigationItemLabel.font = UIFont.boldSystemFont(ofSize: 16)
		navigationItem.titleView = navigationItemLabel

		projectPicker.isHidden = true
		sectionPicker.isHidden = true
		
		tableView.separatorStyle = .none
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (projectPickerViewHidden && indexPath.section == 1 && indexPath.row == 1) || (sectionPickerViewHidden && indexPath.section == 2 && indexPath.row == 1) {
			return 0
		} else {
			return super.tableView(tableView, heightForRowAt: indexPath)
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (1, 0):
			togglePicker(tagged: 111)
		case (2, 0):
			togglePicker(tagged: 222)
		default:
			break
		}
	}

	// MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if indexPath.section == 0 && indexPath.row == 0 {
			return nil
		}
		if (indexPath as NSIndexPath).section == 2 && project == nil {
			let alert = UIAlertController(
				title: NSLocalizedString("No Project", comment: "Warning when you try to select a section before selecting a project"),
				message: NSLocalizedString("You must choose a project, or create a new one.", comment: "Warning that you must choose a project or create a new one before selecting a section."),
				preferredStyle: .alert)
			let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Confirmation"), style: .default, handler: nil)
			alert.addAction(okAction)

			present(alert, animated: true, completion: nil)

			return nil
		}

		return indexPath
	}

	// MARK: UIScrollViewDelegate
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		recordingTitleTextField.resignFirstResponder()
	}

}
