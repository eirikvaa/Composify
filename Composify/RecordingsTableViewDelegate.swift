//
//  RecordingsTableViewDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 21.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class RecordingsTableViewDelegate: NSObject {
	var libraryViewController: LibraryViewController!
	var parentViewController: RecordingsViewController!
    private var realmStore = RealmStore.shared
}

extension RecordingsTableViewDelegate: UITableViewDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let edit = UITableViewRowAction(style: .default, title: .localized(.edit)) { (rowAction, indexPath) in
			let edit = UIAlertController(title: .localized(.edit), message: nil, preferredStyle: .alert)

			edit.addTextField {
				let recording = self.parentViewController.section?.recordings[indexPath.row]
				$0.placeholder = recording?.title
				$0.autocapitalizationType = .words
			}

			let save = UIAlertAction(title: .localized(.save), style: .default, handler: { alertAction in
				let recording = self.parentViewController.section?.recordings[indexPath.row]
				if let title = edit.textFields?.first?.text, let recording = recording {
					self.libraryViewController.fileManager.rename(recording, from: recording.title, to: title, section: nil, project: nil)
					self.realmStore.rename(recording, to: title)
					self.parentViewController.tableView.reloadRows(at: [indexPath], with: .automatic)
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
				let recording = currentSection.recordings[indexPath.row]

				self.libraryViewController.fileManager.delete(recording)
                self.realmStore.delete(recording)
                self.libraryViewController.updateUI()
			}
		}

		edit.backgroundColor = Colors.edit
		delete.backgroundColor = Colors.delete

		return [edit, delete]
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.reloadData()

		guard let recording = parentViewController.section?.recordings[indexPath.row] else {
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
		libraryViewController.updateUI()
	}
}
