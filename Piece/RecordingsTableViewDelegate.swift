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
	var audioPlayer: AudioPlayer?
}

extension RecordingsTableViewDelegate: UITableViewDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let edit = UITableViewRowAction(style: .default, title: NSLocalizedString("Edit", comment: "")) { (rowAction, indexPath) in
			let edit = UIAlertController(title: NSLocalizedString("Edit", comment: ""), message: nil, preferredStyle: .alert)

			edit.addTextField {
				let recording = self.parentViewController.section?.sortedRecordings[indexPath.row]
				$0.placeholder = recording?.title
				$0.autocapitalizationType = .words
			}

			let save = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { alertAction in
				let recording = self.parentViewController.section?.sortedRecordings[indexPath.row] // DRY!
				if let title = edit.textFields?.first?.text, let recording = recording {
					self.libraryViewController.pieFileManager.rename(recording, from: recording.title, to: title, section: nil, project: nil)
					recording.title = title
					self.libraryViewController.coreDataStack.saveContext()
					//self.libraryViewController.recordingsTableView.reloadRows(at: [indexPath], with: .fade)
					self.parentViewController.tableView.reloadData()
				}
			})
			let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)

			edit.addAction(save)
			edit.addAction(cancel)

			self.libraryViewController.present(edit, animated: true, completion: nil)
		}

		let delete = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (
				rowAction, indexPath) in
			if let currentSection = self.parentViewController.section {
				let recording = currentSection.sortedRecordings[indexPath.row]

				self.libraryViewController.pieFileManager.delete(recording)
				self.libraryViewController.coreDataStack.viewContext.delete(recording)
				self.libraryViewController.coreDataStack.saveContext()

				self.parentViewController.tableView.reloadData()
			}
		}

		edit.backgroundColor = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
		delete.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)

		return [edit, delete]
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.reloadData()

		guard let recording = parentViewController.section?.sortedRecordings[indexPath.row] else {
			return
		}

		audioPlayer = AudioPlayer(url: recording.url)
		audioPlayer?.player.delegate = self
		audioPlayer?.player.play()
		

		let cell = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
		cell.playButton.setImage(UIImage(named: "Pause"), for: .normal)
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
		
		libraryViewController.shouldRefresh(projectCollectionView: false, sectionCollectionView: false, recordingsTableView: true)
	}
}
