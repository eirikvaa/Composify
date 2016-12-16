//
//  ViewController.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

/**
`RecordAudioViewController` handles audio recording.
*/
class RecordAudioViewController: UIViewController {

	// MARK: @IBOutlets
	@IBOutlet weak var recordAudioButton: UIButton! {
		didSet {
			recordAudioButton.layer.cornerRadius = 15
			recordAudioButton.titleLabel?.textAlignment = .center
		}
	}

	// MARK: Properties
	fileprivate var coreDataStack = CoreDataStack.sharedInstance
	fileprivate let pieFileManager = PIEFileManager()
	fileprivate var audioRecorder: AudioRecorder!
	var recording: Recording!
	var section: Section!

	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let recording = Recording.init(with: "MySong".localized, section: section, project: section.project, fileExtension: .caf, insertIntoManagedObjectContext: self.coreDataStack.viewContext) {
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

// MARK: Helper Methods
private extension RecordAudioViewController {
	func showRecorderDeniedAccessAlert() {
		let deniedAlert = UIAlertController(title: "Permission denied".localized,
		                                    message: "You have denied Piece access to the microphone. Allow access in the privacy settings.".localized,
		                                    preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
		deniedAlert.addAction(okAction)
		
		recordAudioButton.isEnabled = false
		
		present(deniedAlert, animated: true, completion: nil)
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
			recordButtonTitle = "Start recording".localized
			performSegue(withIdentifier: "configureRecording", sender: self)
			self.audioRecorder = nil
		} else {
			audioRecorder.recorder.record()
			recordButtonTitle = "Stop recording".localized
		}
		
		recordAudioButton.setTitle(recordButtonTitle, for: .normal)
	}
}

