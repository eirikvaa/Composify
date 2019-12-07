//
//  AdministrateProjectDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

protocol AdministrateProjectDelegate: AnyObject {
    func userDidCreateProject(_ project: Project)
    func userDidAddSectionToProject(_ section: Section)
    func userDidDeleteSectionFromProject()
    func userDidEditTitleOfObjects()
    func userDidDeleteProject()
    func userDidReorderSections()
}
