//
//  AdministrateProjectDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

protocol AdministrateProjectDelegate: class {
    /// User aded a section to a project
    /// - parameter section: The section that was added
    func userDidAddSectionToProject(_ section: Section)

    /// The user deleted a section from the project
    func userDidDeleteSectionFromProject()

    /// The user edited the title of one or more sections and/or the project itself
    func userDidEditTitleOfObjects()

    /// The user deleted the project
    func userDidDeleteProject()
}
