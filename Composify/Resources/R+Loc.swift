//
//  Strings.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import Foundation

// MARK: Multi-subject localizations

extension R.Loc {
    static let composify = NSLocalizedString(
        "app.title",
        comment: "The title of the application. Should not be localized, but is included for completeness sake."
    )
}

// MARK: Project localizations

extension R.Loc {
    static let addProject = NSLocalizedString(
        "library.menu.add-project.alert.title",
        comment: "Title of an alert appearing when user tries to add a project."
    )
    static let noProjects = NSLocalizedString(
        "library.empty-state.no-projects",
        comment: "Label appearing when the user has no projects."
    )
    static let projectTitle = NSLocalizedString(
        "library.menu.add-project.textfield.placeholder",
        comment: "Placeholder of textfield in alert appearing when user tries to add a project."
    )
    static func showProject(named name: String) -> String {
        return String.localizedStringWithFormat(NSLocalizedString(
            "library.menu.show-project.label",
            comment: "Title of button in menu for seeing a project."
        ), name)
    }

    static let deleteProejct = NSLocalizedString(
        "administrate-project.delete-button.title",
        comment: "Title of delete button in table view."
    )
}

// MARK: Section localizatios

extension R.Loc {
    static let addSection = NSLocalizedString(
        "administrate-project.tableview.cell.add-section.title",
        comment: "Title of cell that appears below all other sections in table view, next to a green button, indicating that it should add a new section when pressed."
    )
    static let noSections = NSLocalizedString(
        "library.empty-state.no-sections",
        comment: "Label appearing when the user has no sections in a project."
    )
    static let section = NSLocalizedString(
        "sections.section",
        comment: "Generic name for a new section"
    )
}

// MARK: Recording localizations

extension R.Loc {
    static let startRecording = NSLocalizedString(
        "library.record-button.start-recording.title",
        comment: "Title of button when user is not recording audio."
    )
    static let stopRecording = NSLocalizedString(
        "library.record-button.stop-recording.title",
        comment: "Title of button when user is recording audio."
    )
    static let recording = NSLocalizedString(
        "recordings.recording",
        comment: "Generic name for a new recording"
    )
}

// MARK: Generic localizations

extension R.Loc {
    static let cancel = NSLocalizedString(
        "general.cancel",
        comment: "Generic word for cancel."
    )
    static let edit = NSLocalizedString(
        "general.edit",
        comment: "Generic word for edit."
    )
    static let delete = NSLocalizedString(
        "general.delete",
        comment: "Generic word for delete."
    )
    static let save = NSLocalizedString(
        "general.save",
        comment: "Generic word for save."
    )
    static let administrate = NSLocalizedString(
        "general.administrate",
        comment: "Generic word for administrate."
    )
    static let ok = NSLocalizedString(
        "general.ok",
        comment: "Generic word for ok"
    )
}

// MARK: Menu localization

extension R.Loc {
    static let menu = NSLocalizedString(
        "library.menu.action-sheet.title",
        comment: "Title of menu when tapping the corresponding menu button in the navigation bar."
    )
    static let administrateProject = NSLocalizedString(
        "library.menu.administarte-project.label",
        comment: "Button in menu for administrating the current project."
    )
}

// MARK: Administrate Project localization

extension R.Loc {
    static let metaInformationHeader = NSLocalizedString(
        "administrate-project.section-titles.meta-information.label",
        comment: "Title of section for meta information in administrate project."
    )
    static let sectionsHeader = NSLocalizedString(
        "administrate-project.section-titles.sections.label",
        comment: "Title of section for project sections in administrate project."
    )
    static let dangerZoneHeader = NSLocalizedString(
        "administrate-project.section-titles.danger-zone.label",
        comment: "Title of section for the danger zone in administrate project."
    )
}

// MARK: Recordings view controller localization

extension R.Loc {
    static let missingRecordingAlertTitle = NSLocalizedString(
        "recordings.error.missing-recording.alert.title",
        comment: "Title when recording can't be found in the file system."
    )

    static let missingRecordingAlertMessage = NSLocalizedString(
        "recordings.error.missing-recording.alert.message",
        comment: "Message when recording can't be found in the file system."
    )

    static let unableToFindRecordingTitle = NSLocalizedString(
        "recordings.error.unable-to-find-recording.alert.title",
        comment: "Title when the audio player was unable to play the recording."
    )

    static let unableToFindRecordingMessage = NSLocalizedString(
        "recordings.error.unable-to-find-recording.alert.message",
        comment: "Message when the audio player was unable to play the recording."
    )

    static let unableToSaveObjectTitle = NSLocalizedString(
        "recordings.error.unable-to-save-recording.alert.title",
        comment: "Title when application was unable to save the recording."
    )

    static func unableToSaveObjectMessage(withTitle title: String) -> String {
        return String.localizedStringWithFormat(NSLocalizedString(
            "recordings.error.unable-to-save-recording.alert.message",
            comment: "Message when application was unable to save the recording."
        ), title)
    }

    static let unableToDeleteObjectTitle = NSLocalizedString(
        "recordings.error.unable-to-delete-object.alert.title",
        comment: "Title when trying to delete object from filesystem."
    )

    static func unableToDeleteObjectMessage(withTitle title: String) -> String {
        return String.localizedStringWithFormat(NSLocalizedString(
            "recordings.error.unable-to-delete-object.alert.message",
            comment: "Message when trying to delete object from filesystem."
        ), title)
    }

    static let unableToConfigureRecordingSessionTitle = NSLocalizedString(
        "recordings.error.unable-to-configure-recording-session.alert.title",
        comment: "Title when application is unable to configure a recording session."
    )

    static let unableToConfigureRecordingSessionMessage = NSLocalizedString(
        "recordings.error.unable-to-configure-recording-session.alert.message",
        comment: "Message when application is unable to configure a recording session."
    )
}
