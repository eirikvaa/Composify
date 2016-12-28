//
//  ViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import AVFoundation

/**
`RecordAudioViewController` handles audio recording.
*/
class RecordAudioViewController: UIViewController {
	
	// MARK: Properties
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	fileprivate let pieFileManager = PIEFileManager()
	fileprivate var audioRecorder: AudioRecorder!
	var recording: Recording!
	var section: Section!
	
	// MARK: @IBOutlets
	@IBOutlet weak var recordAudioButton: UIButton! {
		didSet {
			recordAudioButton.layer.cornerRadius = 15
			recordAudioButton.titleLabel?.textAlignment = .center
		}
	}

	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let recording = Recording.init(with: NSLocalizedString("MySong", comment: ""), section: section, project: section.project, fileExtension: .caf, insertIntoManagedObjectContext: self.coreDataStack.viewContext) {
			audioRecorder = AudioRecorder(url: recording.url)
			self.recording = recording
			
			if audioRecorder.askForPermissions() {
				recordAudioButton.isEnabled = true
			} else {
				showRecorderDeniedAccessAlert()
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
}

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
			recordButtonTitle = NSLocalizedString("Start recording", comment: "")
			performSegue(withIdentifier: "configureRecording", sender: self)
			self.audioRecorder = nil
		} else {
			audioRecorder.recorder.record()
			recordButtonTitle = NSLocalizedString("Stop recording", comment: "")
		}
		
		recordAudioButton.setTitle(recordButtonTitle, for: .normal)
	}
}

// MARK: Helper Methods
private extension RecordAudioViewController {
	func showRecorderDeniedAccessAlert() {
		let denied = UIAlertController(title: NSLocalizedString("Permission denied", comment: ""), message: NSLocalizedString("You have denied Piece access to the microphone. Allow access in the privacy settings.", comment: ""), preferredStyle: .alert)
		
		let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
		denied.addAction(ok)
		
		recordAudioButton.isEnabled = false
		
		present(denied, animated: true, completion: nil)
	}
}

