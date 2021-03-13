//
//  HomeViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

class HomeViewModel: ObservableObject, SongRepositoryInjectable {
    enum State {
        case noProjects
        case noSections(project: Project)
        case loaded(project: Project, sections: [Section])
    }

    @Published var state: State = .noProjects
    @Published var currentProject: Project?

    init(currentProject: Project? = nil) {
        self.currentProject = currentProject
    }

    func getProjects() -> [Project] {
        songRepository.getProjects()
    }

    func getSections(in project: Project) -> [Section] {
        songRepository.getSections(in: project)
    }

    func loadData() {
        state = .noProjects

        let projects = getProjects()

        if projects.isEmpty {
            return
        }

        // TODO: Remember the current project
        guard let currentProject = projects.first else {
            return
        }

        let sections = getSections(in: currentProject)

        if sections.isEmpty {
            state = .noSections(project: currentProject)
            return
        }

        state = .loaded(project: currentProject, sections: sections)
    }
}
