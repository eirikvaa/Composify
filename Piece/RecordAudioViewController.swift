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
			recordAudioButton.layer.cornerRadius = 15
			recordAudioButton.titleLabel?.textAlignment = .center
		}
	}

	// MARK: Properties
	private var audioRecorder: AudioRecorder!
	var section: Section!
	var recording: Recording!

	// MARK: View controller life cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		let managedObjectContext = CoreDataStack.sharedInstance.managedContext
		let entityDescription = NSEntityDescription.entity(forEntityName: "Recording", in: managedObjectContext)

		if let entityDescription = entityDescription {
			if let recording = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext) as? Recording {
				recording.title = NSLocalizedString("MySong", comment: "Default title of recording")
				recording.dateRecorded = Date()
				recording.section = section
				recording.project = section.project
				recording.fileExtension = FileSystemExtensions.caf.rawValue
				self.recording = recording
				
				// This must go here because recording.url is not set before recording is created.
				audioRecorder = AudioRecorder(url: recording.url)
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
	@IBAction func cancelButton(_ sender: Any) {
		PIEFileManager().delete(recording)
		CoreDataStack.sharedInstance.persistentContainer.viewContext.delete(recording)
		CoreDataStack.sharedInstance.saveContext()
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func recordAudio(_ sender: AnyObject) {
		var recordButtonTitle = ""

		if audioRecorder.recorder.isRecording {
			audioRecorder.recorder.stop()
			recordButtonTitle = NSLocalizedString("Tap to Record", comment: "Title of record button before recording.")
			performSegue(withIdentifier: "configureRecording", sender: self)
			self.audioRecorder = nil
		} else {
			audioRecorder.recorder.record()
			recordButtonTitle = NSLocalizedString("Tap to Stop", comment: "Title of record button after starting to recording.")
		}

		recordAudioButton.setTitle(recordButtonTitle, for: .normal)
	}
}


