//
//  ConfigureRecordingTableViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: Helper methods
private extension ConfigureRecordingTableViewController {
	func isDuplicate(_ title: String) -> Bool {

		guard let recordings = section.recordings.array as? [Recording] else {
			return false
		}

		return recordings.filter { $0.title == title }.count > 0
	}

	func showOKAlert(_ title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message ?? nil, preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Confirmation"), style: .default, handler: nil)
		alert.addAction(okAction)

		present(alert, animated: true, completion: nil)
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
			return (project.sections[row] as! Section).title
		default:
			return nil
		}
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch pickerView.tag {
		case 111:
			guard projects.count > 0 else { return }

			project = projects[row]
			projectDetailLabel.text = project.title

			if !project.sections.contains(section) {
				section = project.sections[0] as! Section
				sectionDetailLabel.text = section.title
			}
		case 222:
			guard project.sections.count > 0 else { return }

			if let section = project.sections[row] as? Section {
				sectionDetailLabel.text = section.title
			}
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

class ConfigureRecordingTableViewController: UITableViewController {

	// MARK: @IBOutlets
	@IBOutlet weak var saveBarButton: UIBarButtonItem!
	@IBOutlet weak var recordingTitleTextField: UITextField!
	@IBOutlet weak var sectionDetailLabel: UILabel! {
		didSet {
			sectionDetailLabel.text = section.title
		}
	}
	@IBOutlet weak var projectDetailLabel: UILabel! {
		didSet {
			projectDetailLabel.text = section.project.title
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
	fileprivate var audioPlayer: AudioPlayer!
	var section: Section!
	var project: Project!
	var recording: Recording!
	private var projectPickerViewHidden = true
	private var sectionPickerViewHidden = true
	var projects: [Project] {
		var projects = [Project]()
		let fetchRequest = Project.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]

		do {
			projects = try CoreDataStack.sharedInstance.managedContext.fetch(fetchRequest) as! [Project]
		} catch {
			print(error.localizedDescription)
		}

		return projects
	}

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		recordingTitleTextField.text = recording.title
		
		navigationItem.title = NSLocalizedString("Configure and Save Recording", comment: "Navigation bar title when configuring recording")
		
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
		label.text = navigationItem.title
		label.adjustsFontSizeToFitWidth = true
		label.textColor = UIColor.white
		label.textAlignment = .center
		navigationItem.titleView = label

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
			let selectedIndex = project.sections.contains(section) ? project.sections.index(of: section) : 0
			sectionPicker.selectRow(selectedIndex, inComponent: 0, animated: true)
			sectionDetailLabel.text = section.title
		}

		tableView.beginUpdates()
		tableView.endUpdates()

		tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
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

	// MARK: @IBActions
	@IBAction func save(_ sender: AnyObject) {
		guard let project = project, let section = section else { return }

		guard let newTitle = recordingTitleTextField.text, !isDuplicate(newTitle) else {
			showOKAlert(NSLocalizedString("Duplicate title!", comment: "The title is not unique in the project and section."), message: nil)
			return
		}

		// The audio file is already created, so we'll just rename it.
		PIEFileManager().rename(recording, from: recording.title, to: newTitle, section: section, project: project)
		recording.title = newTitle
		recording.section = section
		recording.project = project
		CoreDataStack.sharedInstance.saveContext()
		presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
	}

	@IBAction func cancel(_ sender: AnyObject) {
		// We'll notify the user if he/she tries to cancel the configuration of the recording.
		let localizedTitle = NSLocalizedString("Recording will be deleted. Procede?", comment: "Alert when user cancels the recording.")
		let cancelAlert = UIAlertController(title: localizedTitle, message: nil, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "OK", style: .default) { _ in
			PIEFileManager().delete(self.recording)
			CoreDataStack.sharedInstance.managedContext.delete(self.recording)
			CoreDataStack.sharedInstance.saveContext()

			self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
		}
		let localizedCancel = NSLocalizedString("Cancel", comment: "Cancelling configuration")
		let noAction = UIAlertAction(title: localizedCancel, style: .cancel, handler: nil)
		cancelAlert.addAction(yesAction)
		cancelAlert.addAction(noAction)
		present(cancelAlert, animated: true, completion: nil)
	}

	@IBAction func playAudio(_ sender: AnyObject) {
		audioPlayer = AudioPlayer(url: recording.url)
		audioPlayer.player.play()
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
