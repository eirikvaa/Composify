//
//  RecordingsTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingsTableViewDataSource: NSObject {
	var libraryViewController: LibraryViewController!
	var parentViewController: RecordingsViewController!
	var audioPlayer: AudioPlayer?
}

// MARK: UITableViewDataSource

extension RecordingsTableViewDataSource: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recordings = parentViewController.section?.recordingIDs else { return 0 }
        return recordings.count
	}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard parentViewController.section?.isInvalidated == false else { return 0 }
        guard let recordings = parentViewController.section?.recordingIDs else { return 0 }
        return recordings.hasElements ? 1 : 0
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Strings.Cells.recordingCell, for: indexPath) as? RecordingTableViewCell else {
            return UITableViewCell()
        }
        
        cell.contentView.isUserInteractionEnabled = false
        cell.selectionStyle = .none
        
        let recording = parentViewController.section?.recordingIDs[indexPath.row].correspondingRecording
        let isCurrentlyPlayingRecording = parentViewController.currentlyPlayingRecording == recording
        
        cell.titleLabel.font = .preferredFont(forTextStyle: .body)
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        cell.titleLabel.text = recording?.title.count ?? 0 > 0 ? recording?.title : recording?.dateRecorded.description
		cell.playButton.alpha = 1
        cell.playButton.setImage(isCurrentlyPlayingRecording ? Images.pause : Images.play, for: .normal)
        
		return cell
	}

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            libraryViewController.tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
}
