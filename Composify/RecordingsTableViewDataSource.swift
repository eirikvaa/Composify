//
//  RecordingsTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class RecordingsTableViewDataSource: NSObject {
	var libraryViewController: LibraryViewController!
	var parentViewController: RecordingsViewController!
	var audioPlayer: AudioPlayer?
}

// MARK: UITableViewDataSource

extension RecordingsTableViewDataSource: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return parentViewController.section?.recordings.count ?? 0
	}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (libraryViewController.currentSection?.recordings.count ?? 0) > 0 ? 1 : 0
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Strings.Cells.recordingCell, for: indexPath) as! RecordingTableViewCell
        cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleLabel.adjustsFontForContentSizeCategory = true

		cell.contentView.isUserInteractionEnabled = false
		cell.selectionStyle = .none
		cell.playButton.alpha = 1

		let recording = parentViewController.section?.recordings.sorted()[indexPath.row]
		
		if parentViewController.currentlyPlayingRecording == recording {
			cell.playButton.setImage(Images.pause, for: .normal)
		} else {
			cell.playButton.setImage(Images.play, for: .normal)
		}

		if let recording = recording {
			cell.titleLabel.text = recording.title
		}

		return cell
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .insert {
			libraryViewController.recordingsTableView.insertRows(at: [indexPath], with: .fade)
		}
	}
}
