//
//  SectionViewController+UITableViewDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 21.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension SectionViewController: UITableViewDelegate {
    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recording = section.recordings[indexPath.row]

        let edit = UIContextualAction(
            style: .normal,
            title: R.Loc.edit
        ) { _, _, _ in
            let edit = UIAlertController(title: R.Loc.edit, message: nil, preferredStyle: .alert)

            edit.addTextField {
                $0.placeholder = recording.title
                $0.autocapitalizationType = .words
            }

            let save = UIAlertAction(title: R.Loc.save, style: .default, handler: { _ in
                let textFieldText = edit.textFields?.first?.text
                if let title = textFieldText {
                    self.databaseService.rename(recording, to: title)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.libraryViewController?.setEditing(false, animated: true)
                }
            })
            let cancel = UIAlertAction(title: R.Loc.cancel, style: .cancel, handler: nil)

            edit.addAction(save)
            edit.addAction(cancel)

            self.present(edit, animated: true, completion: nil)
        }

        let delete = UIContextualAction(style: .destructive, title: R.Loc.delete) { _, _, _ in
            let confirmation = UIAlertController.createConfirmationAlert(
                title: R.Loc.deleteRecordingConfirmationAlertTitle,
                message: R.Loc.deleteRecordingConfirmationAlertMessage,
                completionHandler: { _ in
                    self.libraryViewController?.setEditing(false, animated: true)
                    FileManager.default.deleteRecording(recording)
                    self.databaseService.delete(recording)
                    self.libraryViewController?.updateUI()
                }
            )

            self.present(confirmation, animated: true)
        }

        let export = UIContextualAction(style: .normal, title: R.Loc.export) { _, _, _ in
            let url: [Any] = [recording.url]
            let activityVC = UIActivityViewController(activityItems: url, applicationActivities: nil)
            self.present(activityVC, animated: true)
        }

        edit.backgroundColor = R.Colors.eucalyptus
        delete.backgroundColor = R.Colors.carminPink
        export.backgroundColor = R.Colors.blueDeFrance

        return UISwipeActionsConfiguration(actions: [edit, export, delete])
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
