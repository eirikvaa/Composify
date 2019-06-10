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

        let recordingId = section.recordingIDs[indexPath.row]
        let recording: Recording? = recordingId.correspondingComposifyObject()
        let isCurrentlyPlayingRecording = currentlyPlayingRecording?.id == recording?.id

        // If a recording has just been created, it's title is defaulted to a zero-string,
        // so the date of recording is used instead.
        let hasTitle = recording?.title.hasPositiveCharacterCount ?? false
        let title = hasTitle ? recording?.title : String(describing: recording?.dateCreated.description)
        cell.setTitle(title)

        // For now: Image must come after title because I set accessbility after image is set
        let image = isCurrentlyPlayingRecording ? R.Images.pause : R.Images.play
        cell.setImage(image)

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
}
