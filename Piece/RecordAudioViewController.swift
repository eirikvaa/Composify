//
//  ViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

// MARK: @IBActions
private extension RecordAudioViewController {
	@objc @IBAction func cancelButton(_ sender: Any) {
		self.pieFileManager.delete(recording)
		self.coreDataStack.viewContext.delete(recording)
		self.coreDataStack.saveContext()
		dismiss(animated: true, completion: nil)
	}
	
	@objc @IBAction func recordAudio(_ sender: AnyObject) {
		var recordButtonTitle = ""
		
		if audioRecorder.recorder.isRecording {
			audioRecorder.recorder.stop()
			recordButtonTitle = NSLocalizedString("Start recording", comment: "Title of record button before recording.")
			performSegue(withIdentifier: "configureRecording", sender: self)
			self.audioRecorder = nil
		} else {
			audioRecorder.recorder.record()
			recordButtonTitle = NSLocalizedString("Stop recording", comment: "Title of record button after starting to recording.")
		}
		
		recordAudioButton.setTitle(recordButtonTitle, for: .normal)
	}
}

class RecordAudioViewController: UIViewController {

	// MARK: @IBOutlets
	@IBOutlet weak var recordAudioButton: UIButton! {
		didSet {
			recordAudioButton.layer.cornerRadius = 15
			recordAudioButton.titleLabel?.textAlignment = .center
		}
	}

	// MARK: Properties
	fileprivate var audioRecorder: AudioRecorder!
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	fileprivate let pieFileManager = PIEFileManager()
	var section: Section!
	var recording: Recording!

	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		if let recording = NSEntityDescription.insertNewObject(forEntityName: "Recording", into: self.coreDataStack.viewContext) as? Recording {
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

	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "configureRecording" {
			if let navigationController = segue.destination as? UINavigationController, let configureRecordingTVC = navigationController.viewControllers.first as? ConfigureRecordingTableViewController {
					configureRecordingTVC.recording = recording
					configureRecordingTVC.project = recording.project
					configureRecordingTVC.section = recording.section
			}
		}
	}
}


