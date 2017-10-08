//
//  RecordingsTableViewDelegate.swift
//  Piece
//
//  Created by Eirik Vale Aase on 21.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingsTableViewDelegate: NSObject {
	var libraryViewController: LibraryViewController!
	var parentViewController: RecordingsViewController!
}

extension RecordingsTableViewDelegate: UITableViewDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let edit = UITableViewRowAction(style: .default, title: .localized(.edit)) { (rowAction, indexPath) in
			let edit = UIAlertController(title: .localized(.edit), message: nil, preferredStyle: .alert)

			edit.addTextField {
				let recording = self.parentViewController.section?.sortedRecordings[indexPath.row]
				$0.placeholder = recording?.title
				$0.autocapitalizationType = .words
			}

			let save = UIAlertAction(title: .localized(.save), style: .default, handler: { alertAction in
				let recording = self.parentViewController.section?.sortedRecordings[indexPath.row] // DRY!
				if let title = edit.textFields?.first?.text, let recording = recording {
					self.libraryViewController.pieFileManager.rename(recording, from: recording.title, to: title, section: nil, project: nil)
					recording.title = title
					self.libraryViewController.coreDataStack.saveContext()
					self.parentViewController.tableView.reloadData()
				}
			})
			let cancel = UIAlertAction(title: .localized(.cancel), style: .default, handler: nil)

			edit.addAction(save)
			edit.addAction(cancel)

			self.libraryViewController.present(edit, animated: true, completion: nil)
		}

		let delete = UITableViewRowAction(style: .destructive, title: .localized(.delete)) { (
				rowAction, indexPath) in
			if let currentSection = self.parentViewController.section {
				let recording = currentSection.sortedRecordings[indexPath.row]

				self.libraryViewController.pieFileManager.delete(recording)
				self.libraryViewController.coreDataStack.viewContext.delete(recording)
				self.libraryViewController.coreDataStack.saveContext()
                self.libraryViewController.setEmptyState()

				self.parentViewController.tableView.reloadData()
			}
		}

		edit.backgroundColor = Colors.edit
		delete.backgroundColor = Colors.delete

		return [edit, delete]
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.reloadData()

		guard let recording = parentViewController.section?.sortedRecordings[indexPath.row] else {
			return
		}
        
        if parentViewController.currentlyPlayingRecording != nil {
            parentViewController.currentlyPlayingRecording = nil
            parentViewController.audioPlayer?.player.stop()
        } else {
            parentViewController.audioPlayer = AudioPlayer(url: recording.url)
            parentViewController.currentlyPlayingRecording = recording
        }
	}

	func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		libraryViewController.setEditing(true, animated: true)
	}

	func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		libraryViewController.setEditing(false, animated: true)
	}
}

extension RecordingsTableViewDelegate: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		parentViewController.currentlyPlayingRecording = nil
		libraryViewController.shouldRefresh(projectCollectionView: false, sectionCollectionView: false, recordingsTableView: true)
	}
}
