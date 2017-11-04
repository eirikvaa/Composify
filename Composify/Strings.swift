//
//  Strings.swift
//  Piece
//
//  Created by Eirik Vale Aase on 08.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import Foundation

// MARK: Multi-subject localizations

extension Localizable {
    static let appTitle = Localizable(NSLocalizedString("Piece", comment: "Piece title"))
    static let addProjectSectionTitle = Localizable(NSLocalizedString("Add project or section", comment: ""))
    static let longPressTitle = Localizable(NSLocalizedString("Actions", comment: "Actions"))
}

// MARK: Project localizations

extension Localizable {
    static let addProject = Localizable(NSLocalizedString("Add project", comment: ""))
    static let addProjectTextFieldTitle = Localizable(NSLocalizedString("New project title", comment: ""))
    static let noProjects = Localizable(NSLocalizedString("You have no projects. Try adding one.", comment: "No projects"))
}

// MARK: Section localizatios

extension Localizable {
    static let addSection = Localizable(NSLocalizedString("Add section", comment: ""))
    static let addSectionTextFieldTitle = Localizable(NSLocalizedString("New section title", comment: ""))
    static let noSections = Localizable(NSLocalizedString("You have no sections. Try adding one.", comment: "No sections"))
}

// MARK: Recording localizations

extension Localizable {
    static let startRecording = Localizable(NSLocalizedString("Start recording", comment: ""))
    static let stopRecording = Localizable(NSLocalizedString("Stop recording", comment: ""))
    static let noRecordings = Localizable(NSLocalizedString("There are no recordings in this section. Try recording some audio.", comment: "No recordings"))
}

// MARK: Generic localizations

extension Localizable {
    static let done = Localizable(NSLocalizedString("Done", comment: ""))
    static let cancel = Localizable(NSLocalizedString("Cancel", comment: ""))
    static let edit = Localizable(NSLocalizedString("Edit", comment: ""))
    static let delete = Localizable(NSLocalizedString("Delete", comment: "Delete"))
    static let rename = Localizable(NSLocalizedString("Rename", comment: "Rename"))
    static let save = Localizable(NSLocalizedString("Save", comment: "Save"))
}
