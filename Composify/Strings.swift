//
//  Strings.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import Foundation

// MARK: Multi-subject localizations

extension Localizable {
    static let composify = Localizable(NSLocalizedString("app.title", comment: "The title of the application. Should not be localized, but is included for completeness sake."))
}

// MARK: Project localizations

extension Localizable {
    static let addProject = Localizable(NSLocalizedString("library.menu.add-project.alert.title", comment: "Title of an alert appearing when user tries to add a project."))
    static let noProjects = Localizable(NSLocalizedString("library.empty-state.no-projects", comment: "Label appearing when the user has no projects."))
    static let projectTitle = Localizable(NSLocalizedString("library.menu.add-project.textfield.placeholder", comment: "Placeholder of textfield in alert appearing when user tries to add a project."))
    static let showProject = Localizable(NSLocalizedString("library.menu.show-project.label", comment: "Title of button in menu for seeing a project."))
    static let deleteProejct = Localizable(NSLocalizedString("administrate-project.delete-button.title", comment: "Title of delete button in table view."))
}

// MARK: Section localizatios

extension Localizable {
    static let addSection = Localizable(NSLocalizedString("administrate-project.tableview.cell.add-section.title", comment: "Title of cell that appears below all other sections in table view, next to a green button, indicating that it should add a new section when pressed."))
    static let noSections = Localizable(NSLocalizedString("library.empty-state.no-sections", comment: "Label appearing when the user has no sections in a project."))
}

// MARK: Recording localizations

extension Localizable {
    static let startRecording = Localizable(NSLocalizedString("library.record-button.start-recording.title", comment: "Title of button when user is not recording audio."))
    static let stopRecording = Localizable(NSLocalizedString("library.record-button.stop-recording.title", comment: "Title of button when user is recording audio."))
}

// MARK: Generic localizations

extension Localizable {
    static let cancel = Localizable(NSLocalizedString("general.cancel", comment: "Generic word for cancel."))
    static let edit = Localizable(NSLocalizedString("general.edit", comment: "Generic word for edit."))
    static let delete = Localizable(NSLocalizedString("general.delete", comment: "Generic word for delete."))
    static let save = Localizable(NSLocalizedString("general.save", comment: "Generic word for save."))
    static let administrate = Localizable(NSLocalizedString("general.administrate", comment: "Generic word for administrate."))
}

// MARK: Menu localization

extension Localizable {
    static let menu = Localizable(NSLocalizedString("library.menu.action-sheet.title", comment: "Title of menu when tapping the corresponding menu button in the navigation bar."))
    static let administrateProject = Localizable(NSLocalizedString("library.menu.administarte-project.label", comment: "Button in menu for administrating the current project."))
}

// MARK: Administrate Project localization

extension Localizable {
    static let metaInformationHeader = Localizable(NSLocalizedString("administrate-project.section-titles.meta-information.label", comment: "Title of section for meta information in administrate project."))
    static let sectionsHeader = Localizable(NSLocalizedString("administrate-project.section-titles.sections.label", comment: "Title of section for project sections in administrate project."))
    static let dangerZoneHeader = Localizable(NSLocalizedString("administrate-project.section-titles.danger-zone.label", comment: "Title of section for the danger zone in administrate project."))
}
