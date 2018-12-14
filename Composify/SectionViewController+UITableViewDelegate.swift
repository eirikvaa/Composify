//
//  SectionViewController+UITableViewDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 21.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension SectionViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let edit = UITableViewRowAction(style: .default, title: .localized(.edit)) { (_, indexPath) in
            let edit = UIAlertController(title: .localized(.edit), message: nil, preferredStyle: .alert)

			edit.addTextField {
				let recording = self.section?.recordings[indexPath.row]
				$0.placeholder = recording?.title
				$0.autocapitalizationType = .words
			}

			let save = UIAlertAction(title: .localized(.save), style: .default, handler: { _ in
				let recording = self.section?.recordingIDs[indexPath.row].correspondingRecording
				if let title = edit.textFields?.first?.text, let recording = recording {
                    self.databaseService.rename(recording, to: title)
					self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.setEditing(false, animated: true)
				}
			})
			let cancel = UIAlertAction(title: .localized(.cancel), style: .default, handler: nil)

			edit.addAction(save)
			edit.addAction(cancel)

			self.present(edit, animated: true, completion: nil)
		}

		let delete = UITableViewRowAction(style: .destructive, title: .localized(.delete)) { (_, indexPath) in
			if let currentSection = self.section,
                let recording = currentSection.recordingIDs[indexPath.row].correspondingRecording {
                
                do {
                    try self.libraryViewController?.fileManager.delete(recording)
                } catch let errror as FileManagerError {
                    self.handleError(errror)
                } catch {
                    print(error.localizedDescription)
                }
                
                self.databaseService.delete(recording)
                self.libraryViewController?.updateUI()
			}
		}

		edit.backgroundColor = .mainColor
		delete.backgroundColor = .delete

		return [edit, delete]
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.reloadData()

		guard let recording = section?.recordingIDs[indexPath.row].correspondingRecording else {
			return
		}
        
        if currentlyPlayingRecording != nil {
            currentlyPlayingRecording = nil
            audioDefaultService?.stop()
        } else {
            do {
                audioDefaultService = try AudioPlayerServiceFactory.defaultService(withObject: recording)
            } catch {
                handleError(error)
            }
            
            audioDefaultService?.audioDidFinishBlock = { _ in
                self.currentlyPlayingRecording = nil
                self.libraryViewController?.updateUI()
            }
            
            currentlyPlayingRecording = recording
            audioDefaultService?.play()
        }
	}

	func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		setEditing(true, animated: true)
	}

	func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		setEditing(false, animated: true)
	}
}
