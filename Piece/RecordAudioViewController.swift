//
//  ViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

class RecordAudioViewController: UIViewController {

	// MARK: @IBOutlets
	@IBOutlet weak var recordAudioButton: UIButton! {
		didSet {
			recordAudioButton.layer.cornerRadius = 90
			recordAudioButton.titleLabel?.textAlignment = .center
		}
	}

	// MARK: Properties
	private var audioRecorder: AudioRecorder?
	var section: Section!
	var recording: Recording!

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		let managedObjectContext = CoreDataStack.sharedInstance.managedContext
		let entityDescription = NSEntityDescription.entity(forEntityName: "Recording", in: managedObjectContext)

		if let entityDescription = entityDescription {
			if let recording = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext) as? Recording {
				recording.title = "MySong"
				recording.dateRecorded = Date()
				recording.section = section
				recording.project = section.project
				recording.fileExtension = FileSystemExtensions.caf.rawValue
				audioRecorder = audioRecorder ?? AudioRecorder(url: recording.fileSystemURL)
				self.recording = recording
			}
		}
	}

	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "configureRecording" {
			if let navigationController = segue.destination as? UINavigationController,
				let configureRecordingTVC = navigationController.viewControllers.first as? ConfigureRecordingTableViewController {
					configureRecordingTVC.recording = recording
					configureRecordingTVC.project = recording.project
					configureRecordingTVC.section = recording.section
			}
		}
	}

	// MARK: @IBActions
	@IBAction func recordAudio(_ sender: AnyObject) {
		guard let audioRecorder = audioRecorder, let recorder = audioRecorder.recorder else { return }

		var recordButtonTitle = ""

		if recorder.isRecording {
			recorder.stop()
			recordButtonTitle = NSLocalizedString("Tap to Record", comment: "Title of record button before recording.")
			performSegue(withIdentifier: "configureRecording", sender: self)
			self.audioRecorder = nil
		} else {
			recorder.record()
			recordButtonTitle = NSLocalizedString("Tap to Stop", comment: "Title of record button after starting to recording.")
		}

		recordAudioButton.setTitle(recordButtonTitle, for: .normal)
	}
}


