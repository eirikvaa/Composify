//
//  SectionViewController+UITableViewDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 21.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension SectionViewController: UITableViewDelegate {
    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .default, title: R.Loc.edit) { _, indexPath in
            let edit = UIAlertController(title: R.Loc.edit, message: nil, preferredStyle: .alert)

            edit.addTextField {
                let recording = self.section.recordings[indexPath.row]
                $0.placeholder = recording.title
                $0.autocapitalizationType = .words
            }

            let save = UIAlertAction(title: R.Loc.save, style: .default, handler: { _ in
                let recording: Recording? = self.section.recordingIDs[indexPath.row].correspondingComposifyObject()
                if let title = edit.textFields?.first?.text, let recording = recording {
                    self.databaseService.rename(recording, to: title)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.setEditing(false, animated: true)
                }
            })
            let cancel = UIAlertAction(title: R.Loc.cancel, style: .default, handler: nil)

            edit.addAction(save)
            edit.addAction(cancel)

            self.present(edit, animated: true, completion: nil)
        }

        let delete = UITableViewRowAction(style: .destructive, title: R.Loc.delete) { _, indexPath in
            guard let recording: Recording = self.section.recordingIDs[indexPath.row].correspondingComposifyObject() else {
                return
            }

            do {
                try self.libraryViewController?.fileManager.delete(recording)
            } catch let FileManagerError.unableToDeleteObject(object) {
                let objectTitle = object.getTitle() ?? ""
                let title = R.Loc.unableToSaveObjectTitle
                let message = R.Loc.unableToSaveObjectMessage(withTitle: objectTitle)
                let alert = UIAlertController.createErrorAlert(title: title, message: message)
                self.libraryViewController?.present(alert, animated: true)
            } catch {
                print(error.localizedDescription)
            }

            self.databaseService.delete(recording)
            self.libraryViewController?.updateUI()
        }

        let export = UITableViewRowAction(style: .default, title: R.Loc.export) { _, indexPath in
            let url: [Any] = [self.section.recordings[indexPath.row].url]
            let activityVC = UIActivityViewController(activityItems: url, applicationActivities: nil)
            self.present(activityVC, animated: true)
        }

        edit.backgroundColor = R.Colors.mainColor
        delete.backgroundColor = R.Colors.delete

        return [edit, delete, export]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()

        guard let recording: Recording = section.recordingIDs[indexPath.row].correspondingComposifyObject() else {
            return
        }

        if currentlyPlayingRecording != nil {
            currentlyPlayingRecording = nil
            audioDefaultService?.stop()
        } else {
            do {
                audioDefaultService = try AudioPlayerServiceFactory.defaultService(withObject: recording)
            } catch AudioPlayerServiceError.unableToFindPlayable {
                let title = R.Loc.unableToFindRecordingTitle
                let message = R.Loc.unableToFindRecordingMessage
                let alert = UIAlertController.createErrorAlert(title: title, message: message)
                libraryViewController?.present(alert, animated: true)
            } catch AudioPlayerServiceError.unableToConfigurePlayingSession {
                let title = R.Loc.missingRecordingAlertTitle
                let message = R.Loc.missingRecordingAlertMessage
                let alert = UIAlertController.createErrorAlert(title: title, message: message)
                libraryViewController?.present(alert, animated: true)
            } catch {
                print(error.localizedDescription)
            }

            audioDefaultService?.audioDidFinishBlock = { _ in
                self.currentlyPlayingRecording = nil
                self.libraryViewController?.updateUI()
            }

            currentlyPlayingRecording = recording
            audioDefaultService?.play()
        }
    }

    func tableView(_: UITableView, willBeginEditingRowAt _: IndexPath) {
        setEditing(true, animated: true)
    }

    func tableView(_: UITableView, didEndEditingRowAt _: IndexPath?) {
        setEditing(false, animated: true)
    }
}
