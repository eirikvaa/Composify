//
//  ProjectDetailsViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 20/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

class ProjectDetailsViewModel: ObservableObject, SongRepositoryInjectable {
    func update<Value>(project: inout Project, keypath: WritableKeyPath<Project, Value>, value: Value) {
        songRepository.update(project: &project, keypath: keypath, value: value)
    }

    func save(section: Section, to project: Project) {
        songRepository.save(section: section, to: project)
    }

    func save(project: Project) {
        songRepository.save(project: project)
    }

    func update<Value>(section: inout Section, keypath: WritableKeyPath<Section, Value>, value: Value) {
        songRepository.update(section: &section, keypath: keypath, value: value)
    }

    func delete(section: Section) {
        songRepository.delete(section: section)
    }

    func delete(project: Project) {
        songRepository.delete(project: project)
    }
}
