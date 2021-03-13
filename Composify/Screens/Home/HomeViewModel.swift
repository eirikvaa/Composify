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

    init(currentProject: Project? = nil) {
        self.currentProject = currentProject
    }

    func getProjects() -> [Project] {
        songRepository.getProjects()
    }

    func getSections(in project: Project) -> [Section] {
        songRepository.getSections(in: project)
    }
}
