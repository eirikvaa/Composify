//
//  HomeViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

class HomeViewModel: ObservableObject, SongRepositoryInjectable {
    @Published var currentProject: Project?
    @Published var currentSection: Section?

    init(currentProject: Project? = nil, currentSection: Section? = nil) {
        self.currentProject = currentProject
        self.currentSection = currentSection
    }

    func loadData() {
        // TODO: Remember the current project
        currentProject = songRepository.getProjects().first
        currentSection = currentProject?.sections.first
    }

    func save(recording: Recording) {
        if let currentSection = currentSection {
            songRepository.save(recording: recording, to: currentSection)
        }
    }
}
