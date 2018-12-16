//
//  SectionViewController+UITableViewDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

// MARK: UITableViewDataSource

extension SectionViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section?.recordingIDs.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#function)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.Cells.libraryRecordingCell, for: indexPath) as? RecordingTableViewCell else {
            return UITableViewCell()
        }
        
        cell.contentView.isUserInteractionEnabled = false
        cell.selectionStyle = .none
        
        let recording = section?.recordingIDs[indexPath.row].correspondingRecording
        let isCurrentlyPlayingRecording = currentlyPlayingRecording?.id == recording?.id
        
        cell.titleLabel.font = .preferredFont(forTextStyle: .body)
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        
        // If a recording has just been created, it's title is defaulted to a zero-string,
        // so the date of recording is used instead.
        cell.titleLabel.text = recording?.title.count ?? 0 > 0 ? recording?.title : recording?.dateRecorded.description
		cell.playButton.alpha = 1
        cell.playButton.setImage(isCurrentlyPlayingRecording ? R.Images.pause : R.Images.play, for: .normal)
        
		return cell
	}

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
}
