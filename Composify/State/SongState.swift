//
//  SongState.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

class SongState: ObservableObject, SongRepositoryInjectable {
    @Published var currentProject: Project?
    @Published var currentSection: Section?

    func select(currentProject: Project?, currentSection: Section? = nil) {
        self.currentProject = currentProject
        self.currentSection = currentSection ?? currentProject?.sections.first

        songRepository.set(currentProject: currentProject, currentSection: currentSection)
    }

    func refresh() {
        let (currentProject, currentSection) = songRepository.getCurrentProjectAndSection()

        self.currentProject = currentProject
        self.currentSection = currentSection
    }
}
