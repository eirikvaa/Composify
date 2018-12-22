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
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return section.recordingIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.Cells.libraryRecordingCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? RecordingTableViewCell else {
            return UITableViewCell()
        }

        let recording: Recording? = section.recordingIDs[indexPath.row].correspondingComposifyObject()
        let isCurrentlyPlayingRecording = currentlyPlayingRecording?.id == recording?.id

        // If a recording has just been created, it's title is defaulted to a zero-string,
        // so the date of recording is used instead.
        let hasTitle = recording?.title.hasPositiveCharacterCount ?? false
        cell.titleLabel.text = hasTitle ? recording?.title : recording?.dateCreated.description
        cell.playButton.setImage(isCurrentlyPlayingRecording ? R.Images.pause : R.Images.play, for: .normal)

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
}
