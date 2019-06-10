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
    static let settings = NSLocalizedString(
        "app.settings",
        comment: "Settings"
    )
}

// MARK: Onboarding

extension R.Loc {
    static let onboardingSkipButtonTitle = NSLocalizedString(
        "onboarding.skipButton.title",
        comment: "Title of skip button"
    )
    static let onboardingNextButtonTitleNext = NSLocalizedString(
        "onboarding.next-button-title.next",
        comment: "Next button title when not at the last page"
    )
    static let onboardingNextButtonTitleDismiss = NSLocalizedString(
        "onboarding.next-button-title.dismiss",
        comment: "Next button title when at the last page"
    )
    static let onboardingPage1 = NSLocalizedString(
        "onboarding.page1",
        comment: "onboarding.page1"
    )
    static let onboardingPage2 = NSLocalizedString(
        "onboarding.page2",
        comment: "onboarding.page2"
    )
    static let onboardingPage3 = NSLocalizedString(
        "onboarding.page3",
        comment: "onboarding.page3"
    )
    static let onboardingPage4 = NSLocalizedString(
        "onboarding.page4",
        comment: "onboarding.page4"
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
        return String.localizedStringWithFormat(
            NSLocalizedString(
                "library.menu.show-project.label",
                comment: "Title of button in menu for seeing a project."
            ), name
        )
    }

    static let deleteProejct = NSLocalizedString(
        "administrate-project.delete-button.title",
        comment: "Title of delete button in table view."
    )

    static let deleteProjectConfirmationAlertTitle = NSLocalizedString(
        "administrate.delete-project.confirmation.alert.title",
        comment: "Confirmation title when deleting section"
    )

    static let deleteProjectConfirmationAlertMessage = NSLocalizedString(
        "administrate.delete-project.confirmation.alert.message",
        comment: "Confirmation message when deleting section"
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

    static let deleteSectionConfirmationAlertTitle = NSLocalizedString(
        "administrate.delete-section.confirmation.alert.title",
        comment: "Confirmation title when deleting section"
    )

    static let deleteSectionConfirmationAlertMessage = NSLocalizedString(
        "administrate.delete-section.confirmation.alert.message",
        comment: "Confirmation message when deleting section"
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

    static let deleteRecordingConfirmationAlertTitle = NSLocalizedString(
        "library.delete-recording.confirmation.alert.title",
        comment: "Confirmation title when deleting recording"
    )

    static let deleteRecordingConfirmationAlertMessage = NSLocalizedString(
        "library.delete-recording.confirmation.alert.message",
        comment: "Confirmation message when deleting recording"
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
    static let export = NSLocalizedString(
        "general.export",
        comment: "Generic word for export"
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
        return String.localizedStringWithFormat(
            NSLocalizedString(
                "recordings.error.unable-to-save-recording.alert.message",
                comment: "Message when application was unable to save the recording."
            ), title
        )
    }

    static let unableToDeleteObjectTitle = NSLocalizedString(
        "recordings.error.unable-to-delete-object.alert.title",
        comment: "Title when trying to delete object from filesystem."
    )

    static func unableToDeleteObjectMessage(withTitle title: String) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString(
                "recordings.error.unable-to-delete-object.alert.message",
                comment: "Message when trying to delete object from filesystem."
            ), title
        )
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

// MARK: Microphone permissions

extension R.Loc {
    static let deniedMicrophoneAccessGoToSettingsAlertTitle = NSLocalizedString(
        "microphone-access.denied.show-settings-alert.title",
        comment: "Alert title when user has denied access to microphone"
    )

    static let deniedMicrophoneAccessGoToSettingsAlertTessage = NSLocalizedString(
        "microphone-access.denied.show-settings-alert.message",
        comment: "Alert message when user has denied access to microphone"
    )
}

// MARK: Accessibility

extension R.Loc {
    static let menuChooseProjectAccHint = NSLocalizedString(
        "menu.choose-project.acc.hint",
        comment: "Accessibility hint when choosing project in menu"
    )

    static let menuChooseProjectAccLabel = NSLocalizedString(
        "menu.choose-project.acc.label",
        comment: "Accessibility label when choosing project in menu"
    )

    static let menuBarButtonAccHint = NSLocalizedString(
        "menu-bar-button.acc.hint",
        comment: "Accessibility hint for menu bar button"
    )

    static let libraryNavigationItemAccLabel = NSLocalizedString("library.nav-item.acc.label", comment: "Accessibility label for library navigation item")

    static let libraryRecordAudioButtonAccLabel = NSLocalizedString(
        "library.record-audio-button.acc.label",
        comment: "Accessibility label for library record audio button"
    )

    static let libraryRecordAudioButtonAccStartRecordingHint = NSLocalizedString(
        "library.record-audio-button.acc.start-recording.hint",
        comment: "Accessibility hint when able to start recording"
    )

    static let libraryRecordAudioButtonAccStopRecordingHint = NSLocalizedString(
        "library.record-audio-button.acc.stop-recording.hint",
        comment: "Accessibility hint when able to stop recording"
    )

    static let libraryCollectionViewCellAccLabel = NSLocalizedString(
        "library.collection.cell.acc.label",
        comment: "Accessibility label for library collection view cell"
    )

    static let libraryCollectionViewCellAccHint = NSLocalizedString(
        "library.collection.cell.acc.hint",
        comment: "Accessibility hint for library collection view cell"
    )

    static let recordingCellPlayButtonAccLabel = NSLocalizedString(
        "recording-cell.play-button.acc.label",
        comment: "Accessibility label for recording cell play button"
    )

    static let recordingCellPlayButtonCanPlayAccValue = NSLocalizedString(
        "recording-cell.play-button.can-play.acc.value",
        comment: "Accessibility value for recording cell play button when can play"
    )

    static let recordingCellPlayButtonCanPauseAccValue = NSLocalizedString(
        "recording-cell.play-button.can-pause.acc.value",
        comment: "Accessibility value for recording cell play button when can pause"
    )

    static let recordingCellPlayButtonAccHint = NSLocalizedString(
        "recording-cell.play-button.acc.hint",
        comment: "Accessibility hint for recording cell play button"
    )

    static let recordingCellTitleLabelAcclabel = NSLocalizedString(
        "recording-cell.title-label.acc.label",
        comment: "Accessibility label for recording cell title label"
    )
    static let errorViewControllerLabelAccLabel = NSLocalizedString(
        "error-view-controller.label.acc.label",
        comment: "Accessibility label for error view controller label"
    )
    static let buttonTableViewCellAccLabel = NSLocalizedString(
        "button-table-view-cell.acc.label",
        comment: "Accessibility label for button table view cell"
    )

    static let buttonTableViewCellAccHint = NSLocalizedString(
        "button-table-view-cell.acc.hint",
        comment: "Accessibility hint for button table view cell"
    )
    static let textFieldTableViewCellAccLabel = NSLocalizedString(
        "textfield-table-view-cell.acc.label",
        comment: "Accessibility label for textfield table view cell"
    )

    static let onboardingNextButtonAccLabel = NSLocalizedString(
        "onboarding.next-button.acc.label",
        comment: "Accessibility label for onboarding next button"
    )

    static let onboardingNextButtonAccHint = NSLocalizedString(
        "onboarding.next-button.acc.hint",
        comment: "Accessibility hint for onboarding next button"
    )

    static let onboardingSkipButtonAccLabel = NSLocalizedString(
        "onboarding.skip-button.acc.label",
        comment: "Accessibility label for onboarding skip button"
    )

    static let onboardingSkipButtonAccHint = NSLocalizedString(
        "onboarding.skip-button.acc.hint",
        comment: "Accessibility hint for onboarding skip button"
    )

    static let onboardingBackgroundImage0AccLabel = NSLocalizedString(
        "onboarding.background-image-0.acc.label",
        comment: "Accessibility label for onboarding bacground image 0"
    )

    static let onboardingBackgroundImage1AccLabel = NSLocalizedString(
        "onboarding.background-image-1.acc.label",
        comment: "Accessibility label for onboarding bacground image 1"
    )

    static let onboardingBackgroundImage2AccLabel = NSLocalizedString(
        "onboarding.background-image-2.acc.label",
        comment: "Accessibility label for onboarding bacground image 2"
    )

    static let onboardingBackgroundImage3AccLabel = NSLocalizedString(
        "onboarding.background-image-3.acc.label",
        comment: "Accessibility label for onboarding background image 3"
    )
    static let onboardingBackgroundImageAccLabel = NSLocalizedString(
        "onboarding.background-image.acc.label",
        comment: "Accessibility label for onboarding background image"
    )
}
